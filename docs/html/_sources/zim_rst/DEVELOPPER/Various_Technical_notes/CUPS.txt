================
CUPS
================
| Created mercredi 17 octobre 2012

IPP
^^^
| `http://en.wikipedia.org/wiki/Internet_Printing_Protocol <http://en.wikipedia.org/wiki/Internet_Printing_Protocol>`_
| `http://www.cups.org/documentation.php/api-httpipp.html <http://www.cups.org/documentation.php/api-httpipp.html>`_
| `http://www.cups.org/documentation.php/spec-ipp.html <http://www.cups.org/documentation.php/spec-ipp.html>`_

Cups-pk-helper
^^^^^^^^^^^^^^

| see : `http://www.vuntz.net/journal/post/2010/02/19/A-few-words-about-cups-pk-helper <http://www.vuntz.net/journal/post/2010/02/19/A-few-words-about-cups-pk-helper>`_...


Cups device changes
^^^^^^^^^^^^^^^^^^^

| 2011-08-01 13:05:09 +0200
| Till Kamppeter <`till.kamppeter@gmail.com <mailto:till.kamppeter@gmail.com>`_>
| b4c67383d9e71b468b5384b7a63095864d3a9ae7

| 	CUPS Raster output device: Ignore RIP_MAX_CACHE environment variable

| 	Ghostscript is (at least currently) not able to work with hard-limited
| 	space parameters. It crashes with a segmentation fault on many input
| 	files then. Leaving the setting of these parameters fully automatic
| 	Ghostscript works just fine. As in most distributions (Currently all
| 	except Debian, Ubuntu, and their derivatives) CUPS imposes a hard
| 	limit via the RIP_MAX_CACHE environment variable, the only way to
| 	assure reliable working of Ghostscript is to ignore the parameter,
| 	leaving the space parameters in automatic mode. For CUPS this should
| 	be no regression, as print queues with other Ghostscript drivers (like
| 	pxlcolor, ljet4, ...) worked without hard limits all the time and no
| 	one complained.

| 	To ignore this RIP_MAX_CACHE we simply add a "return" right at the
| 	beginning of this function. It will be removed when a real fix gets
| 	into place.

| 	See `http://bugs.ghostscript.com/show_bug.cgi?id=691586 <http://bugs.ghostscript.com/show_bug.cgi?id=691586>`_

| 	gs/cups/gdevcups.c 
	
| _________________________________________________________________
| 2011-07-30 11:56:53 +0200
| Till Kamppeter <`till.kamppeter@gmail.com <mailto:till.kamppeter@gmail.com>`_>
| 83abb6ca67829a1273ed4fdfc894a6af44c5c5ad

| 	Added "-dNOINTERPOLATE" to the Ghostscript command lines of the CUPS filters

| 	This makes rendering significantly faster and the output of normal
| 	files comming as print jobs from applications does not show any
| 	visible difference.

| 	gs/cups/gstoraster.c
| 	gs/cups/pstopxl.in 
	
	

Limiting usage ressources
^^^^^^^^^^^^^^^^^^^^^^^^^

| see : `http://pl.digipedia.org/usenet/thread/15766/2301/ <http://pl.digipedia.org/usenet/thread/15766/2301/>`_

| **FilterLimit**
| Exemples

| 	FilterLimit 0
| 	FilterLimit 200
| 	FilterLimit 1000

| Description

| La directive FilterLimit définit le coût maximal de tous les filtres appliqués au travaux en cours de traitement. Elle peut être utilisée pour limiter le nombre de programmes de filtres qui son exécutés dans un serveur pour minimiser les problèmes de ressources disque, mémoire ou CPU. Une limite de 0 désactive la limitation des filtres.

| Le coût moyen d'une impression vers une imprimante non-PostScript nécessite une limitation de filtre aux alentours de 200. Une imprimante PostScript nécessite une limite d'environ la moitié (100). Positionner la limite en dessous de ces seuils va effectivement limiter l'ordonnanceur à l'impression d'un travail à la fois.

| La valeur implicite est 0. 

| **RIPCache**
| Exemples

| 	RIPCache 8m
| 	RIPCache 1g
| 	RIPCache 2048k

| Description

| La directive RIPCache définit la quantité de mémoire utilisée par les filtres RIP ("Raster Images Processor") tels que imagetoraster et pstoraster. La taille peut être suffixée par "k" pour kilo-octets, "m" pour méga-octets, ou "g" pour giga-octets. La taille implicite est de "8m", ou 8 méga-octets. 

