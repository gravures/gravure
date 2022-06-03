Design notes
=====================

## Fonctionnalité plannifiés

* gestion des limites de ressources du RIP
* disposer d'une première implémentation des lignes d'impressions
  * composite/séparation
  * monitorer les chaînes de filtres
  * définition des profils icc d'une ligne d'impression composites
  * definitions des courbes de calibrations en composite/séparation
  * disposer d'un tramage AM
* Centralisation des formats papiers (voir libpaper)
* preview/controle du placement sur format (rasterview)    
* integrer les définitions de adobe ppd spec dans une help

## recherche d'implémentations

* développer une première mouture d'un RipManager, incluant notamment un analyseur de chaîne de filtres, qui au mieux pourrait permettre de modifier une chaîne.
* Tester les fusions de ppd
* étudier les contraintes d'ui des ppd
* étudier un hack du system-config-printer
* étudier genppd de gutenprint en vue d'une regénération des ppd de libgutenprint 

______________________________________________________________________________

### GRAVURE RIP

* ☐ implement a print lines model
* ☐ implement a generic document modéle
* ☐ gestion des ressources du RIP
* ☐ module d'imposition
* ☐ module de calibration
* ☐ direct print module 

______________________________________________________________________________

### SCREEN MODELER

* ☐ GREEN NOISE STOCHASTIQUE THRESHOLD ARRAY GENERATION
  * ☑ first implementation
* ☐ AM THRESHOLD ARRAY GENERATION
* ☐ MODELER GUI 
* ☐ screenprinting helper
* ☐ MOIRE MODELER

______________________________________________________________________________

### GRAVURE.NUMERIC

* ☑ gmath module
* ☐ mdarray module
  * ☑ base implementation
  * ☐ arithmetic methods
  * ☐ 1 bit array mode
  * ☐ convertion methods

______________________________________________________________________________

### GRAVURE.PYGUTENPRINT

* reprendre l'implementation



### GHOSTSCRIPT-GRAVURE

* ☑ empaquetage de ghostscript-9.06 pour wheezy
* ☑ empaquetage de ghostscript-9.15 pour wheezy
* ☒ empaquetage de gen_ordered
* ☐ portage de icc_creator
* ☐ empaquetage de device gravure pour test

### VIEWER PS/PDF

* un remplacement à ghostview

### CALCULATEUR / CONVERTISSEUR

* voir table de conversion "how to be a great screenprinter"
* calculatrice pour imprimeur

#### RASTERVIEW

* ☑ empaquetage pour wheezy

______________________________________________________________________________

### ARGYLL GUI

* hack des utilitaires dispcal orienté print
* exploration des profils icc
* convertion v4-->v3
* dotgain curve <--> icc
* gui utilitaire argyll
* voir lcms et outil icc consortium
* viewer gamut 3d : library lookat, 

<http://www.scipy.org/topical-software.html>
<http://mayavi.sourceforge.net/>
<https://pypi.python.org/pypi/menpo-PyVRML97/2.3.0a4>
