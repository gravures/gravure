# -*- coding: utf-8 -*-

import sys
import os
import logging

import zim.config
import zim.config.basedirs
from zim.fs import Dir, File
from zim.errors import Error
from zim.templates import get_template


from zim.formats import *
from zim.formats import get_format
from zim.formats.plain import Dumper as TextDumper
from zim.export.selections import AllPages, SinglePage, SubPages
from zim.command import Command, UsageError, GetoptError
from zim.notebook import Notebook, Path, \
    get_notebook_list, resolve_notebook, build_notebook
from zim.main import NotebookCommand

logger = logging.getLogger('zim')
EXPORT_MODULE = sys.modules['__main__']


#
# Rst Exporter

info = {
    'name': 'reST',
    'desc': 'reST (Octopress)',
    'mimetype': 'text/x-rst',
    'extension': 'rst',
    # No official file extension, but this is often used
    'native': False,
    'import': False,
    'export': True,
    'usebase': True,
}


class Dumper(TextDumper):

    BULLETS = {
        UNCHECKED_BOX:    u'- \u2610',
        XCHECKED_BOX:    u'- \u2612',
        CHECKED_BOX:    u'- \u2611',
        BULLET:        u'-',
    }

    TAGS = {
        EMPHASIS:    ('*', '*'),
        STRONG:        ('**', '**'),
        MARK:        ('', ''),  # TODO, no directly way to do this in rst
        STRIKE:        ('', ''),  # TODO, no directly way to do this in rst
        VERBATIM:    ("``", "``"),
        TAG:        ('', ''),  # No additional annotation (apart from the visible @)
        SUBSCRIPT:    ('\\ :sub:`', '`\\ '),
        SUPERSCRIPT:    ('\\ :sup:`', '`\\ '),
    }
    # TODO tags other than :sub: and :sup: may also need surrounding whitespace, deal with this in post process (join) action ?
    # IDEM for blocks like images and objects, how to enforce empty lines and how to deal with inline images..

    HEADING_UNDERLINE = ['=', '-', '^', '"']

    def dump(self, tree):
        assert self.linker, 'rst dumper needs a linker object'
        return TextDumper.dump(self, tree)
        
    def dump_indent(self, tag, attrib, strings):
        # Prefix lines with one or more tabs
        if attrib and 'indent' in attrib:
            prefix = '\t' * int(attrib['indent'])
            return self.prefix_lines(prefix, strings)
            # TODO enforces we always end such a block with \n unless partial
        else:
            return self.prefix_lines('| ', strings)

    dump_p = dump_indent
    dump_div = dump_indent
    dump_pre = dump_indent

    def dump_h(self, tag, attrib, strings):
        # Underlined headings
        level = int(attrib['level'])
       
        if level < 1:   level = 1
        elif level > 4: level = 4
        
        char = self.HEADING_UNDERLINE[level-1]
        heading = u''.join(strings)
        
        underline = char * len(heading)
        return [heading + '\n', underline]
        
        
    def dump_pre(self, tag, attrib, strings):
        # prefix last line with "::\n\n"
        # indent with \t to get preformatted
        strings = self.prefix_lines('\t', strings)
        strings.insert(0, '::\n\n')
        return strings

    def dump_link(self, tag, attrib, strings=None):
        # Use inline url form, putting links at the end is more difficult
        assert 'href' in attrib, \
            'BUG: link misses href: %s "%s"' % (attrib, strings)
        href = self.linker.link(attrib['href'])
        text = u''.join(strings) or href
        
        if href[-3:] == 'rst':
            if href[0:2] == './':
                href = href[2:]
            return ':doc:`%s`' % (href[:-4],)
        else:
            return '`%s <%s>`_' % (text, href)

    def dump_img(self, tag, attrib, strings=None):
        src = self.linker.img(attrib['src'])
        text = '.. image:: %s\n' % src

        items = attrib.items()
        items.sort()  # unit tests don't like random output
        for k, v in items:
            if k == 'src' or k.startswith('_'):
                continue
            elif v:  # skip None, "" and 0
                text += '   :%s: %s\n' % (k, v)

        return text + '\n'

        # TODO use text for caption (with full recursion)
        # can be done using "figure" directive

    dump_object_fallback = dump_pre

    def dump_table(self, tag, attrib, strings):
        table = []  # result table

        aligns, _wraps = TableParser.get_options(attrib)
        rows = TableParser.convert_to_multiline_cells(strings)
        maxwidths = TableParser.width3dim(rows)
        rowsep = lambda y: TableParser.rowsep(maxwidths, x='+', y=y)
        rowline = lambda row: TableParser.rowline(row, maxwidths, aligns)

        # print table
        table.append(rowsep('-'))
        table += [rowline(line) for line in rows[0]]
        table.append(rowsep('='))
        for row in rows[1:]:
            table += [rowline(line) for line in row]
            table.append(rowsep('-'))

        return map(lambda line: line+"\n", table)

    def dump_th(self, tag, attrib, strings):
        strings = [s.replace('|', '∣') for s in strings]
        return [self._concat(strings)]

    def dump_td(self, tag, attrib, strings):
        strings = [s.replace('|', '∣') for s in strings]
        return [self._concat(strings)]


#
# Command Line Interface Code

def build_rst_exporter(dir, format, template, **opts):
    from zim.export.layouts import MultiFileLayout
    from zim.export.exporters.files import MultiFileExporter

    template = get_template(format, template)
    ext = get_format(format).info['extension']
    layout = MultiFileLayout(dir, ext)
    mfe = MultiFileExporter(layout, template, format, **opts)
    mfe.format = EXPORT_MODULE
    return mfe
    

