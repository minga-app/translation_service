import 'dart:io';

requestHandler(HttpRequest request) async {
  request.response.statusCode = 200;
  await request.response.close();
}
