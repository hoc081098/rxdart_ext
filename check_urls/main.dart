import 'dart:io';

import 'package:http/http.dart' as http;

void main() async {
  final text = File('../README.md').readAsStringSync();
  print('[START] text.length=${text.length}');

  final regex = RegExp(
      r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])');
  final ok = await test(
      regex.allMatches(text).map((m) => m.group(0)).whereType<String>());

  print('[DONE] $ok');
  if (!ok) {
    exit(1);
  }
}

Future<bool> testUrl(Uri url) async {
  print(' >> [Test] $url');

  bool success;
  try {
    final response = await http.get(url);
    success = response.statusCode == 200;
  } catch (e, s) {
    print('$e $s');
    success = false;
  }

  print(' << [Done] $success $url');
  return success;
}

Future<bool> test(Iterable<String> urls) {
  return Stream.fromIterable(urls)
      .map(Uri.parse)
      .asyncMap(testUrl)
      .every((b) => b);
}
