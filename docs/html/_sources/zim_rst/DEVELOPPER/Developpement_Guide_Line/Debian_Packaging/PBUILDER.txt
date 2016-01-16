================
PBUILDER
================
| Created dimanche 28 décembre 2014


ENVIRONNEMENT
^^^^^^^^^^^^^

| → `http://www.megatunix.com/blog/2012/05/09/using-pbuilder-for-making-debianubuntu-packages/ <http://www.megatunix.com/blog/2012/05/09/using-pbuilder-for-making-debianubuntu-packages/>`_
| → `http://wiki.debian.org/PbuilderTricks <http://wiki.debian.org/PbuilderTricks>`_

| - apt-cacher-ng | pbuilder | debootstrap | quilt
| - /usr/lib/pbuilder/hooks
| - /var/cache/pbuilder/repo
| - ajout de ne comme extrapackage pour editer les fichiers apres login chrooter 
| - ajout du depot atelier obscur manuellement car l'ajout dans `~/.pbuilderrc <file:///home/gilles/.pbuilderrc>`_ EXTRAMIRROR provoque une erreur 403 à la creation de l'environnement → conflit avec apt-cacher-ng (double port). deactiver httpproxy in `./pbuilderrc <./PBUILDER/pbuilderrc>`_ si besoin du depot ao et installer le par chroot

HOOKS
^^^^^

| - `/usr/lib/pbuilder/hooks/B90lintian <file:///usr/lib/pbuilder/hooks/D05deps>`_
| - `/usr/lib/pbuilder/hooks/C10shell <file:///usr/lib/pbuilder/hooks/C10shell>`_
| - `/usr/lib/pbuilder/hooks/D05deps <file:///usr/lib/pbuilder/hooks/D05deps>`_

INITIALISATION
^^^^^^^^^^^^^^

| - **Now we need to initialize the “Packages” file for the empty repo so we can work the first time:**

| ``dpkg-scanpackages /var/cache/pbuilder/repo > /var/cache/pbuilder/repo/Packages``

| - **initialize the pbuilder images for each OS variant**
	
| 	``for arch in `echo i386 amd64` ; do for dist in `echo sid wheezy jessie saucy raring quantal precise trusty` ; do sudo DIST=${dist} ARCH=${arch} pbuilder --create --configfile /home/gilles/.pbuilderrc --architecture ${arch} --distribution ${dist} ; done ; done |tee /tmp/baseimage_create.log``

| 	ou
	
| 	``for arch in `echo i386 amd64` ; do for dist in `echo wheezy`; do sudo DIST=${dist} ARCH=${arch} pbuilder --create --configfile /home/gilles/.pbuilderrc --architecture ${arch} --distribution ${dist}  ; done ; done |tee /tmp/baseimage_create.log``
	
| 	ou
	
	
| 	``for arch in `echo amd64` ; do for dist in `echo wheezy`; do sudo DIST=${dist} ARCH=${arch} pbuilder --create --configfile /home/gilles/.pbuilderrc --architecture ${arch} --distribution ${dist} ; done ; done |tee /tmp/baseimage_create.log``

| 	ou
	
| 	``sudo DIST=wheezy ARCH=amd64 pbuilder --configfile /home/gilles/.pbuilderrc --create --architecture amd64 --distribution testing |tee /tmp/baseimage_create.log``
	

BUILD
^^^^^

| - **build any debian source package**
| 	that has a “debian” directory within it, 
| 	run the following, making sure your in the dir 
| 	that CONTAINS the “debian” directory
	
| 	``pdebuild --architecture <i386|amd64> --buildresult /tmp --pbuilderroot "sudo DIST=<sid|wheezy|jessie|trusty|precise|quantal|raring|saucy> ARCH=<i386|amd64>"``
	
| 	ou

| 	``pdebuild --architecture <i386|amd64>  --buildresult /tmp --pbuilderroot "sudo DIST=<unstable|stable|testing|hardy|lucid|natty|oneiric|precise> ARCH=<i386|amd64>"``

| 	ou
	
| 	``pdebuild --architecture amd64  --buildresult /tmp --pbuilderroot "sudo DIST=<wheezy | jessie> ARCH=amd64"``

| 	ou
	
| 	``pdebuild --configfile /home/gilles/.pbuilderrc --architecture amd64 --pbuilderroot "sudo DIST=wheezy ARCH=amd64"``


| - **to UPDATE** 
| 	your distroot’s to current patches do the following:

| 	``for arch in `echo amd64` ; do for dist in `echo wheezy` ; do sudo DIST=${dist} ARCH=${arch} pbuilder --update --configfile /home/gilles/.pbuilderrc; done ; done |tee /tmp/baseimage_update.log``
	
| - to **chroot**
	
| 	``sudo DIST=wheezy ARCH=amd64 pbuilder --login --save-after-login --configfile /home/gilles/.pbuilderrc --architecture amd64 --distribution wheezy``
	


