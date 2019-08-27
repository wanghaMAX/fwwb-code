import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'gallery.dart';

class CameraPage extends StatefulWidget {
  String imagedir;
  bool cropafter;

  CameraPage(String imagedir, {Key key, bool crop})
      : imagedir = imagedir,
        cropafter = crop == null ? false : crop,
        super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller = null;
  String imagePath = null;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void updateThubpath() {
		final dir = Directory(widget.imagedir);

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final imgst = dir.listSync();

    FileSystemEntity max;
    DateTime maxt;

    for (var v in imgst) {
      final t = v.statSync().modified;
      if (maxt == null || t.compareTo(maxt) > 0) {
        max = v;
        maxt = t;
      }
    }

    setState(() {
      if (!mounted) {
        return;
      }

      imagePath = max == null ? null : max.path;
    });
  }

  void loadCamera() async {
    availableCameras().then((cameras) {
      for (var camera in cameras) {
        if (camera.lensDirection != CameraLensDirection.front) {
          var ctrl = CameraController(camera, ResolutionPreset.high);
          ctrl.initialize().then((_) {
            if (!mounted) {
              return;
            }

            setState(() {
              if (!mounted) {
                return;
              }

              controller = ctrl;
            });
          });

          return;
        }
      }

      showDialog<CupertinoAlertDialog>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('no camera available'),
              content: Text('maybe you did not give permission'),
            ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    updateThubpath();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		if (controller == null) loadCamera();

    File image = imagePath == null ? null : File(imagePath);
    List<int> bytes =
        image == null || !image.existsSync() ? null : image.readAsBytesSync();

    return Scaffold(
      key: _scaffoldKey,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final child = controller == null
            ? Center(
                child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: const CircularProgressIndicator(),
              ))
            : Transform.scale(
                scale: controller.value.aspectRatio *
                    constraints.maxHeight /
                    constraints.maxWidth,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              );
        return Container(child: Center(child: child), decoration: BoxDecoration(color: Colors.black87));
      }),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.black87),
          child: SizedBox(
              height: 128.0,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: const Color(0xff122e29),
                          border: Border.all(
                            color: const Color(0xff122e29),
                            width: 2.0,
                          ),
                        ),
                        child: Ink(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        GalleryPage(dir: widget.imagedir)),
                              ).then((_) {
                                updateThubpath();
                              });
                            },
                            child: bytes == null ? null : Image.memory(bytes),
                          ),
                        ),
                      ),
                      width: constraints.maxWidth * 0.25,
                      height: constraints.maxHeight * 0.8,
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      iconSize: 48.0,
                      color: const Color(0xfff6f5ec),
                      tooltip: 'take a shot',
                      onPressed: takePicture,
                    ),
                    SizedBox(
                      child: null,
                      width: constraints.maxWidth * 0.25,
                      height: constraints.maxHeight * 0.8,
                    ),
                  ],
                );
              }))),
    );
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void takePicture() async {
    if (!controller.value.isInitialized) {
      loadCamera();
      showInSnackBar('loading camera');
      return;
    }

    if (controller.value.isTakingPicture) {
      showInSnackBar('Error: is taking picture.');
      return;
    }

    final dir = Directory(widget.imagedir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final filePath = widget.imagedir + '/' + DateTime.now().toString() + '.jpg';
    File file = File(filePath);

    try {
      if (file.existsSync()) {
        file.deleteSync();
      }

      await controller.takePicture(filePath);

      final filebytes = await FlutterImageCompress.compressWithFile(
        filePath,
        quality: 94,
        rotate: controller.description.sensorOrientation,
      );
      file.writeAsBytes(filebytes);

      if (widget.cropafter) {
        File cropfile = await ImageCropper.cropImage(
          sourcePath: filePath,
        );

        if (cropfile != null) {
          cropfile.renameSync(filePath);
        }
      }

      setState(() {
        if (!mounted) {
          return;
        }

        imagePath = filePath;
      });
    } on CameraException catch (e) {
			file.deleteSync();
			updateThubpath();
      showInSnackBar('Error: ${e.code}\n${e.description}');
      return;
    }
  }
}
