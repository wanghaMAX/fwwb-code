import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

Future publishLogin() async {
  Directory tempDir = await getTemporaryDirectory();
  final dio = new Dio();
  final jar = new PersistCookieJar(dir: tempDir.path);
  dio.interceptors.add(new CookieManager(jar));
  jar.deleteAll();

  final res1 = await dio.get("http://111.230.196.202:8085/login");

  final json = jsonDecode(res1.data);
  final salt = json['data']['salt'];
  final cookies = jar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login'));

  String passwd;
  for (var cookie in cookies) {
    if (cookie.name == 'sessionid') {
      // cd2e... is precalculated passwd
      passwd = salt + sha256.convert(utf8.encode("123456")).toString()+ cookie.value;
    }
  }
  print('${res1}');


  final correctpasswd = sha256.convert(utf8.encode(passwd)).toString();
  final res2 = await dio.post("http://111.230.196.202:8085/login", data: {"name": "testuser2", "passwd": correctpasswd});
  print('${res2}');

  jar.saveFromResponse(Uri.parse('http://111.230.196.202:8085'), jar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login')));

  return dio;
}