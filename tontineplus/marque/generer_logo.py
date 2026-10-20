"""Génère le logo TONTINE+ en SVG (texte vectorisé : aucune police requise à l'affichage).

Symbole « la calebasse » : la caisse commune, gravée d'une frise en zigzag, dans laquelle
une pièce vient d'être déposée. Chacun apporte sa part ; la caisse se remplit pour tous.

Usage : python generer_logo.py <dossier_sortie>   (Python 3 + fonttools, police Caladea Bold)
"""

import math
import os
import sys

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

SORTIE = sys.argv[1]
os.makedirs(SORTIE, exist_ok=True)

TERRE, BRUN_NUIT, OCRE, CREME, BRUN = "#B4532A", "#5A2614", "#E9A23B", "#F6EBDD", "#3B2A20"


def calebasse(c_bol, c_piece, c_gravure):
    """Calebasse (demi-sphère + rebord) gravée d'un zigzag entre deux filets ;
    la pièce passe derrière le rebord : on la voit entrer dans la caisse."""
    piece = (f'<circle cx="60" cy="40" r="16" fill="{c_piece}"/>'
             f'<circle cx="60" cy="40" r="10.5" fill="none" stroke="{c_bol}" stroke-opacity=".28" stroke-width="2.2"/>')
    bol = f'<path d="M14 60H106A46 46 0 0 1 14 60Z" fill="{c_bol}"/>'
    rebord = f'<rect x="10" y="53" width="100" height="11" rx="5.5" fill="{c_bol}"/>'
    zigzag = " ".join(f"{x},{70 if i % 2 == 0 else 81}" for i, x in enumerate(range(26, 96, 7)))
    gravure = (f'<g fill="none" stroke="{c_gravure}" stroke-opacity=".55" stroke-width="2.4" stroke-linecap="round" '
               f'stroke-linejoin="round"><path d="M24 66H96"/><polyline points="{zigzag}"/><path d="M29 85H91"/></g>')
    return piece + bol + rebord + gravure


def plus(cx, cy, longueur, epaisseur, couleur):
    l, e = longueur / 2, epaisseur / 2
    return (f'<g fill="{couleur}"><rect x="{cx-l:.2f}" y="{cy-e:.2f}" width="{longueur:.2f}" height="{epaisseur:.2f}" rx="{e:.2f}"/>'
            f'<rect x="{cx-e:.2f}" y="{cy-l:.2f}" width="{epaisseur:.2f}" height="{longueur:.2f}" rx="{e:.2f}"/></g>')


# ---- Mot-symbole « Tontine » (Caladea Bold vectorisé) suivi du « + » ocre ----
police = TTFont("/usr/share/fonts/truetype/crosextra/Caladea-Bold.ttf")
glyphes, cmap, upm, hmtx = police.getGlyphSet(), police.getBestCmap(), police["head"].unitsPerEm, police["hmtx"]


def texte_en_chemin(texte, taille, x0, ligne_base):
    echelle, x, chemins = taille / upm, x0, []
    for car in texte:
        nom = cmap[ord(car)]
        stylo = SVGPathPen(glyphes)
        glyphes[nom].draw(stylo)
        if stylo.getCommands():
            chemins.append(f'<path transform="translate({x:.2f} {ligne_base:.2f}) scale({echelle:.5f} {-echelle:.5f})" '
                           f'd="{stylo.getCommands()}"/>')
        x += hmtx[nom][0] * echelle
    return "".join(chemins), x


def mot_symbole(couleur, x0, ligne_base, taille):
    chemins, x_fin = texte_en_chemin("Tontine", taille, x0, ligne_base)
    hauteur_x = 0.47 * taille
    cote, ep = hauteur_x * 0.98, taille * 0.115
    cx = x_fin + taille * 0.08 + cote / 2
    return f'<g fill="{couleur}">{chemins}</g>' + plus(cx, ligne_base - hauteur_x / 2 - 1, cote, ep, OCRE), cx + cote / 2


def svg(viewbox, contenu):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{viewbox}" role="img" aria-label="TONTINE+">'
            f'<title>TONTINE+</title>{contenu}</svg>')


def ecrire(nom, contenu):
    with open(os.path.join(SORTIE, nom), "w") as f:
        f.write(contenu)


ecrire("symbole.svg", svg("0 0 120 120", calebasse(TERRE, OCRE, CREME)))
ecrire("symbole-blanc.svg", svg("0 0 120 120", calebasse(CREME, OCRE, BRUN_NUIT)))

icone = svg("0 0 120 120", f'<rect width="120" height="120" rx="27" fill="{BRUN_NUIT}"/>'
                           f'<g transform="translate(14 16) scale(.7667)">{calebasse(CREME, OCRE, BRUN_NUIT)}</g>')
ecrire("icone-app.svg", icone)
ecrire("favicon.svg", icone)
# Icône pleine : iOS et Android arrondissent eux-mêmes ; symbole dans la zone sûre (80 %).
ecrire("icone-carree.svg", svg("0 0 120 120", f'<rect width="120" height="120" fill="{BRUN_NUIT}"/>'
                                              f'<g transform="translate(24 26) scale(.6)">{calebasse(CREME, OCRE, BRUN_NUIT)}</g>'))

TAILLE, X_MOT, BASE = 76, 130, 84
mot, fin = mot_symbole(BRUN, X_MOT, BASE, TAILLE)
mot_b, _ = mot_symbole(CREME, X_MOT, BASE, TAILLE)
largeur = math.ceil(fin + 4)
ecrire("logo-horizontal.svg", svg(f"0 0 {largeur} 120", calebasse(TERRE, OCRE, CREME) + mot))
ecrire("logo-horizontal-blanc.svg", svg(f"0 0 {largeur} 120", calebasse(CREME, OCRE, BRUN_NUIT) + mot_b))
seul, fin_seul = mot_symbole(BRUN, 2, BASE, TAILLE)
ecrire("mot-symbole.svg", svg(f"0 0 {math.ceil(fin_seul + 4)} 120", seul))
print("logo généré dans", SORTIE)
