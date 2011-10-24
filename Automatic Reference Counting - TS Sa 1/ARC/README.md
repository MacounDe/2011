Automatic Reference Counting
============================

Unterlagen zum Vortrag Automatic Reference Counting von der Macoun 2011.

Teilprojekte
------------

* **ARC.key/.pdf** Die Folien zur Präsentation

* **NoARC** Ein Projekt, das ohne ARC compiliert wird. Stellt eine Klasse bereit, deren Instanzen alle Aufrufe auf alloc, allocWithZone, retain, autorelease und release loggen. Jeder Instanz kann mit allocWithLabel: oder mit initWithLabel: ein Label zugewiesen werden, das jeweils mit ausgegeben wird. (Diese Klasse diente mir dazu, zu verstehen, wann ARC was wirklich macht. Die Klatte ist nicht für produktiven Code gedacht.)

* **Demo** Projekt, das NoARC unter ARC benutzt.

* **Demo.xcworkspace** Verbindet Demo und NoARC

Copyright
---------

Alle Dokumente in diesem Repository stehen unter CC-SA-BY (Daniel Höpfl).
Siehe <http://creativecommons.org/licenses/by-sa/3.0/de/>

