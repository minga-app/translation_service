import 'dart:io';

import 'package:gsheets/gsheets.dart';
import 'arb_serialization.dart';
import 'credentials.dart';

final PATH = '/Users/lukashimsel/Projects/minga-app/minga_app/lib/l10n';
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
    var keys = allColumns[0].sublist(1);
    for (var col in allColumns.sublist(1)) {
      var locale = col.first;
      var sub = col.sublist(1);
      var values = List.generate(
        keys.length,
        (index) => sub.length > index ? sub[index] : '',
      );
      var data = Map.fromIterables(keys, values);
      var serializer = ArbSerializer.parse(locale, data, context);
      await File('$PATH/intl_$locale.arb')
          .writeAsString(serializer.serialize());
    }
  }
  return;
}
