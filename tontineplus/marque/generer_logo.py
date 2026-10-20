"""Génère le logo TONTINE+ en SVG (texte vectorisé : aucune police requise à l'affichage).

Symbole « le maillon » : deux maillons entrelacés à angle droit, vert et or, dessinent un « + ».
La chaîne dit la solidarité qui lie les membres ; le « + » reprend le nom.

Usage : python generer_logo.py <dossier_sortie>   (Python 3 + fonttools, police Inter Display)
"""

import math
import os
import sys

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

SORTIE = sys.argv[1]
os.makedirs(SORTIE, exist_ok=True)

VERT, VERT_NUIT, OR, IVOIRE, CHARBON = "#0E5A3C", "#0A2E22", "#E8A93B", "#FBF6EC", "#1C2420"

# ---- Symbole : deux maillons (ligne médiane) dans un carré de 120 ----
EPAISSEUR, ECART = 13, 4.2        # trait du maillon ; vide visible de part et d'autre d'un croisement
LONG, LARGE = 96, 38              # longueur et largeur d'un maillon (ligne médiane) : bras longs = « + » lisible
C = 60


def stade(horizontal):
    """Ligne médiane d'un maillon (rectangle aux bouts en demi-cercle)."""
    r = LARGE / 2
    if horizontal:
        x0, x1, y0, y1 = C - LONG / 2 + r, C + LONG / 2 - r, C - r, C + r
        return f"M{x0} {y0}H{x1}A{r} {r} 0 0 1 {x1} {y1}H{x0}A{r} {r} 0 0 1 {x0} {y0}Z"
    y0, y1, x0, x1 = C - LONG / 2 + r, C + LONG / 2 - r, C - r, C + r
    return f"M{x0} {y0}V{y1}A{r} {r} 0 0 0 {x1} {y1}V{y0}A{r} {r} 0 0 0 {x0} {y0}Z"


def maillons(c_horizontal, c_vertical, uid):
    """Entrelacement : le maillon vertical passe dessus en haut à droite et en bas à gauche,
    dessous aux deux autres croisements (dessus, dessous, dessus, dessous)."""
    h, v = stade(True), stade(False)
    d = LARGE / 2                       # les croisements sont en (C ± d, C ± d)
    z = EPAISSEUR + 2 * ECART + 2       # zone carrée autour d'un croisement

    def zones(points):
        return "".join(f'<rect x="{C + sx*d - z/2}" y="{C + sy*d - z/2}" width="{z}" height="{z}"/>'
                       for sx, sy in points)

    dessus_v = zones([(1, -1), (-1, 1)])
    dessus_h = zones([(-1, -1), (1, 1)])
    trou = EPAISSEUR + 2 * ECART
    return (f'<defs><clipPath id="zv{uid}">{dessus_v}</clipPath><clipPath id="zh{uid}">{dessus_h}</clipPath>'
            f'<mask id="mh{uid}"><rect width="120" height="120" fill="#fff"/>'
            f'<path d="{v}" fill="none" stroke="#000" stroke-width="{trou}" clip-path="url(#zv{uid})"/></mask>'
            f'<mask id="mv{uid}"><rect width="120" height="120" fill="#fff"/>'
            f'<path d="{h}" fill="none" stroke="#000" stroke-width="{trou}" clip-path="url(#zh{uid})"/></mask></defs>'
            f'<path d="{h}" fill="none" stroke="{c_horizontal}" stroke-width="{EPAISSEUR}" mask="url(#mh{uid})"/>'
            f'<path d="{v}" fill="none" stroke="{c_vertical}" stroke-width="{EPAISSEUR}" mask="url(#mv{uid})"/>')


def plus(cx, cy, longueur, epaisseur, couleur):
    l, e = longueur / 2, epaisseur / 2
    return (f'<g fill="{couleur}"><rect x="{cx-l:.2f}" y="{cy-e:.2f}" width="{longueur:.2f}" height="{epaisseur:.2f}" rx="{e:.2f}"/>'
            f'<rect x="{cx-e:.2f}" y="{cy-l:.2f}" width="{epaisseur:.2f}" height="{longueur:.2f}" rx="{e:.2f}"/></g>')


# ---- Mot-symbole « tontine » (Inter Display Bold vectorisé) suivi du « + » or ----
police = TTFont("/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf")
glyphes, cmap, upm, hmtx = police.getGlyphSet(), police.getBestCmap(), police["head"].unitsPerEm, police["hmtx"]


def texte_en_chemin(texte, taille, x0, ligne_base, approche=0.0):
    echelle, x, chemins = taille / upm, x0, []
    for car in texte:
        nom = cmap[ord(car)]
        stylo = SVGPathPen(glyphes)
        glyphes[nom].draw(stylo)
        if stylo.getCommands():
            chemins.append(f'<path transform="translate({x:.2f} {ligne_base:.2f}) scale({echelle:.5f} {-echelle:.5f})" '
                           f'd="{stylo.getCommands()}"/>')
        x += hmtx[nom][0] * echelle + approche * taille
    return "".join(chemins), x


def mot_symbole(couleur, x0, ligne_base, taille):
    chemins, x_fin = texte_en_chemin("tontine", taille, x0, ligne_base, approche=-0.012)
    hauteur_x = 0.545 * taille
    cote, ep = hauteur_x * 0.92, taille * 0.12
    cx = x_fin + taille * 0.06 + cote / 2
    return f'<g fill="{couleur}">{chemins}</g>' + plus(cx, ligne_base - hauteur_x / 2, cote, ep, OR), cx + cote / 2


def svg(viewbox, contenu):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{viewbox}" role="img" aria-label="TONTINE+">'
            f'<title>TONTINE+</title>{contenu}</svg>')


def ecrire(nom, contenu):
    with open(os.path.join(SORTIE, nom), "w") as f:
        f.write(contenu)


ecrire("symbole.svg", svg("0 0 120 120", maillons(VERT, OR, "a")))
ecrire("symbole-blanc.svg", svg("0 0 120 120", maillons(IVOIRE, OR, "b")))

icone = svg("0 0 120 120", f'<rect width="120" height="120" rx="27" fill="{VERT_NUIT}"/>'
                           f'<g transform="translate(13 13) scale(.7833)">{maillons(IVOIRE, OR, "c")}</g>')
ecrire("icone-app.svg", icone)
ecrire("favicon.svg", icone)
# Icône pleine : iOS et Android arrondissent eux-mêmes ; symbole dans la zone sûre (80 %).
ecrire("icone-carree.svg", svg("0 0 120 120", f'<rect width="120" height="120" fill="{VERT_NUIT}"/>'
                                              f'<g transform="translate(24 24) scale(.6)">{maillons(IVOIRE, OR, "d")}</g>'))

TAILLE, X_MOT, BASE = 74, 134, 84
mot, fin = mot_symbole(CHARBON, X_MOT, BASE, TAILLE)
mot_b, _ = mot_symbole(IVOIRE, X_MOT, BASE, TAILLE)
largeur = math.ceil(fin + 4)
ecrire("logo-horizontal.svg", svg(f"0 0 {largeur} 120", maillons(VERT, OR, "e") + mot))
ecrire("logo-horizontal-blanc.svg", svg(f"0 0 {largeur} 120", maillons(IVOIRE, OR, "f") + mot_b))
seul, fin_seul = mot_symbole(CHARBON, 2, BASE, TAILLE)
ecrire("mot-symbole.svg", svg(f"0 0 {math.ceil(fin_seul + 4)} 120", seul))
print("logo généré dans", SORTIE)
