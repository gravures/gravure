#! /usr/bin/env python3.2
# -*- coding: utf-8 -*-

import sys
import runpy
import subprocess

def build():
    try :
        arg = ['python3', '/home/gilles/FOSSILS/gravure/setup.py', 'build_ext', '--inplace']
        sub = subprocess.Popen(arg, stdout=subprocess.PIPE)
        returnDatas = sub.communicate()
        (out , err) = returnDatas
        retcode = sub.returncode
        if retcode < 0:
            sys.stderr.write("Child was terminated by signal", -retcode)
        else:
            print("output : %s" %out.decode())
        if err is not None:
            print("error : ", err)
    except OSError as e:
        sys.stderr.write("interpreter not found: %s" %e)
    finally:
        print('----------------------------------------------------------------------------------------------------------------------\n')

print('\n----------------------------------------------------------------------------------------------------------------------')
print("Gravure devellopemt warpper script...")
build()
o = runpy.run_module(sys.argv[1],  alter_sys=True)
