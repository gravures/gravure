================
Making a pdf grayscale with ghostscript
================
| Created jeudi 10 décembre 2015



| 	``% gs -sOutputFile=grayscale.pdf -sDEVICE=pdfwrite \``
| ``-sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray \``
| ``-dCompatibilityLevel=1.4 -dNOPAUSE -dBATCH color.pdf`` 


| source : `http://handyfloss.net/2008.09/making-a-pdf-grayscale-with-ghostscript/ <http://handyfloss.net/2008.09/making-a-pdf-grayscale-with-ghostscript/>`_

