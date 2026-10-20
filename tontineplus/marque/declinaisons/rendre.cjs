// Rend chaque déclinaison HTML en PNG à sa taille réelle (× 2 pour la carte et le reçu, destinés à l'impression).
// Usage : node rendre.cjs   (nécessite playwright-core et Chromium ; CHROMIUM=/chemin/vers/chrome si besoin)
const { chromium } = require('playwright-core');
const path = require('path');
const PAGES = {
  'carte-membre': [1012, 638, 2], 'recu-cotisation': [800, 1120, 2],
  'post-reseaux': [1080, 1080, 1], 'statut-whatsapp': [1080, 1920, 1], 'partage': [1200, 630, 1],
};
(async () => {
  const navigateur = await chromium.launch(process.env.CHROMIUM ? { executablePath: process.env.CHROMIUM } : {});
  for (const [nom, [largeur, hauteur, echelle]] of Object.entries(PAGES)) {
    const page = await navigateur.newPage({ viewport: { width: largeur, height: hauteur }, deviceScaleFactor: echelle });
    await page.goto('file://' + path.join(__dirname, nom + '.html'));
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({ path: path.join(__dirname, 'png', nom + '.png') });
    await page.close();
  }
  await navigateur.close();
})();
