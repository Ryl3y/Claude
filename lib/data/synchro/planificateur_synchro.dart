import 'dart:async';

import 'synchro_service.dart';

/// Lance la synchronisation au bon moment : au démarrage, quand le réseau
/// revient, toutes les [intervalle], et peu après un changement local.
/// Un échec n'arrête rien : on réessaie au passage suivant.
class PlanificateurSynchro {
  PlanificateurSynchro(
    this._synchro, {
    required Stream<bool> reseauDisponible,
    this.intervalle = const Duration(minutes: 5),
    this.delaiApresChangement = const Duration(seconds: 30),
  }) : _reseau = reseauDisponible;

  final SynchroService _synchro;
  final Stream<bool> _reseau;
  final Duration intervalle;
  final Duration delaiApresChangement;

  final _bilans = StreamController<BilanSynchro>.broadcast();
  Timer? _minuterie;
  Timer? _bientot;
  StreamSubscription<bool>? _abonnementReseau;
  StreamSubscription<int>? _abonnementAttente;
  BilanSynchro? _dernier;

  /// Résultat de chaque passage.
  Stream<BilanSynchro> get bilans => _bilans.stream;

  BilanSynchro? get dernierBilan => _dernier;

  void demarrer() {
    _minuterie ??= Timer.periodic(intervalle, (_) => lancer());
    _abonnementReseau ??= _reseau.listen((disponible) {
      if (disponible) lancer();
    });
    _abonnementAttente ??= _synchro.surveillerEnAttente().listen((n) {
      // Un changement local : on l'envoie bientôt, sans attendre la minuterie.
      if (n > 0) _bientot ??= Timer(delaiApresChangement, lancer);
    });
    lancer();
  }

  Future<BilanSynchro> lancer() async {
    _bientot?.cancel();
    _bientot = null;
    final bilan = await _synchro.synchroniser();
    _dernier = bilan;
    if (!_bilans.isClosed) _bilans.add(bilan);
    return bilan;
  }

  Future<void> arreter() async {
    _minuterie?.cancel();
    _bientot?.cancel();
    _minuterie = null;
    _bientot = null;
    await _abonnementReseau?.cancel();
    await _abonnementAttente?.cancel();
    _abonnementReseau = null;
    _abonnementAttente = null;
    await _bilans.close();
  }
}
