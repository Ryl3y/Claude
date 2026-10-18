import 'package:uuid/uuid.dart';

/// Identifiants générés sur le téléphone (UUID v4),
/// pour créer des données hors ligne sans conflit.
abstract final class Identifiant {
  static const _uuid = Uuid();

  static String nouveau() => _uuid.v4();
}