class RstExportCommand(NotebookCommand):
    '''Class implementing the C{--export} command'''

    arguments = ('NOTEBOOK', '[PAGE]')
    options = (
        ('format=', '', 'format to use (defaults to \'html\')'),
        ('template=', '', 'name or path of the template to use'),
        ('output=', 'o', 'output folder, or output file name'),
        ('root-url=', '', 'url to use for the document root'),
        ('index-page=', '', 'index page name'),
        ('recursive', 'r', 'when exporting a page, also export sub-pages'),
        ('singlefile', 's', 'export all pages to a single output file'),
        ('overwrite', 'O', 'overwrite existing file(s)'),
    )

    def get_exporter(self, page):
        from zim.fs import File, Dir
        from zim.export import \
            build_mhtml_file_exporter, \
            build_single_file_exporter, \
            build_page_exporter, \
            build_notebook_exporter

        format = self.opts.get('format', 'html')
        if not 'output' in self.opts:
            raise UsageError, _('Output location needed for export')  # T: error in export command
        output = Dir(self.opts['output'])
        if not output.isdir():
            output = File(self.opts.get('output'))
        template = self.opts.get('template', 'Default')

        if output.exists() and not self.opts.get('overwrite'):
            if output.isdir():
                if len(output.list()) > 0:
                    raise Error, _('Output folder exists and not empty, specify "--overwrite" to force export')  # T: error message for export
                else:
                    pass
            else:
                raise Error, _('Output file exists, specify "--overwrite" to force export')  # T: error message for export

        if format == 'mhtml':
            self.ignore_options('index-page')
            if output.isdir():
                raise UsageError, _('Need output file to export MHTML')  # T: error message for export

            exporter = build_mhtml_file_exporter(
                output, template,
                document_root_url=self.opts.get('root-url'),
            )
        elif page:
            self.ignore_options('index-page')
            if output.exists() and output.isdir():
                ext = 'html'
                output = output.file(page.basename) + '.' + ext

            if self.opts.get('singlefile'):
                exporter = build_single_file_exporter(
                    output, format, template, namespace=page,
                    document_root_url=self.opts.get('root-url'),
                )
            else:
                exporter = build_page_exporter(
                    output, format, template, page,
                    document_root_url=self.opts.get('root-url'),
                )
        else:
            if not output.exists():
                output = Dir(output.path)
            elif not output.isdir():
                raise UsageError, _('Need output folder to export full notebook')  # T: error message for export

            
            if format == 'rst':
                exporter = build_rst_exporter(
                    output, format, template,
                    index_page=self.opts.get('index-page'),
                    document_root_url=self.opts.get('root-url'),
                )
            else:
                exporter = build_notebook_exporter(
                    output, format, template,
                    index_page=self.opts.get('index-page'),
                    document_root_url=self.opts.get('root-url'),
                )

        return exporter

    def run(self):
        from zim.export.selections import AllPages, SinglePage, SubPages

        notebook, page = self.build_notebook()
        #~ notebook.index.update()

        if page and self.opts.get('recursive'):
            selection = SubPages(notebook, page)
        elif page:
            selection = SinglePage(notebook, page)
        else:
            selection = AllPages(notebook)
            
        exporter = self.get_exporter(page)
        exporter.export(selection)


#
# Main Section Code

# Check if we run the correct python version
def main(*argv):
    '''Run full zim application
    @returns: exit code (if error handled, else just raises)
    '''
    argv = list(argv)
    exe = argv.pop(0)

    obj = build_command(argv)
    import zim.errors  # !???
    zim.errors.set_use_gtk(obj.use_gtk)

    obj.set_logging()
    try:
        obj.run()
    except KeyboardInterrupt:
        # Don't show error dialog for this error..
        logger.error('KeyboardInterrupt')
        return 1
    except Exception:
        zim.errors.exception_handler('Exception in main()')
        return 1
    else:
        return 0


def build_command(argv):
    '''Parse all commandline options
    @returns: a L{Command} object
    @raises UsageError: if argv is not correct
    '''
    argv = list(argv)
    argv.pop(0)

    obj = RstExportCommand('export-rst')
    obj.parse_options(*argv)
    return obj


try:
    version_info = sys.version_info
    assert version_info >= (2, 6)
    assert version_info < (3, 0)
except:
    print >> sys.stderr, 'ERROR: zim needs python >= 2.6   (but < 3.0)'
    sys.exit(1)

# Try importing our modules
try:
    import zim
    import zim.main
    import zim.ipc
except ImportError:
    sys.excepthook(*sys.exc_info())
    print >>sys.stderr, 'ERROR: Could not find python module files in path:'
    print >>sys.stderr, ' '.join(map(str, sys.path))
    print >>sys.stderr, '\nTry setting PYTHONPATH'
    sys.exit(1)

# Run the application and handle some exceptions
try:
    zim.ipc.handle_argv()
    encoding = sys.getfilesystemencoding()  # not 100% sure this is correct
    argv = [arg.decode(encoding) for arg in sys.argv]
    exitcode = main(*argv)
    sys.exit(exitcode)
except zim.main.GetoptError, err:
    print >>sys.stderr, sys.argv[0]+':', err
    sys.exit(1)
except zim.main.UsageError, err:
    print >>sys.stderr, err.msg
    sys.exit(1)
except KeyboardInterrupt:  # e.g. <Ctrl>C while --server
    print >>sys.stderr, 'Interrupt'
    sys.exit(1)
else:
    sys.exit(0)





