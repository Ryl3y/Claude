import '../core/heure_douala.dart';

/// Prix de Kassa Pro pour un mois, en FCFA (le serveur a le même).
const prixProFcfa = 5000;

/// Durée de l'essai gratuit offert à la création de la boutique.
const dureeEssaiJours = 30;

/// Où en est l'abonnement de la boutique. Les jours sont des dates de
/// Douala (sans heure) : l'essai ou Pro valent jusqu'à la fin de [fin].
sealed class EtatAbonnement {
  const EtatAbonnement(this.fin);

  /// Dernier jour inclus (date de Douala, marquée UTC à minuit).
  final DateTime fin;

  /// Vrai tant qu'on peut enregistrer (ventes, stock, dettes).
  bool get peutEcrire => this is! AbonnementTermine;

  /// Calcule l'état pour [aujourdhui] (date de Douala, voir [jourDouala]).
  static EtatAbonnement calculer({
    required String formule,
    required DateTime fin,
    required DateTime aujourdhui,
  }) {
    final jours = fin.difference(aujourdhui).inDays;
    if (jours < 0) return AbonnementTermine(fin, etaitPro: formule == 'pro');
    return formule == 'pro'
        ? AbonnementPro(fin)
        : AbonnementEssai(fin, joursRestants: jours);
  }

  /// La date de Douala d'un instant, à minuit (marquée UTC).
  static DateTime jourDouala(DateTime instant) {
    final d = HeureDouala.versDouala(instant);
    return DateTime.utc(d.year, d.month, d.day);
  }

  /// Fin de l'essai quand le serveur n'a pas encore répondu : 30 jours
  /// après la création de la boutique (comme le serveur).
  static DateTime finEssaiDepuis(DateTime creeLe) =>
      jourDouala(creeLe).add(const Duration(days: dureeEssaiJours));

  /// Lit une date « 2026-11-09 » du serveur ; null si illisible.
  static DateTime? lireDate(String? texte) {
    if (texte == null) return null;
    final d = DateTime.tryParse(texte);
    return d == null ? null : DateTime.utc(d.year, d.month, d.day);
  }

  /// Écrit une date au format du serveur (« 2026-11-09 »).
  static String ecrireDate(DateTime jour) =>
      '${jour.year.toString().padLeft(4, '0')}-'
      '${jour.month.toString().padLeft(2, '0')}-'
      '${jour.day.toString().padLeft(2, '0')}';
}

/// Essai gratuit en cours ; 0 jour restant = dernier jour.
class AbonnementEssai extends EtatAbonnement {
  const AbonnementEssai(super.fin, {required this.joursRestants});

  final int joursRestants;

  @override
  bool operator ==(Object other) =>
      other is AbonnementEssai &&
      other.fin == fin &&
      other.joursRestants == joursRestants;

  @override
  int get hashCode => Object.hash(fin, joursRestants);
}

class AbonnementPro extends EtatAbonnement {
  const AbonnementPro(super.fin);

  @override
  bool operator ==(Object other) => other is AbonnementPro && other.fin == fin;

  @override
  int get hashCode => fin.hashCode;
}

/// Essai ou Pro terminé : l'app reste en lecture seule.
class AbonnementTermine extends EtatAbonnement {
  const AbonnementTermine(super.fin, {required this.etaitPro});

  final bool etaitPro;

  @override
  bool operator ==(Object other) =>
      other is AbonnementTermine &&
      other.fin == fin &&
      other.etaitPro == etaitPro;

  @override
  int get hashCode => Object.hash(fin, etaitPro);
}
