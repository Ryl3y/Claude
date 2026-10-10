import 'package:flutter_test/flutter_test.dart';
import 'package:kassa/admin/admin_app.dart';
import 'package:kassa/admin/donnees/serveur_admin.dart';
import 'package:kassa/admin/ecrans/coquille_admin.dart';
import 'package:kassa/admin/etat/etat_admin.dart';
import 'package:kassa/admin/ui/carte_cameroun.dart';
import 'package:kassa/admin/ui/graphiques.dart';

void main() {
  test('chiffres lus depuis le JSON du serveur', () {
    final c = ChiffresAdmin.depuisJson({
      'boutiques': 12,
      'nouvelles_7_jours': 3,
      'essais': 5,
      'pro': 4,
      'termines': 3,
      'revenus_mois': 20000,
      'paiements_mois': 4,
      'inscriptions': [
        {'jour': '2026-10-09', 'nombre': 2},
        {'jour': '2026-10-10', 'nombre': 1},
      ],
      'revenus': [
        {'mois': '2026-10-01', 'montant': 20000},
      ],
    });
    expect(c.boutiques, 12);
    expect(c.revenusMois, 20000);
    expect(c.inscriptions, [
      (DateTime.parse('2026-10-09'), 2),
      (DateTime.parse('2026-10-10'), 1),
    ]);
    expect(c.revenus.single.$2, 20000);
  });

  test('boutique sans abonnement ni sauvegarde', () {
    final b = BoutiqueAdmin.depuisJson({
      'id': 'b1',
      'nom': 'Chez Awa',
      'telephone': '237690000001',
      'ville': 'Douala',
      'quartier': 'Akwa',
      'type_commerce': 'alimentation',
      'cree_le': '2026-10-01T08:00:00+00:00',
      'formule': null,
      'date_fin': null,
      'derniere_activite': null,
      'ventes': 0,
      'total': 1,
    });
    expect(b.formule, isNull);
    expect(b.dateFin, isNull);
    expect(b.derniereActivite, isNull);
    expect(b.creeLe, DateTime.utc(2026, 10, 1, 8));
  });

  test('date de fin : jour sans heure', () {
    final a = AjustementAdmin.depuisJson({
      'cree_le': '2026-10-10T10:00:00Z',
      'admin_email': 'rich@kassa.cm',
      'jours': 10,
      'formule': 'pro',
      'nouvelle_fin': '2026-11-19',
      'motif': 'Geste',
    });
    expect(a.nouvelleFin, DateTime.utc(2026, 11, 19));
  });

  test('villes : accents, tirets et majuscules ignorés', () {
    expect(cleVille(' Yaoundé '), 'yaounde');
    expect(cleVille('ABONG-MBANG'), 'abong mbang');
    expect(villesCameroun.containsKey(cleVille('Ngaoundéré')), isTrue);
    expect(villesCameroun.containsKey(cleVille('Mora')), isFalse);
  });

  test('toutes les villes connues sont dans le contour du pays', () {
    bool dedans((double, double) p) {
      var dans = false;
      for (
        var i = 0, j = contourCameroun.length - 1;
        i < contourCameroun.length;
        j = i++
      ) {
        final (xi, yi) = contourCameroun[i];
        final (xj, yj) = contourCameroun[j];
        if ((yi > p.$2) != (yj > p.$2) &&
            p.$1 < (xj - xi) * (p.$2 - yi) / (yj - yi) + xi) {
          dans = !dans;
        }
      }
      return dans;
    }

    for (final e in villesCameroun.entries) {
      expect(dedans(e.value), isTrue, reason: e.key);
    }
  });

  test('une ville écrite de deux façons ne compte qu\'une fois', () {
    final z = fusionnerZones(const [
      ZoneAdmin(ville: 'Yaoundé', boutiques: 3, pro: 1),
      ZoneAdmin(ville: 'Douala', boutiques: 2, pro: 2),
      ZoneAdmin(ville: 'Yaounde', boutiques: 1, pro: 0),
    ], cleVille);
    expect(z, hasLength(2));
    expect(z.first.ville, 'Yaoundé');
    expect(z.first.boutiques, 4);
    expect(z.first.pro, 1);
  });

  test('graduation ronde', () {
    expect(maxRond(0), 2);
    expect(maxRond(3), 4);
    expect(maxRond(7), 10);
    expect(maxRond(30000), 40000);
    expect(maxRond(30000) / 2, 20000); // repère du milieu rond
  });

  test('redirection : connexion obligatoire', () {
    Uri u(String s) => Uri.parse(s);
    expect(
      redirectionAdmin(const AdminChargement(), u('/')),
      CheminsAdmin.connexion,
    );
    expect(
      redirectionAdmin(const AdminDeconnecte(), u('/boutiques')),
      '/connexion?retour=%2Fboutiques',
    );
    expect(
      redirectionAdmin(const AdminDeconnecte(), u('/connexion?retour=/carte')),
      isNull,
    );
    // Session reprise : retour à l'écran demandé.
    expect(
      redirectionAdmin(const AdminConnecte('a'), u('/connexion?retour=/carte')),
      CheminsAdmin.carte,
    );
    // Adresse inconnue : tableau de bord.
    expect(
      redirectionAdmin(
        const AdminConnecte('a'),
        u('/connexion?retour=https://ailleurs.example'),
      ),
      CheminsAdmin.tableauDeBord,
    );
    expect(redirectionAdmin(const AdminConnecte('a'), u('/carte')), isNull);
  });
}
