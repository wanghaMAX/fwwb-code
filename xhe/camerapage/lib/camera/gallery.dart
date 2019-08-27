import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'translate.dart';

bool scoreup(dynamic elem) {
	return elem != null && elem['score'] < 0.5;
}

int compareup(dynamic a, b) {
	return ((b['score'] - a['score'])*100).toInt();
}

CupertinoActionSheet popup(
    BuildContext context, dynamic imgpath, dynamic imgstat) {
  return CupertinoActionSheet(
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text('detail'),
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => Scaffold(
                        appBar: CupertinoNavigationBar(),
                        body: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.sd_card),
                                    title: Text('path'),
                                    subtitle:
                                        imgpath == null ? null : Text(imgpath),
                                  ),
                                  ListTile(
                                    title: Text('size'),
                                    subtitle: Text(imgstat.size.toString()),
                                  ),
                                  ListTile(
                                    title: Text('accessed'),
                                    subtitle: Text(imgstat.accessed.toString()),
                                  ),
                                  ListTile(
                                    title: Text('modified'),
                                    subtitle: Text(imgstat.modified.toString()),
                                  ),
                                ]))))).then((_) {
              Navigator.pop(context);
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('rename'),
          onPressed: () {
            showCupertinoModalPopup<CupertinoAlertDialog>(
                context: context,
                builder: (context) {
                  final ctrl = TextEditingController(text: basename(imgpath));
                  return CupertinoAlertDialog(
                    content: CupertinoTextField(controller: ctrl),
                    actions: <Widget>[
                      CupertinoButton(
                        child: Text('cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoButton(
                          child: Text('ok'),
                          onPressed: () {
                            File(imgpath)
                                .renameSync(dirname(imgpath) + '/' + ctrl.text);
                            Navigator.pop(context);
                          }),
                    ],
                  );
                }).then((_) {
              Navigator.pop(context);
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('share'),
          onPressed: () async {
						final dio = new Dio();

						Directory tempDir = await getApplicationDocumentsDirectory();
						final jar = new PersistCookieJar(dir: tempDir.path);
						dio.interceptors.add(new CookieManager(jar));

						final filebytes = File(imgpath).readAsBytesSync();
						final filesum = sha256.convert(filebytes).toString();

						final res3 = await dio.post("http://111.230.196.202:8085/image", data: {"format": "jpg", "image": base64.encode(filebytes)});

            Share.share('http://111.230.196.202:8085/' + filesum[0] + '/' + filesum[1] + '/' + filesum + '.jpg');

						Navigator.pop(context);
          },
        )
      ]);
}

class GalleryPage extends StatefulWidget {
  Directory dir = null;

  GalleryPage({Key key, String dir})
      : dir = Directory(dir),
        super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<FileSystemEntity> imgs = null;
  int curidx = 0;
	bool loadingRec = false;

  @override
  void initState() {
    super.initState();
    loadImgs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadImgs() {
		final dir = widget.dir;

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final ximgs = dir.listSync();

    ximgs.removeWhere(
        (item) => item.statSync().type != FileSystemEntityType.file);

    ximgs
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    setState(() {
      if (!mounted) {
        return;
      }

      imgs = ximgs;
    });
  }

  @override
  Widget build(BuildContext context) {
    loadImgs();
    curidx = curidx < imgs.length ? curidx : imgs.length - 1;

    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text(imgs.length > 0 ? basename(imgs[curidx].path) : ""),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.black87),
          child: PhotoViewGallery(
            pageOptions: List<PhotoViewGalleryPageOptions>.generate(imgs.length,
                (int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider:
                    MemoryImage(File(imgs[index].path).readAsBytesSync()),
              );
            }),
            backgroundDecoration: BoxDecoration(color: Colors.black87),
            onPageChanged: (int index) {
              setState(() {
                if (!mounted) {
                  return;
                }

                curidx = index;
              });
            },
            loadingChild: Container(
              decoration: BoxDecoration(color: Colors.black87),
              child: Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CupertinoButton(
                child: Icon(Icons.textsms, size: 24.0),
                borderRadius: BorderRadius.circular(0.0),
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  print('wait to implement');
                },
              ),
              CupertinoButton(
                child: loadingRec ? SizedBox(width: 24, height: 24, child:CircularProgressIndicator()) : Icon(Icons.info_outline, size: 24.0),
                borderRadius: BorderRadius.circular(0.0),
                padding: EdgeInsets.all(0.0),
                onPressed: () async {
                  if (imgs.length == 0 || loadingRec) return;

									setState(() {
										loadingRec = true;
									});

									final dio = new Dio();

									Directory appDir = await getApplicationDocumentsDirectory();
									final jar = new PersistCookieJar(dir: appDir.path);
									dio.interceptors.add(new CookieManager(jar));

									final filebytes = File(imgs[curidx].absolute.path).readAsBytesSync();
									final filesum = sha256.convert(filebytes).toString();

									final res3 = await dio.post("http://111.230.196.202:8085/image",
											data: {"format": "jpg", "image": base64.encode(filebytes)});

										final res4 = await dio.post("http://111.230.196.202:8085/camera",
												data: {"mode": "web", "image": filesum});

										final res4json = jsonDecode(res4.data);

										final webent = res4json['data']['web_detection']['web_entities'];
										webent.removeWhere((elem) => scoreup(elem) || elem['description'] == null);
										webent.sort(compareup);

										setState(() {
											loadingRec = false;
										});

										showCupertinoModalPopup<CupertinoAlertDialog>(
												context: context,
												builder: (context) {
													return CupertinoAlertDialog(
															content: Column(children: List<Widget>.generate(webent.length, (int index) {
																final textToCopy = (webent[index]['score']*100).toInt().toString() + '% ' + webent[index]['description'];
																return new GestureDetector(
																		child: new Text(textToCopy,
																				textAlign: TextAlign.left,
																				style: TextStyle(fontWeight: FontWeight.bold)),
																		onLongPress: () {
																			Clipboard.setData(new ClipboardData(text: textToCopy));
																			Navigator.pop(context);
																		},
																);
															})),
															actions: <Widget>[
																CupertinoButton(
																		child: Text('tap to copy'),
																		onPressed: () {
																			Navigator.pop(context);
																		}),
															]);
									});
								},
              ),
              CupertinoButton(
                child: Icon(Icons.translate),
                borderRadius: BorderRadius.circular(0.0),
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  if (imgs.length == 0) return;

                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => TranslatePage(
                              imagepath: imgs[curidx].absolute.path)));
                },
              ),
              CupertinoButton(
                child: Icon(Icons.transform),
                borderRadius: BorderRadius.circular(0.0),
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  if (imgs.length == 0) return;

                  final file = imgs[curidx];

                  ImageCropper.cropImage(
                    sourcePath: file.path,
                  ).then((File cropfile) {
                    if (cropfile == null) {
                      return;
                    }

                    cropfile.renameSync(file.path);

                    setState(() {});
                  });
                },
              ),
              CupertinoButton(
                child: Icon(Icons.delete),
                borderRadius: BorderRadius.circular(0.0),
                padding: EdgeInsets.all(0.0),
                onPressed: () {
                  if (imgs.length == 0) return;

                  final file = imgs[curidx];

                  imgs.removeAt(curidx);
                  file.deleteSync();

                  setState(() {});
                },
              ),
              CupertinoButton(
                  child: Icon(Icons.more_horiz),
                  borderRadius: BorderRadius.circular(0.0),
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    if (imgs.length == 0) return;

                    final img = imgs[curidx];
                    final imgstat = img.statSync();
                    final imgpath = imgs[curidx].path;

                    showCupertinoModalPopup<CupertinoActionSheet>(
                        context: context,
                        builder: (context) => popup(context, imgpath, imgstat));
                  })
            ]));
  }
}
