/// Essais du code PIN : 5 essais libres, puis une attente qui double à
/// chaque erreur (30 s, 1 min, 2 min…), 15 minutes au plus.
abstract final class EssaisPin {
  static const essaisLibres = 5;
  static const premiereAttente = Duration(seconds: 30);
  static const attenteMax = Duration(minutes: 15);

  /// Attente imposée après [echecs] erreurs d'affilée.
  static Duration attenteApres(int echecs) {
    if (echecs < essaisLibres) return Duration.zero;
    final doublements = (echecs - essaisLibres).clamp(0, 10);
    final attente = premiereAttente * (1 << doublements);
    return attente > attenteMax ? attenteMax : attente;
  }

  /// Essais encore libres avant la première attente.
  static int restants(int echecs) =>
      echecs >= essaisLibres ? 0 : essaisLibres - echecs;
}
