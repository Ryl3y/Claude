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

TERRE, BRUN_NUIT, OCRE, CREME, BRUN = "#9A4322", "#5A2614", "#E9A23B", "#F6EBDD", "#3B2A20"


def calebasse(c_bol, c_piece, c_gravure):
    """Calebasse (demi-sphère + rebord) gravée d'un zigzag entre deux filets ;
    la pièce passe derrière le rebord : on la voit entrer dans la caisse."""
    piece = (f'<circle cx="60" cy="40" r="16" fill="{c_piece}"/>'
             f'<circle cx="60" cy="40" r="10.5" fill="none" stroke="{c_bol}" stroke-opacity=".28" stroke-width="2.2"/>')
    bol = f'<path d="M14 60H106A46 46 0 0 1 14 60Z" fill="{c_bol}"/>'
    rebord = f'<rect x="10" y="53" width="100" height="11" rx="5.5" fill="{c_bol}"/>'
    zigzag = " ".join(f"{x},{70 if i % 2 == 0 else 81}" for i, x in enumerate(range(26, 96, 7)))
    gravure = (f'<g fill="none" stroke="{c_gravure}" stroke-opacity=".7" stroke-width="3" stroke-linecap="round" '
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


# ---- Animation d'ouverture (SVG animé, SMIL : aucun script, aucune bibliothèque) ----
# La calebasse bascule, la pièce en sort, tombe et roule vers la droite : le nom apparaît
# derrière elle au fur et à mesure, puis la pièce devient le « + ». Durée : 3 s.
def ouverture():
    ech, sol, t_nom = 1.3, 200, 96              # échelle de la calebasse, ligne du sol, taille du nom
    bx, by = 20, sol - 106 * ech                # la calebasse pose sur le sol
    r = 16 * ech                                # rayon de la pièce
    x_depart, y_depart = bx + 60 * ech, by + 40 * ech
    angles = [0, -5, 84, 84, -6, 0]             # la calebasse : petit élan, bascule, attente, se redresse
    recul = 46 * math.radians(angles[2])        # chemin parcouru en roulant sur son fond (rayon 46)
    x_bol_fin = bx + (110 + recul) * ech        # bord droit de la calebasse une fois redressée
    x_sol, y_sol = x_bol_fin + 26 + r - 4, sol - r   # la pièce touche le sol ; le nom commence 26 px après le bol
    hx = 0.47 * t_nom
    base = y_sol + hx / 2 + 1                   # le « + » sera exactement à la hauteur de la pièce
    chemins, x_fin = texte_en_chemin("Tontine", t_nom, x_sol - r + 4, base)
    cote, ep = hx * 0.98, t_nom * 0.115
    x_plus = x_fin + t_nom * 0.08 + cote / 2
    course = x_plus - x_sol
    tours = course / r * 180 / math.pi          # roulement sans glissement
    largeur = math.ceil(x_plus + cote / 2 + 20)

    def anim(attr, valeurs, debut, duree, temps="0;1", courbes="0.4 0 0.2 1", typ=None):
        balise = "animateTransform" if typ else "animate"
        t = f' type="{typ}"' if typ else ""
        return (f'<{balise} attributeName="{attr}"{t} values="{valeurs}" keyTimes="{temps}" calcMode="spline" '
                f'keySplines="{courbes}" begin="{debut}s" dur="{duree}s" fill="freeze"/>')

    # Calebasse sans sa pièce (la pièce est animée à part). Elle roule sur son fond arrondi :
    # le centre de la sphère (60, 60) reste à la même hauteur et avance de rayon × angle.
    # Elle bascule jusqu'à poser le rebord, puis se redresse sur place, à côté du nom.
    bol = calebasse(TERRE, OCRE, CREME).split('<path d="M14', 1)
    bol = '<path d="M14' + bol[1]
    temps, courbes = "0;0.08;0.3;0.78;0.92;1", "0.4 0 0.6 1;0.45 0 0.8 0.7;0 0 1 1;0.3 0 0.4 1;0.4 0 0.6 1"
    avance = ";".join(f"{46 * math.radians(a) if i < 3 else recul:.1f} 0" for i, a in enumerate(angles))
    calebasse_animee = (
        f'<g transform="translate({bx} {by:.1f}) scale({ech})">'
        f'<g>{anim("transform", avance, 0.15, 2.7, temps, courbes, "translate")}'
        f'<g>{anim("transform", ";".join(f"{a} 60 60" for a in angles), 0.15, 2.7, temps, courbes, "rotate")}{bol}</g></g></g>')

    # Pièce : gravée d'un « + » pour que le roulement se voie.
    piece = (f'<circle r="{r:.1f}" fill="{OCRE}"/><circle r="{r*.66:.1f}" fill="none" stroke="#C47F22" stroke-width="2.6"/>'
             + plus(0, 0, r * .62, r * .2, "#C47F22"))
    chute = (f'<animateMotion path="M{x_depart:.1f} {y_depart:.1f}Q{x_depart+75:.1f} {y_depart-35:.1f} {x_sol:.1f} {y_sol:.1f}" '
             f'keyPoints="0;0;1" keyTimes="0;0.6;1" calcMode="spline" keySplines="0 0 1 1;0.45 0.1 0.7 1" dur="1.05s" fill="freeze"/>')
    piece_animee = (
        f'<g>'
        f'<g>{anim("transform", f"0 0;{course:.1f} 0", 1.05, 1.2, courbes="0.15 0.55 0.35 1", typ="translate")}'
        f'<g>{chute}<g>{anim("transform", f"0;{tours * 0.25 + 90:.0f};{tours + 90:.0f}", 0.63, 1.62, "0;0.26;1", "0.3 0 0.6 1;0.15 0.55 0.35 1", "rotate")}'
        f'<g>{anim("transform", "1;1.12;0", 2.3, 0.3, "0;0.4;1", "0.3 0 0.5 1;0.5 0 0.8 0.4", "scale")}{piece}</g>'
        f'</g></g></g></g>')

    # Le nom se dévoile derrière la pièce : le bord du masque suit le bord gauche de la pièce.
    masque = (f'<clipPath id="devoile"><rect x="{x_sol - r:.1f}" y="0" height="240" width="0">'
              f'{anim("width", f"0;{course:.1f}", 1.05, 1.2, courbes="0.15 0.55 0.35 1")}</rect></clipPath>')
    nom = f'<g clip-path="url(#devoile)" fill="{BRUN}">{chemins}</g>'
    plus_final = (f'<g transform="translate({x_plus:.1f} {y_sol:.1f})"><g transform="scale(0)">'
                  f'{anim("transform", "0;1.18;1", 2.42, 0.4, "0;0.6;1", "0.3 0 0.5 1;0.4 0 0.6 1", "scale")}'
                  f'{plus(0, 0, cote, ep, OCRE)}</g></g>')
    return svg(f"0 0 {largeur} 240", f"<defs>{masque}</defs>{piece_animee}{calebasse_animee}{nom}{plus_final}")


ecrire("ouverture.svg", ouverture())
print("logo généré dans", SORTIE)
