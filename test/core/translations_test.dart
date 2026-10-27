// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

Set<String> _keys(Map<String, dynamic> json, [String prefix = '']) => {
  for (final MapEntry(:key, :value) in json.entries)
    if (value is Map<String, dynamic>)
      ..._keys(value, '$prefix$key.')
    else
      '$prefix$key',
};

Set<String> _keysOf(String locale) => _keys(
  jsonDecode(File('assets/translations/$locale.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  test('English and French define the same keys', () {
    expect(_keysOf('en'), _keysOf('fr'));
  });
}
