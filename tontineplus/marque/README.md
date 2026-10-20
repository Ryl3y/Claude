# Identité visuelle TONTINE+

![Planche d'identité](planche-identite.png)

## L'idée

Le symbole, **le maillon**, est fait de deux maillons de chaîne entrelacés à angle droit, l'un
vert, l'autre or. Ensemble, ils dessinent un **« + »** :

- la **chaîne** dit la solidarité qui lie les membres : chacun tient sa place, et c'est ensemble
  que la caisse tient ;
- le **« + »** reprend le nom et l'argent qui grandit à plusieurs.

Les maillons passent alternativement dessus et dessous (dessus, dessous, dessus, dessous), comme
une vraie chaîne. Le « + » or du nom fait écho au maillon or du symbole.

Promesse : **Chacun son tour. Tous ensemble.**

## Fichiers

| Fichier | Usage |
| --- | --- |
| `svg/logo-horizontal.svg` | Logo principal sur fond clair |
| `svg/logo-horizontal-blanc.svg` | Logo sur fond vert nuit ou photo sombre |
| `svg/symbole.svg`, `svg/symbole-blanc.svg` | Symbole seul (avatar, tampon, petit espace) |
| `svg/mot-symbole.svg` | Nom seul |
| `svg/icone-app.svg`, `png/icone-*.png` | Icône d'application (coins arrondis) |
| `svg/icone-carree.svg`, `png/apple-touch-icon.png`, `png/icone-maskable-512.png` | Icône pleine pour iOS et Android (le système arrondit lui-même) |
| `svg/favicon.svg`, `png/favicon-32.png` | Onglet du navigateur |

Tous les SVG ont le texte **vectorisé** : ils s'affichent à l'identique sans police installée.
Préférez toujours le SVG ; les PNG servent quand le SVG n'est pas accepté.

## Couleurs

| Nom | Hex | Rôle |
| --- | --- | --- |
| Vert tontine | `#0E5A3C` | Couleur principale, boutons |
| Vert nuit | `#0A2E22` | Fonds sombres, barre de navigation |
| Or caisse | `#E8A93B` | Accent unique : le tour tiré, le « + », jamais en grand aplat de texte |
| Ivoire | `#FBF6EC` | Fond des pages, logo sur fond sombre |
| Charbon | `#1C2420` | Texte |

## Typographie

Inter Display Bold (titres, logo) et SemiBold. Le logo est dessiné à partir d'Inter Display Bold
(licence SIL Open Font License).

## Règles

- Zone de protection autour du logo : au moins l'épaisseur d'un maillon multipliée par deux.
- Taille minimale : symbole 16 px, logo horizontal 24 px de haut.
- Ne pas changer les couleurs du symbole, ne pas le déformer, ne pas supprimer les croisements dessus/dessous.
- Sur fond clair : version couleur. Sur fond sombre : version blanche (le maillon vertical reste or).

## Régénérer

`generer_logo.py` produit tous les SVG (Python 3 + `fonttools`, police Inter Display installée) :

```sh
python generer_logo.py svg/
```
