================
Debian Packaging
================
| Created lundi 31 décembre 2012
| `http://www.isalo.org/wiki.debian-fr/index.php?title=Gestion_des_archives_sous_Debian <http://www.isalo.org/wiki.debian-fr/index.php?title=Gestion_des_archives_sous_Debian>`_

Chartes Debian
^^^^^^^^^^^^^^
| `http://www.debian.org/doc/devel-manuals#devref <http://www.debian.org/doc/devel-manuals#devref>`_
| `http://ftp-master.debian.org/REJECT-FAQ.html <http://ftp-master.debian.org/REJECT-FAQ.html>`_
| `http://lists.debian.org/debian-devel-announce/2006/03/msg00023.html <http://lists.debian.org/debian-devel-announce/2006/03/msg00023.html>`_
| `http://www.debian.org/doc/debian-policy/index.html#contents <http://www.debian.org/doc/debian-policy/index.html#contents>`_

GNU AutoTools
^^^^^^^^^^^^^
| `http://www.gnu.org/software/autoconf/ <http://www.gnu.org/software/autoconf/>`_
| `http://www.lrde.epita.fr/~adl/dl/autotools.pdf <http://www.lrde.epita.fr/~adl/dl/autotools.pdf>`_
| `http://www.gnu.org/prep/standards/ <http://www.gnu.org/prep/standards/>`_
| `http://inti.sourceforge.net/tutorial/libinti/autotoolsproject.html <http://inti.sourceforge.net/tutorial/libinti/autotoolsproject.html>`_

Debian packaging guides
^^^^^^^^^^^^^^^^^^^^^^^
| → `http://www.debian.org/doc/manuals/maint-guide/index.fr.html <http://www.debian.org/doc/manuals/maint-guide/index.fr.html>`_
| → `http://wiki.debian.org/IntroDebianPackaging <http://wiki.debian.org/IntroDebianPackaging>`_
| → `http://www.debian.org/doc/packaging-manuals/python-policy/ <http://www.debian.org/doc/packaging-manuals/python-policy/>`_
| `http://www.debian.org/devel/wnpp/prospective <http://www.debian.org/devel/wnpp/prospective>`_
| `http://rcrowley.org/articles/packaging.html <http://rcrowley.org/articles/packaging.html>`_


Essentials Tools
^^^^^^^^^^^^^^^^

| build-essential autoconf automake autotools-dev debhelper dh-make dh-autoreconf devscripts fakeroot file git gnupg lintian patch patchutils pbuilder quilt xutils-dev DEVELOPPER:VUE GENERALE:PACKAGING & DISTRIBUTION:GRAVURE:VUE GENERALE:PACKAGING & DISTRIBUTION:piuparts


Modification de debian/changelog
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

| - new upstream release
|  ``dch --newversion --edit --preserve --multimaint``

| - ajouter une modif dans la version actuelle
| ``dch --append --edit --multimaint``

Update Symbols
^^^^^^^^^^^^^^

| `https://www.debian.org/doc/manuals/maint-guide/advanced.en.html <https://www.debian.org/doc/manuals/maint-guide/advanced.en.html>`_
| 	- construire le paquet avec pdebuild
| 	- recuperer dans le log de construction le fichier diff généré par dpkg-gensymbols
| 	- l'enregistrer comme fichier diff
| 	- appliquer les diffs avec patch
| 		``patch -b ghostscript-9.15~dfsg-1/debian/symbols.common libgs-9.15_symbols.diff``
| 	- tenter de reconstruire le paquet

Construire un paquet
^^^^^^^^^^^^^^^^^^^^

| - ``sudo mk-build-deps -ir``
| - dpkg-buildpackage ou debuild
| - `pbuilder <./Debian_Packaging/PBUILDER.txt>`_


CDBS
^^^^

