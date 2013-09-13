# Debian Packaging
Created lundi 31 décembre 2012
<http://www.isalo.org/wiki.debian-fr/index.php?title=Gestion_des_archives_sous_Debian>

### Chartes Debian
<http://www.debian.org/doc/devel-manuals#devref>
<http://ftp-master.debian.org/REJECT-FAQ.html>
<http://lists.debian.org/debian-devel-announce/2006/03/msg00023.html>
<http://www.debian.org/doc/debian-policy/index.html#contents>

### GNU AutoTools
<http://www.gnu.org/software/autoconf/>
<http://www.lrde.epita.fr/~adl/dl/autotools.pdf>
<http://www.gnu.org/prep/standards/>
<http://inti.sourceforge.net/tutorial/libinti/autotoolsproject.html>

### Debian packaging guides
→ <http://www.debian.org/doc/manuals/maint-guide/index.fr.html>
→ <http://wiki.debian.org/IntroDebianPackaging>
→ <http://www.debian.org/doc/packaging-manuals/python-policy/>
<http://www.debian.org/devel/wnpp/prospective>
<http://rcrowley.org/articles/packaging.html>

### Construire un paquet


* ``sudo mk-build-deps -ir``
* dpkg-buildpackage ou debuild
* pbuilder


### Environnement pbuilder
→ <http://www.megatunix.com/blog/2012/05/09/using-pbuilder-for-making-debianubuntu-packages/>
→ <http://wiki.debian.org/PbuilderTricks>


* apt-cacher-ng | pbuilder | debootstrap | quilt
* /usr/lib/pbuilder/hooks
* /var/cache/pbuilder/repo
* [/usr/lib/pbuilder/hooks/D05deps](../../../../../../../../../usr/lib/pbuilder/hooks/D05deps)
* [/etc/pbuilderrc](../../../../../../../../../etc/pbuilderrc) → fusion de toutes la conf ici
* ~~~(root)/.pbuilderrc~~

``for arch in `echo i386 amd64` ; do for dist in `echo testing unstable stable` ; do sudo DIST=${dist} ARCH=${arch} pbuilder --create --architecture ${arch} --distribution ${dist}  --http-proxy http://localhost:3142 ; done ; done``

``sudo DIST=testing ARCH=amd64 pbuilder --create --architecture amd64 --distribution testing --http-proxy  http://localhost:3142``



* ``pdebuild --architecture <i386|amd64>  --buildresult /tmp --pbuilderroot "sudo DIST=<unstable|stable|testing|hardy|lucid|natty|oneiric|precise> ARCH=<i386|amd64>"``


``pdebuild --architecture amd64  --buildresult /tmp --pbuilderroot "sudo DIST=testing ARCH=amd64"``


#### cdbs
<http://debathena.mit.edu/packaging/>
<http://cdbs-doc.duckcorp.org/en/cdbs-doc.xhtml#id467909>
<http://doc.ubuntu-fr.org/projets/paquets/creer_un_paquet_avec_cdbs>
python →  <https://wiki.edubuntu.org/PackagingGuide/Python>


### Signing package

#### Creating a new GPG key
<http://keyring.debian.org/creating-key.html>
<http://www.gnupg.org/howtos/fr/GPGMiniHowto-3.html>

#### signing
Packages will be automatically signed as long as the name and email address in your package’s changelog file are the same as that of the GPG key you created.
This means that simply running **dpkg-buildpackage** will now give you signed packages.

If you want to resign an existing debian package, for example if you’re setting up your own backport of a package (as with my usecase, backporting Chef 0.9.16 into debian), then this is very easy too if you already have a GPG key set up. We use a tool called **dpkg-sig**.

``$ dpkg-sig --sign-changes full --sign builder mypackage_0.1.2_amd64.deb``

### Verification apres construction
<http://www.debian.org/doc/manuals/maint-guide/checkit.fr.html>


* verification de nom de fichier en conflit avec **apt-file**

    ``apt-file update``
``apt-file search -D nemo_1.1.2_amd64.deb``
	

* Vérification de l'installation d'un paquet avec **debi**

 ``sudo debi gentoo_0.9.12-1_i386.changes``
	

* Vérification des scripts du responsable d'un paquet : **piuparts**

   <http://piuparts.debian.org/doc/piuparts.1.html>

* Les séquences suivantes devraient être essayées :
* installation de la version précédente (si elle existe) ;  
* mise à niveau depuis la version précédente ;
* dégradation (« downgrade ») à la version précédente (optionnel) ;
* purge ;
* installation du nouveau paquet ;
* suppression (« remove ») du paquet ;
* installation du paquet, encore ;
* purge ; 


``$ piuparts -d wheezy --no-upgrade-test package_amd64.deb`` 
``$ piuparts -d wheezy --no-upgrade-test package_amd64.changes``


* Exécutez **lintian** sur le fichier .changes.

``$ lintian -i -I --show-overrides gentoo_0.9.12-1_i386.changes``


* La commande **debc** permet d'énumérer les fichiers du paquet Debian binaire.

``$ debc paquet.changes``


* La commande debdiff(1) peut comparer les contenus de fichiers entre deux paquets Debian sources.

``$ debdiff ancien-paquet.dsc nouveau-paquet.dsc``
	

* La commande debdiff(1) permet aussi de comparer les listes de fichiers entre deux ensembles de paquets Debian binaires.

``$ debdiff ancien-paquet.changes nouveau-paquet.changes``


### Tools
build-essential
autoconf, automake, autotools-dev
debhelper
dh-make
devscripts
fakeroot
file
git
gnupg
lintian
patch, patchutils
pbuilder
quilt
xutils-dev
→ <http://packages.debian.org/wheezy/piuparts>




