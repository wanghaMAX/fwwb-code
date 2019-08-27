import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Painter extends CustomPainter {
  ui.Image info;
  dynamic anno;
  String mode;

  Painter(ui.Image info, dynamic anno, String mode)
      : info = info,
        mode = mode,
        anno = anno;

  @override
  void paint(Canvas canvas, Size size) {
    double centerShift_x = 0;
    double centerShift_y = 0;

    if (info != null) {
      final hRatio = size.width / info.width;
      final vRatio = size.height / info.height;
      final ratio = hRatio < vRatio ? hRatio : vRatio;
      centerShift_x = (size.width - info.width * ratio) / 2 / ratio;
      centerShift_y = (size.height - info.height * ratio) / 2 / ratio;

      canvas.scale(ratio);
      canvas.drawImage(info, Offset(centerShift_x, centerShift_y), new Paint());
    }

    if (anno != null) {
      switch (mode) {
        case "translate":
          final text = anno['text_annotations'];
          final full = <dynamic>[];
          final single = <dynamic>[];

          for (var para in text) {
            if (para['locale'] != null) {
              full.add(para);
            } else {
              single.add(para);
            }
          }

          for (var p in full) {
            final texts = p['description'].split('\n');

            for (var para in texts) {
              dynamic x0;
              dynamic x2;

              if (para == null || para.length == 0) {
                continue;
              }

              for (var c in single) {
                if (c['description'] != null &&
                    c['description'][0] == para[0]) {
                  x0 = c['bounding_poly']['vertices'][0];
                  x2 = c['bounding_poly']['vertices'][2];
                }
              }

              if (x0 == null) {
                continue;
              }

              final x0x = x0['x'] == null ? 0 : x0['x'].toDouble();
              final x0y = x0['y'] == null ? 0 : x0['y'].toDouble();
              final x2x = x2['x'] == null ? 0 : x2['x'].toDouble();
              final x2y = x2['y'] == null ? 0 : x2['y'].toDouble();

              TextSpan span = new TextSpan(
                  style: new TextStyle(
                      color: Color(0xffffffff),
                      fontSize: (x2y - x0y) < (x2x - x0x)
                          ? (x2y - x0y)
                          : (x2x - x0x)),
                  text: para);
              TextPainter tp = new TextPainter(
                  text: span,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr);
              tp.layout();
              tp.paint(
                  canvas, Offset(centerShift_x + x0x, centerShift_y + x0y));
            }
          }
          break;
        case "ocr":
          final text = anno['text_annotations'];
          for (var p in text) {
            if (p['locale'] != null) {
              continue;
            }

            final x0 = p['bounding_poly']['vertices'][0];
            final x2 = p['bounding_poly']['vertices'][2];
            final x0x = x0['x'] == null ? 0 : x0['x'].toDouble();
            final x0y = x0['y'] == null ? 0 : x0['y'].toDouble();
            final x2x = x2['x'] == null ? 0 : x2['x'].toDouble();
            final x2y = x2['y'] == null ? 0 : x2['y'].toDouble();

            TextSpan span = new TextSpan(
                style: new TextStyle(
										color: Color(0xffffffff),
                    fontSize:
                        (x2y - x0y) < (x2x - x0x) ? (x2y - x0y) : (x2x - x0x)),
                text: p['description']);
            TextPainter tp = new TextPainter(
                text: span,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr);
            tp.layout();
            tp.paint(canvas, Offset(centerShift_x + x0x, centerShift_y + x0y));
          }
          break;
        default:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) => false;
}

class TranslatePage extends StatefulWidget {
  String imagepath = "";

  TranslatePage({Key key, String imagepath})
      : imagepath = imagepath,
        super(key: key);

  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  ui.Image imageinfo = null;
  dynamic imageanno = null;
  String mode = "translate";

  @override
  void initState() {
    super.initState();
    loadImage();
    loadAnno();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadImage() async {
    ui
        .instantiateImageCodec(File(widget.imagepath).readAsBytesSync())
        .then((ui.Codec codec) {
      codec.getNextFrame().then((info) {
        setState(() {
          if (!mounted) {
            return;
          }

          imageinfo = info.image;
        });
      });
    });
  }

  void loadAnno() async {
		final dio = new Dio();

    Directory tempDir = await getApplicationDocumentsDirectory();
    final jar = new PersistCookieJar(dir: tempDir.path);
    dio.interceptors.add(new CookieManager(jar));

    final filebytes = File(widget.imagepath).readAsBytesSync();
    final filesum = sha256.convert(filebytes).toString();

    final res3 = await dio.post("http://111.230.196.202:8085/image",
        data: {"format": "jpg", "image": base64.encode(filebytes)});
    debugPrint('${res3}');

    final res4 = await dio.post("http://111.230.196.202:8085/camera",
        data: {"mode": "text label", "image": filesum});

    final res4json = jsonDecode(res4.data);

    setState(() {
      if (!mounted) {
        return;
      }

      imageanno = res4json["data"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          decoration: BoxDecoration(color: Colors.black87),
          child: Center(
            child: imageinfo != null && imageanno != null
                ? CustomPaint(
                    painter: Painter(imageinfo, imageanno, mode),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                  )
                : Container(
                    width: 20.0,
                    height: 20.0,
                    child: const CircularProgressIndicator(),
                  ),
          ),
        );
      }),
      bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CupertinoButton(
              child: Text('ocr'),
              borderRadius: BorderRadius.circular(0.0),
              padding: EdgeInsets.all(0.0),
              onPressed: () {
                setState(() {
                  mode = mode == 'ocr' ? "default" : "ocr";
                });
              },
            ),
            CupertinoButton(
              child: Text('translate'),
              borderRadius: BorderRadius.circular(0.0),
              padding: EdgeInsets.all(0.0),
              onPressed: () {
                setState(() {
                  mode = mode == 'translate' ? "default" : "translate";
                });
              },
            ),
          ]),
    );
  }
}