| **TempDir**
| Exemples

| 	TempDir /var/tmp
| 	TempDir /foo/bar/tmp

| Description

| La directive TempDir indique un chemin absolu pour le répertoire à employer pour les fichiers temporaires. Le répertoire standard est `/var/tmp. <file:///var/tmp.>`_
| The default directory is `/var/spool/cups/tmp. <file:///var/spool/cups/tmp.>`_

| Les répertoires temporaires doivent être inscriptibles pour tous et devraient avoir le "sticky" bit activé de sorte que les utilisateurs ne puissent pas supprimer les fichiers temporaires de filtres. Les commandes suivantes créerons un répertoire temporaire approprié appelé /foo/bar/tmp:

| 	mkdir /foo/bar/tmp ENTREE
| 	chmod a+rwxt /foo/bar/tmp ENTREE

| **User**
| Exemples

| 	User lp
| 	User guest

| Description

| La directive User indique l'utilisateur UNIX sous l'identité duquel les programmes CGI et les filtres doivent fonctionner. La valeur implicite est lp. 

| **Group**
| Exemples

| 	Group sys
| 	Group system
| 	Group root

| Description

| La directive Group définit le groupe UNIX sous l'identité duquel les programmes CGI et de filtrage fonctionnent. Le groupe implicite est sys, system, ou root selon le système d'exploitation. 

| **RunAsUser**
| Exemples

| 	RunAsUser Yes
| 	RunAsUser No

| Description

| La directive RunAsUser contrôle si l'ordonnanceur fonctionne sous l'identité d'un compte utilisateur non privilégié (habituellement lp). La valeur implicite est No qui laisse l'utilisateur fonctionner en tant qu'utilisateur root .

| Note: Faire fonctionner CUPS en tant qu'utilisateur non privilégié peut empêcher LPD et les imprimantes connectées localement de fonctionner correctement en raison de problèmes de permissions. Le programme d'arrière-plan lpd utilisera automatiquement le mode non privilégié ce qui est 100% conforme à la RFC 1179. Les programmes d'arrière-plan parallel, serial, et usb auront besoin d'accès en écriture aux fichiers de périphériques correspondants. 

| **PreserveJobFiles**
| Exemples

| 	PreserveJobFiles On
| 	PreserveJobFiles Off

| Description

| La directive PreserveJobFiles contrôle si les fichiers des documents complétés, annulés ou abandonnés sont stockés sur disque.

| La valeur On conserve les fichiers des travaux jusqu'à ce que l'administrateur les purge au moyen de la commande cancel . Les travaux peuvent être resoumis (réimprimés) jusqu'à ce qu'ils soient purgés.

| La valeur Off (valeur implicite) retire les fichiers des travaux dès ceux-ci sont complétés, annulés ou abandonnés.
| Printcap

| **MaxJobsPerUser**
| Exemples

| 	MaxJobsPerUser 100
| 	MaxJobsPerUser 9999
| 	MaxJobsPerUser 0

| Description

| La directive MaxJobsPerUser contrôle le nombre maximum de travaux d'impression qui sont autorisés pour chaque utilisateur. Dès qu'un utilsateur atteint le maximum autorisé, tout nouveau travail sera rejeté avant qu'un des travaux actifs soit complété, arrêté, annulé ou abandonné.

| Régler le maximum sur 0 (valeur implicite) désactive cette fonctionnalité. 

| **MaxJobsPerPrinter**
| Exemples

| 	MaxJobsPerPrinter 100
| 	MaxJobsPerPrinter 9999
| 	MaxJobsPerPrinter 0

| Description

| **AutoPurgeJobs**
| Exemples

| 	AutoPurgeJobs Yes
| 	AutoPurgeJobs No

| Description

| La directive AutoPurgeJobs indique si oui ou non il faut purger les travaux d'impression lorsqu'ils ne sont plus nécessaires au vu des quotas. Cet option n'a aucun effet si les quotas ne sont pas activés. La valeur implicite est No. 
| La directive MaxJobsPerPrinter contrôle le nombre maximum de travaux actifs qui sont autorisés pour chaque imprimante ou classe d'imprimantes. Dès que le nombre est atteint pour une imprimante ou une classe, les nouveaux travaux sont rejetés tant que l'un des travaux actifs n'est pas complété, arrêté, annulé ou abandonné.

| Régler le maximum sur la valeur 0 (valeur implicite) désactive cette fonctionnalité. 



