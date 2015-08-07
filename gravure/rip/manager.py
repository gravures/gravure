from pdfminer.pdfparser import PDFParser, PDFDocument
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.pdfdevice import PDFDevice


#TODO: replace by normal import
import pyximport; pyximport.install()
import carray



# Open a PDF file.
fp = open('/home/gilles/TEST/mcb.pdf', 'rb')
# Create a PDF parser object associated with the file object.
parser = PDFParser(fp)
# Create a PDF document object that stores the document structure.
doc = PDFDocument()
# Connect the parser and document objects.
parser.set_document(doc)
doc.set_parser(parser)
doc.initialize('')

print(dir(doc))
print('')

print(doc.catalog)
print('')




#print(doc.get_outlines())
print('PAGES OUTPUT')
p = doc.get_pages()
pn = 1
for e in p:
    print('PAGE #%i' %(pn,))
    print(e)
    print('')
    print(e.attrs)
    print('')
    print('colorspace',  e.resources['ColorSpace']['CS0'], 'colorspace',  e.resources['ColorSpace']['CS1'])
    print('')
    cs = ((e.resources['ColorSpace']['CS2']))
    print(doc.getobj(cs.objid))
    #cs = ((e.resources['ColorSpace']['CS0']))
    #ref =doc.getobj(cs.objid)[1].objid
    #print(doc.getobj(ref))
    #pn+=1

print('')
print('DOC.INFO : ',  doc.info)

for i in doc.xrefs:
    pass
    #print(dir(i))


# Supply the password for initialization.
# (If no password is set, give an empty string.)
#doc.initialize(password)
# Check if the document allows text extraction. If not, abort.
#if not doc.is_extractable:
#    raise PDFTextExtractionNotAllowed

# Create a PDF resource manager object that stores shared resources.
#rsrcmgr = PDFResourceManager()
# Create a PDF device object.
#device = PDFDevice(rsrcmgr)
# Create a PDF interpreter object.
#interpreter = PDFPageInterpreter(rsrcmgr, device)
# Process each page contained in the document.
#for page in doc.get_pages():
#    interpreter.process_page(page)
