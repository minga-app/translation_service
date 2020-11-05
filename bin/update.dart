import 'dart:io';

import 'package:gsheets/gsheets.dart';
import 'package:translation_service/arb_serialization.dart';
import 'package:translation_service/credentials.dart';
import 'package:translation_service/extract_messages.dart';

final PATH = './lib/l10n';

main() async {
  var sheets = GSheets(
    CREDENTIALS,
  );
  var doc =
      await sheets.spreadsheet('1honvi8nbgiYS0jk4hYbFDNa2i-yoNf0EMmSLhcgTTvo');
  var dir = Directory(PATH);
  if (!await dir.exists()) {
    await dir.create();
  }
  for (var sheet in doc.sheets) {
    var context = sheet.title;
    var allColumns = await sheet.values.allColumns();

    var sheetsKeys = allColumns[0].sublist(1);
    for (var col in allColumns.sublist(1)) {
      var locale = col.first;
      var sub = col.sublist(1);
      var values = List.generate(
        sheetsKeys.length,
        (index) => sub.length > index ? sub[index] : '',
      );
      var data = Map.fromIterables(sheetsKeys, values);
      var serializer = ArbSerializer.parse(locale, data, context);
      await File('$PATH/intl_$locale.arb')
          .writeAsString(serializer.serialize());

      var rowCount = sheet.rowCount;
      var messages = extractMessages('./lib/main.dart');
      for (var key in messages.keys) {
        if (sheetsKeys.contains(key)) {
          await sheet.insertRow(rowCount + 1);
          // insert new key here
        }
      }
    }
  }
  return;
}
