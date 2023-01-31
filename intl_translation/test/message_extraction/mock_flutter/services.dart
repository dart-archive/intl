import 'dart:async';
import 'dart:convert';

import 'foo_messages_de_DE.dart' as de_de;
import 'foo_messages_fr.dart' as fr;

// Mocks the Flutter interfaces used in the generated messages_flutter.dart.
class SystemChannels {
  static const MethodChannel localization = MethodChannel();
}

class MethodChannel {
  const MethodChannel();

  Future<String?> invokeMethod(String method, [dynamic arguments]) async {
    var locale = arguments['locale'];
    if (locale == null) {
      return null;
    }

    // We only have two locales in the test.
    if (locale == 'fr') {
      return jsonEncode(fr.MessageLookup().messages);
    } else if (locale == 'de_DE') {
      return jsonEncode(de_de.MessageLookup().messages);
    }
    return null;
  }
}

class AssetBundle {
  Future<String?> loadString(String key, {bool cache = true}) async {
    // We only have two locales in the test.
    if (key.contains('fr')) {
      return jsonEncode(fr.MessageLookup().messages);
    } else if (key.contains('de-DE')) {
      return jsonEncode(de_de.MessageLookup().messages);
    }
    return null;
  }
}

final AssetBundle rootBundle = AssetBundle();
