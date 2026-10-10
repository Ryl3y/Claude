import 'package:flutter/widgets.dart';

/// Langue courante pour intl (« fr », « en »).
String langueDe(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();
