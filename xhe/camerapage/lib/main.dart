import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import 'camera/main.dart';

class MyApp extends StatefulWidget {            
	MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {            
	String imagedir;

	@override
	void initState() {
    getApplicationDocumentsDirectory().then((extDir) {
			setState(() {
				imagedir = extDir.path + "/Camera";
			});
		});
		loadDIO();
	}

	void loadDIO() async {
		final dio = new Dio();

    Directory tempDir = await getApplicationDocumentsDirectory();
    final jar = new PersistCookieJar(dir: tempDir.path);
    dio.interceptors.add(new CookieManager(jar));
    jar.deleteAll();

    final res1 = await dio.get("http://111.230.196.202:8085/login");

    final json = jsonDecode(res1.data);
    final salt = json['data']['salt'];
    final cookies =
        jar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login'));

    String passwd;
    for (var cookie in cookies) {
      if (cookie.name == 'sessionid') {
        // cd2e... is precalculated passwd
        passwd = salt +
            'cd2eb0837c9b4c962c22d2ff8b5441b7b45805887f051d39bf133b583baf6860' +
            cookie.value;
      }
    }

    final correctpasswd = sha256.convert(utf8.encode(passwd)).toString();
    final res2 = await dio.post("http://111.230.196.202:8085/login",
        data: {"name": "testuser", "passwd": correctpasswd});

    jar.saveFromResponse(Uri.parse('http://111.230.196.202:8085'),
        jar.loadForRequest(Uri.parse('http://111.230.196.202:8085/login')));
	}

	@override            
	Widget build(BuildContext context) {            
		if (imagedir != null) {
			return CameraPage(imagedir);
		} else {
			return Container();
		}
	}
}

class Start extends StatelessWidget {            
	Start({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
		return MaterialApp(
				title: 'Welcome to Flutter',            
				home: MyApp(),
		);
	}
}

void main() => runApp(Start());
