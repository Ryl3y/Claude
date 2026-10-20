# Identité visuelle TONTINE+

![Planche d'identité](planche-identite.png)

## L'idée

Le symbole, **la calebasse**, est la caisse commune de la tontine : une calebasse en terre cuite,
gravée d'une frise en zigzag, dans laquelle une **pièce d'or** vient d'être déposée.

- la **calebasse** est l'objet qu'on se passe de main en main dans les réunions : elle dit la
  confiance et la tradition ;
- la **pièce** qui passe derrière le rebord, c'est la cotisation de chacun qui entre dans la caisse ;
- la **frise** rappelle les motifs gravés des calebasses et des poteries d'Afrique centrale.

Le « + » ocre du nom fait écho à la pièce. Promesse : **Chacun son tour. Tous ensemble.**

## Fichiers

| Fichier | Usage |
| --- | --- |
| `svg/logo-horizontal.svg` | Logo principal sur fond clair |
| `svg/logo-horizontal-blanc.svg` | Logo sur fond brun nuit ou photo sombre |
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
| Terre cuite | `#B4532A` | Couleur principale, boutons, la calebasse |
| Brun nuit | `#5A2614` | Fonds sombres, barre de navigation |
| Ocre | `#E9A23B` | Accent unique : la pièce, le « + », le tour tiré ; jamais en grand aplat de texte |
| Crème | `#F6EBDD` | Fond des pages, logo sur fond sombre |
| Brun | `#3B2A20` | Texte, nom dans le logo |

## Typographie

Le nom est dessiné à partir de **Caladea Bold**, une serif chaleureuse (licence SIL Open Font
License). L'interface garde la police système, plus lisible en petit.

## Règles

- Zone de protection autour du logo : au moins le diamètre de la pièce.
- Taille minimale : symbole 16 px, logo horizontal 24 px de haut.
- Ne pas changer les couleurs du symbole, ne pas le déformer, ne pas sortir la pièce de la calebasse.
- Sur fond clair : version couleur. Sur fond sombre : version blanche (calebasse crème, la pièce reste ocre).

## Régénérer

`generer_logo.py` produit tous les SVG (Python 3 + `fonttools`, police Caladea installée) :

```sh
python generer_logo.py svg/
```
