"""Génère le logo TONTINE+ en SVG (texte vectorisé, aucune police requise à l'affichage)."""
import math, os, sys
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen

SORTIE = sys.argv[1]
os.makedirs(SORTIE, exist_ok=True)

VERT, VERT_NUIT, OR, IVOIRE, CHARBON = "#0E5A3C", "#0A2E22", "#E8A93B", "#FBF6EC", "#1C2420"

# ---- Symbole : le cycle de la tontine découpé en 6 tours ; le segment or sort du cercle :
#      c'est le tour que le tirage au sort vient de désigner.
SEGMENTS, ELU = 6, 0
R_EXT, R_INT, ECART, SORTIE_ELU, ARRONDI = 47, 25, 5.2, 7.5, 3.2


def secteur(cx, cy, i, couleur, decalage=0.0):
    """Secteur d'anneau à coupes parallèles (écart constant), coins adoucis par un trait de même couleur."""
    pas = 360 / SEGMENTS
    milieu = math.radians(-90 + (i + 0.5) * pas)
    cx, cy = cx + decalage * math.cos(milieu), cy + decalage * math.sin(milieu)
    demi = (ECART + ARRONDI) / 2  # le trait d'arrondi mord sur l'écart
    ext, inte = R_EXT - ARRONDI / 2, R_INT + ARRONDI / 2

    def point(r, a):
        return cx + r * math.cos(a), cy + r * math.sin(a)

    a1 = math.radians(-90 + i * pas)
    a2 = math.radians(-90 + (i + 1) * pas)
    e1, e2 = a1 + demi / ext, a2 - demi / ext
    i1, i2 = a1 + demi / inte, a2 - demi / inte
    (x1, y1), (x2, y2) = point(ext, e1), point(ext, e2)
    (x3, y3), (x4, y4) = point(inte, i2), point(inte, i1)
    d = (f"M{x1:.2f} {y1:.2f}A{ext:.2f} {ext:.2f} 0 0 1 {x2:.2f} {y2:.2f}"
         f"L{x3:.2f} {y3:.2f}A{inte:.2f} {inte:.2f} 0 0 0 {x4:.2f} {y4:.2f}Z")
    return (f'<path d="{d}" fill="{couleur}" stroke="{couleur}" stroke-width="{ARRONDI}" '
            f'stroke-linejoin="round"/>')


def symbole(couleur, accent, *_):
    return "".join(secteur(60, 60, i, accent if i == ELU else couleur, SORTIE_ELU if i == ELU else 0)
                   for i in range(SEGMENTS))


def plus(cx, cy, longueur, epaisseur):
    l, e = longueur / 2, epaisseur / 2
    return (f'<rect x="{cx-l:.2f}" y="{cy-e:.2f}" width="{longueur:.2f}" height="{epaisseur:.2f}" rx="{e:.2f}"/>'
            f'<rect x="{cx-e:.2f}" y="{cy-l:.2f}" width="{epaisseur:.2f}" height="{longueur:.2f}" rx="{e:.2f}"/>')


# ---- Mot-symbole « tontine » en Inter Display Bold vectorisé, suivi du « + » or dessiné
police = TTFont("/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf")
glyphes, cmap = police.getGlyphSet(), police.getBestCmap()
upm = police["head"].unitsPerEm
hmtx = police["hmtx"]


def texte_en_chemin(texte, taille, x0, ligne_base, approche=0.0):
    echelle = taille / upm
    chemins, x = [], x0
    for car in texte:
        nom = cmap[ord(car)]
        stylo = SVGPathPen(glyphes)
        glyphes[nom].draw(stylo)
        d = stylo.getCommands()
        if d:
            chemins.append(f'<path transform="translate({x:.2f} {ligne_base:.2f}) scale({echelle:.5f} {-echelle:.5f})" d="{d}"/>')
        x += hmtx[nom][0] * echelle + approche * taille
    return "".join(chemins), x


def mot_symbole(couleur, accent, x0, ligne_base, taille):
    chemins, x_fin = texte_en_chemin("tontine", taille, x0, ligne_base, approche=-0.012)
    hauteur_x = 0.545 * taille
    plus_cote, plus_ep = hauteur_x * 0.92, taille * 0.12
    px = x_fin + taille * 0.06 + plus_cote / 2
    py = ligne_base - hauteur_x / 2
    return f'<g fill="{couleur}">{chemins}</g><g fill="{accent}">{plus(px, py, plus_cote, plus_ep)}</g>', px + plus_cote / 2


def ecrire(nom, contenu):
    with open(os.path.join(SORTIE, nom), "w") as f:
        f.write(contenu)


titre = '<title>TONTINE+</title>'
# Symbole seul
ecrire("symbole.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" role="img" aria-label="TONTINE+">{titre}{symbole(VERT, OR, IVOIRE)}</svg>')
ecrire("symbole-blanc.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" role="img" aria-label="TONTINE+">{titre}{symbole(IVOIRE, OR, VERT)}</svg>')

# Icône d'application : carré arrondi vert nuit, symbole ivoire
icone = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" role="img" aria-label="TONTINE+">{titre}'
         f'<rect width="120" height="120" rx="27" fill="{VERT}"/>'
         f'<g transform="translate(15 15) scale(0.75)">{symbole(IVOIRE, OR)}</g></svg>')
ecrire("icone-app.svg", icone)
ecrire("favicon.svg", icone)

# Logo horizontal : symbole + mot-symbole
TAILLE = 74
mot, fin = mot_symbole(CHARBON, OR, 136, 83, TAILLE)
mot_b, _ = mot_symbole(IVOIRE, OR, 136, 83, TAILLE)
largeur = math.ceil(fin + 4)
ecrire("logo-horizontal.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {largeur} 120" role="img" aria-label="TONTINE+">{titre}{symbole(VERT, OR, IVOIRE)}{mot}</svg>')
ecrire("logo-horizontal-blanc.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {largeur} 120" role="img" aria-label="TONTINE+">{titre}{symbole(IVOIRE, OR)}{mot_b}</svg>')
# Mot-symbole seul
mot_seul, fin_seul = mot_symbole(CHARBON, OR, 2, 83, TAILLE)
ecrire("mot-symbole.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {math.ceil(fin_seul + 4)} 120" role="img" aria-label="TONTINE+">{titre}{mot_seul}</svg>')
print("largeur logo horizontal :", largeur)

# Icône carrée pleine (iOS arrondit lui-même ; Android « maskable » : symbole dans la zone sûre de 80 %)
ecrire("icone-carree.svg", f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" role="img" aria-label="TONTINE+">{titre}'
       f'<rect width="120" height="120" fill="{VERT}"/><g transform="translate(24 24) scale(0.6)">{symbole(IVOIRE, OR)}</g></svg>')
