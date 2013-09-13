# NOTES
Created samedi 04 juin 2011


regarder quand meme comment scribus cree des separation :
scprintengine_gdi_h

### GHOSTSCRIPT

Étudier le driver epsontoraster de cups, 
est-ce-qu'il attend la fin du stream venue de gs pour ensuite
envoyer le raster à l'imprimante ?
les driver peuvent-il écrire des fichiers sur le systeme ?
________________________________________________________________________________

etudier le filtre pdftoraster version ghoscript
________________________________________________________________________________

##### Devices interessant
 : gdevbit, gdevtrac, gdevtsep, gdevwts, gdevtxtw,
 gdevdevn.c/h, gdevcups, gdevprn.c/.h, gdevijs (regarder
le krgb mode !!!)


Fichier de déclarations : devs.mak, contrib.mak, cups.mak
________________________________________________________________________________

##### device de separation (uniquement raster :
tiffsep1 > 1 bit
tiiffsep > 8 bits
devicen > 8 bits
spotcmyk > 8 bits
bmpsep1
bmpsep8
pksm

##### deviceN spot colors :
devicen > 8 bits
spotcmyk > 8 bits
tiffsep1 > 1 bit
tiiffsep > 8 bits
psd >
xcf

Comme le format d'entier le + long est sur 64bit dans gs, et que tous les deviceN 
driver estime devoir fournir les plaques cmyk avec les tons direct, ils se sont limités
à des sortie 8 bits par plaque.
Une première entreprise peut etre pas trop compliqué serait de développer un [device](../GRAVURE_GHOSCRIPT_DEVICE.markdown)
qui sort une plaque à la fois, et en plus accompagné d'un pixmap/Object pour 
la séparation. La sélection de la plaque se ferait par un setPageDevice.

________________________________________________________________________________

##### petit calcul de raster

pour un format F4+ : 95 X 132 cm à 1440x1440 dpi
1 inch=2.54 cm -> 37.4 X 51 .9
37.4*1440 * 51 .9*1440 = 4'024'982'016 pixel
16 bit/pixel -> 64399712256 bits = 7861293 Ko = 7.8 Go

Question : qu'est ce qu'il arrive actuellement si j'envoie une impression
de cette taille à gutenprint en demandant du 16 bits (par exemple une
photo 16bit à 120dpi pleine page dans un pdf) ?
________________________________________________________________________________

##### Unique scénario de séparation postscript

ps_comp (level <=3) -> GS : ps_comp_level_1.5 -> aurora.ps : sep_N_ps_level_1

pdf_comp (>=1.4) -> pdftops : ps_separable_(level <=3) -> GS : ps__level_1.5 

   -> aurora.ps : sep_N_ps_level_1

pdftops = poppler (xpdf)
>> **aurora n'est pas gpl !!**

________________________________________________________________________________


#### PDF 2 PS ISSUES

Both PostScript 3 and PDF 1.3 & later support a mechanism called smooth shading which offers higher-quality monochrome or color gradient fills. Older versions of PostScript as well as the EPS file format don’t support smooth shading. This means that gradients are transformed when converting from PDF to EPS or PostScript level 2. This may lead to banding or thin white lines in the gradient.

I have never encountered PDF files with 16-bit images in them besides the ones that I created myself when playing around with that feature. Those 16 bits won’t survive refrying. A refried PDF always contains 8-bit data because that is all that PostScript can handle. 


(<http://www.prepressure.com/pdf/basics/refrying>)

					
					


PostScript as a page description language has never been limited to 256 gray levels.

Admittedly Adobe's own Level 1 RIPs did have this limitation, but the language itself does not impose any limits. (Improvements to the language incorporated in PostScript Level 2 included the ability to move data with 12 bits per channel directly to the "image" operator.)

<http://www.ledet.com/margulis/ACT_postings/ColorCorrection/ACT-16bit-histogram.htm>

					

Le PostScript 3, selon Buanic, p. 43, accepte 4096 niveaux par couleur de séparation  au lieu de 256, pour le niveau 2. 
________________________________________________________________________________



### CUPS
<http://www.cups.org/documentation.php/doc-1.2/spec-ppd.html>
Separations : Boolean <</Separations true>>setpagedevice



