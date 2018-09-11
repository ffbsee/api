 Freifunk API
=========
Repository to hold our api file for [directory.api.freifunk.net](https://github.com/freifunk/directory.api.freifunk.net).

 API Generator:
----
https://freifunk.net/api-generator/


 Standortermittlung
----
*Eine ungefähre Standortermittlung findet anhand der GEO Koordinaten statt.*

```bash
#               --- Standortkonzept: ---
    Bodman-   |              |          |                 | Ravensburg
 Ludwigshafen | Ueberlingen  |          |                 |_____________
              |              | Markdorf |                 |
 -------------|______________|          | Friedrichshafen | Tettnang
                        B   O   D       |                 |______________
                   Konstanz  |       E    N               |
                             |          |     S   E   E   | Kressbronn
                             |          |                 |______________
                             |          |                 |
                             |          |                 |    Lindau
```


 Aktueller Stand
----
 + ''ffbsee.nodes.pl'' is now an ansible template
 + Ansible will generate automatically new Data for freifunk-karte.de
 + You need update the node numbers manually '':-/'' 
