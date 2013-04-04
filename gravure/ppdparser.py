# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <gilles@atelierobscur.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License with
# the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
# if not, write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301, USA.

from __future__ import print_function

__author__ = "Gilles Coissac <gilles@atelierobscur.org>"
__date__ = "Wed Jan 16 13:49:44 2013"
__version__ = "$Revision: 0.1 $"
__credits__ = "Atelier Obscur : www.atelierobscur.org"

import PARAM
import parameters

import os
import fnmatch
import string
import xml.etree.ElementTree as etree
from xml.dom import minidom

PPD_DICTIONARY_FILENAME = 'ppd_dictionary.xml'
PPD_DICTIONARY = etree.Element('ppd_dictionary')
etree.SubElement(PPD_DICTIONARY, 'keywords')
etree.SubElement(PPD_DICTIONARY, 'qualifiers')


def buildPPDDictionary(fromXML=True):
    global PPD_DICTIONARY
    keys_dir = getPPDDictionaryPath()
    if os.path.exists(keys_dir) and fromXML:
        PPD_DICTIONARY = openPPDDictionary()
    for files in os.listdir(keys_dir):
        if fnmatch.fnmatch(files, 'keywords_*'):
            p = os.path.join(keys_dir, files)
            k_dict = PPD_DICTIONARY.find('keywords')
            try:
                fk = open(p, 'r')
                sp = string.rsplit(files[9:], '_', 2)
                sp2 = string.rsplit(sp[0], '-', 2)
                kd = {'origin': sp2[0], 'version': sp2[1], 'base_type': sp[1]}
                for line in fk:
                    tag = '_' + string.rstrip(line, '\n')
                    if k_dict.find(tag) is None:
                        etree.SubElement(k_dict, tag, kd)
                    else:
                        print (tag, 'already in PPD_DICTIONARY')
                        print(files)
            except IOError:
                print('error when parsing data keywords files')
            finally:
                fk.close()
    for files in os.listdir(keys_dir):
        if fnmatch.fnmatch(files, 'qualifier_*'):
            p = os.path.join(keys_dir, files)
            q_dict = PPD_DICTIONARY.find('qualifiers')
            try:
                fk = open(p, 'r')
                tag = string.rsplit(files, '_', 2)[1]
                for line in fk:
                    keyword = string.rstrip(line, '\n')
                    for e in q_dict.findall(tag):
                        if e.get('keyword') == keyword:
                            print('qualifier already present for keyword')
                            break
                    else:
                        # TODO: test if qualifiers not define inexistant keyword
                        etree.SubElement(q_dict, tag, {'keyword': keyword})
            except IOError:
                print('error when parsing data qualifiers files')
            finally:
                fk.close()
    writePPDDictionary(PPD_DICTIONARY)


def writePPDDictionary(element):
    keys_dir = getPPDDictionaryPath()
    s = etree.tostring(element, encoding='UTF-8', method='xml')
    p = minidom.parseString(s)
    p = p.toprettyxml(indent="  ")
    dp = os.path.join(keys_dir, PPD_DICTIONARY_FILENAME)
    try:
        df = open(dp, 'w')
        df.write(p)
    except IOError:
        print('error when opening ppd dictionary')
    finally:
        df.close()


def openPPDDictionary():
    keys_dir = getPPDDictionaryPath()
    dp = os.path.join(keys_dir, PPD_DICTIONARY_FILENAME)
    element = None
    try:
        df = open(dp, 'r')
        element = etree.fromstringlist(df.readlines())
    except IOError:
        print('error when opening ppd dictionary')
    finally:
        df.close()
    return element


def getPPDDictionaryPath():
    base_dir = os.path.abspath(os.path.dirname(__file__))
    return os.path.join(base_dir, 'keywords')
