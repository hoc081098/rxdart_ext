import 'dart:io';

import 'package:http/http.dart' as http;

void main() async {
  final text = File('README.md').readAsStringSync();
  print('[START] text.length=${text.length}');

  final regex = RegExp(
      r'(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])');
  final invalidUrls = await test(
      regex.allMatches(text).map((m) => m.group(0)).whereType<String>());

  print('[DONE] ${invalidUrls.isEmpty}');
  if (invalidUrls.isNotEmpty) {
    print('\n ------------ INVALID URLS ------------');
    print(invalidUrls.join('\n'));
    exit(1);
  } else {
    print('\n ------------ ALL URLS ARE VALID ------------');
  }
}

Future<bool> testUrl(Uri url) async {
  print(' >> [TEST] $url');

  bool success;
  try {
    final response = await http.get(url);
    success = response.statusCode == 200;
  } catch (e, s) {
    print(' << [TEST ERROR]$e $s');
    success = false;
  }

  print(' << [TEST DONE] $success $url');
  return success;
}

Future<List<Uri>> test(Iterable<String> urls) {
  return Stream.fromIterable(urls)
      .map(Uri.parse)
      .asyncMap((url) => testUrl(url).then((success) => success ? null : url))
      .where((url) => url != null)
      .cast<Uri>()
      .toList();
}