| - `http://debathena.mit.edu/packaging/ <http://debathena.mit.edu/packaging/>`_
| - `http://cdbs-doc.duckcorp.org/en/cdbs-doc.xhtml#id467909 <http://cdbs-doc.duckcorp.org/en/cdbs-doc.xhtml#id467909>`_
| - `http://doc.ubuntu-fr.org/projets/paquets/creer_un_paquet_avec_cdbs <http://doc.ubuntu-fr.org/projets/paquets/creer_un_paquet_avec_cdbs>`_
| - python →  `https://wiki.edubuntu.org/PackagingGuide/Python <https://wiki.edubuntu.org/PackagingGuide/Python>`_


Signing package
^^^^^^^^^^^^^^^

| - **Creating a new GPG key**
| 	`http://keyring.debian.org/creating-key.html <http://keyring.debian.org/creating-key.html>`_
| 	`http://www.gnupg.org/howtos/fr/GPGMiniHowto-3.html <http://www.gnupg.org/howtos/fr/GPGMiniHowto-3.html>`_

| - **signing**
| 	- Packages will be automatically signed as long as the name and email address in your package’s changelog file are the same as that of the GPG key you created.
	
| 	This means that simply running **dpkg-buildpackage** will now give you signed packages.

| 	- If you want to resign an existing debian package, for example if you’re setting up your own backport of a package (as with my usecase, backporting Chef 0.9.16 into debian), then this is very easy too if you already have a GPG key set up. We use a tool called **dpkg-sig**.

| 	``$ dpkg-sig --sign-changes full --sign builder *.deb``

| 	- signer fichier .changes et dsc
| 	``debsign -k'atelier obscur' libtrio_1.16+dfsg1-3_source.changes``

| 	ou
	
| 	- **laisser rerepro signer les paquets**


Verification apres construction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| `http://www.debian.org/doc/manuals/maint-guide/checkit.fr.html <http://www.debian.org/doc/manuals/maint-guide/checkit.fr.html>`_

| - verification de nom de fichier en conflit avec **apt-file**
| 		``apt-file update``
| 	``apt-file search -D nemo_1.1.2_amd64.deb``
	
| - Vérification de l'installation d'un paquet avec **debi**
| 	 ``sudo debi gentoo_0.9.12-1_i386.changes``
	
| - Vérification des scripts du responsable d'un paquet : **piuparts**
|    `http://piuparts.debian.org/doc/piuparts.1.html <http://piuparts.debian.org/doc/piuparts.1.html>`_
| 	- Les séquences suivantes devraient être essayées :
| 	- installation de la version précédente (si elle existe) ;  
| 	- mise à niveau depuis la version précédente ;
| 	- dégradation (« downgrade ») à la version précédente (optionnel) ;
| 	- purge ;
| 	- installation du nouveau paquet ;
| 	- suppression (« remove ») du paquet ;
| 	- installation du paquet, encore ;
| 	- purge ; 

| 	``$ piuparts -d wheezy --no-upgrade-test package_amd64.deb`` 
| 	``$ piuparts -d wheezy --no-upgrade-test package_amd64.changes``

| - Exécutez **lintian** sur le fichier .changes.
| 	``$ lintian -i -I --show-overrides gentoo_0.9.12-1_i386.changes``

| - La commande **debc** permet d'énumérer les fichiers du paquet Debian binaire.
| 	``$ debc paquet.changes``

| - La commande debdiff(1) peut comparer les contenus de fichiers entre deux paquets Debian sources.
| 	``$ debdiff ancien-paquet.dsc nouveau-paquet.dsc``
	
| - La commande debdiff(1) permet aussi de comparer les listes de fichiers entre deux ensembles de paquets Debian binaires.
| 	``$ debdiff ancien-paquet.changes nouveau-paquet.changes``


Ajout dans le dépot
^^^^^^^^^^^^^^^^^^^

| 	- copy des fichier par scp dan `/apt/debian/incoming <file:///apt/debian/incoming>`_
| 	- connection ssh puis cd `/apt/debian <file:///apt/debian>`_
| 	- rerepro processincoming
| 		ou

| 	- reprepro -v includedeb wheezy incoming/*.deb
| 	- reprepro -v includedsc wheezy incoming/*.dsc



