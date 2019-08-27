import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'publishLogin.dart';

Color thisPageColor = Color.fromARGB(255, 252, 223, 56);

var widthMedia;
var heightMedia;
List<Widget> publishList;
List imageGet = List();
var pickImage;
String titleSave = "";
List<Widget> tagsList;
int addTagsIndex = 1;
List<String> tagsSave = List();
double locationGetX;
double locationGetY;
Dio dio;
String coverPick = "";
String contentString = "";

Options dioOptions = Options(
  connectTimeout: 1500,
  sendTimeout: 1000,
  receiveTimeout: 1000,
);

postPublishImage() async {
  if (dio == null) {
    dio = await publishLogin();
  }
  if (dio != null) {
    Map<String, String> imageData;
    Response response;
    for (var image in imageGet) {
      try {
        imageData = {
          "format": image.toString().substring(
              image.toString().length - 4, image.toString().length - 1),
          "image": base64Encode(image.readAsBytesSync()).toString(),
        };
        response = await dio.post(
          "http://111.230.196.202:8085/image",
          data: imageData,
          options: dioOptions,
        );
        Map<String, dynamic> responseDataMap = jsonDecode(response.data);
        print(responseDataMap);
        print(response.data);
        if (responseDataMap['success'] != '200') {
          print("失败");
          return responseDataMap['error'];
        }
      } catch (e) {
        print(e);
      }
    }
    return "succeed";
  }
}

postPublishContent() async {
  if (dio == null) {
    dio = await publishLogin();
  }
  if (dio != null) {
    Map<String, dynamic> contentData;
    Response response;
    try {
      contentData = {
        "cover": coverPick,
        "title": titleSave,
        "content": contentString,
        "tags": tagsSave,
        "x": locationGetX,
        "y": locationGetY,
      };
      response = await dio.post(
        "http://111.230.196.202:8085/pushContent",
        data: contentData,
        options: dioOptions,
      );
      Map<String, dynamic> responseDataMap = jsonDecode(response.data);
      print(responseDataMap);
      print(response.data);
      return responseDataMap['error'];
    } catch (e) {
      print(e);
    }
  }
}

locationDataGet() async {
  Location location = Location();
  LocationData locationData;
  await location.requestService();
  locationData = await location.getLocation();
  if (locationData != null) {
    return locationData;
  }
}

getImage() async {
  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    return image;
  }
}

class PublishMainPage extends StatefulWidget {
  @override
  _PublishMainPageState createState() => _PublishMainPageState();
}

class _PublishMainPageState extends State<PublishMainPage> {
  final imageNumSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(
    '你最多只能添加30张图片。',
    style: TextStyle(fontSize: 20.0),
  ));

  final titleSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(
    '你必须填写标题。',
    style: TextStyle(fontSize: 20.0),
  ));

  final tagsSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),

      content: new Text(
    '你至少要添加一个标签。',
    style: TextStyle(fontSize: 20.0),
  ));

  final contentSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(
    '你的动态内容不能为空。',
    style: TextStyle(fontSize: 20.0),
  ));

  final imageFailedSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(
    '部分图片上传失败。',
    style: TextStyle(fontSize: 20.0),
  ));

  final succeedSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(
    '上传成功。',
    style: TextStyle(fontSize: 20.0),
  ));

  final failedSnackBar = new SnackBar(
      duration: Duration(milliseconds: 2000),
      content: new Text(
    '上传失败。',
    style: TextStyle(fontSize: 20.0),
  ));

  @override
  void initState() {
    super.initState();
    publishList = List<Widget>()
      ..add(TitleTextField())
      ..add(TagsGetWidget())
      ..add(CreateTextField());
  }

  @override
  Widget build(BuildContext context) {
    widthMedia = MediaQuery.of(context).size.width;
    heightMedia = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            backgroundColor: thisPageColor,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            centerTitle: true,
            title: Text('发表动态'),
            actions: <Widget>[
              Builder(builder: (BuildContext context) {
//                didChangeDependencies().inheritFromWidgetOfExactType();
                return FlatButton(
                  child: Text(
                    '发表',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                  onPressed: () {
                    int tagsNum = 0;
                    for (String tag in tagsSave) {
                      if (tag != "") {
                        tagsNum++;
                      }
                    }
                    coverPick = "";
                    for (var inputWidget in publishList.sublist(2)) {
                      if (inputWidget is CreateTextField) {
                        if (inputWidget.text != null) {
                          if (coverPick.length < 30) {
                            coverPick += inputWidget.text;
                            if (coverPick.length > 30) {
                              coverPick = coverPick.substring(0, 30);
                            }
                          }
                          print(8888888888888888888);
                          print(coverPick);
                          print(8888888888888888888);
                        }
                      }
                      if (inputWidget is CreateImageView) {
                        if (inputWidget.image != null) {
                          var image = inputWidget.image;
                          coverPick = "#[img](" +
                              sha256
                                  .convert(image.readAsBytesSync())
                                  .hashCode
                                  .toString() +
                              ")";
                          print("1111111111111111111111111111111");
                          print(coverPick);
                          print("1111111111111111111111111111111");
                          break;
                        }
                      }
                    }
                    contentString = '';
                    for (var inputWidget in publishList.sublist(2)) {
                      if (inputWidget is CreateTextField) {
                        if (inputWidget.text != null) {
                          contentString =
                              contentString + inputWidget.text + '\n';
                        }
                      }
                      if (inputWidget is CreateImageView) {
                        if (inputWidget.image != null) {
                          var image = inputWidget.image;
                          if (contentString.length >= 1) {
                            if (contentString.substring(
                                    contentString.length - 1,
                                    contentString.length) ==
                                '\n') {
                              contentString = contentString.substring(
                                  0, contentString.length - 1);
                            }
                          }
                          contentString = contentString +
                              "#[img](" +
                              sha256
                                  .convert(image.readAsBytesSync())
                                  .hashCode
                                  .toString() +
                              ")";
                        }
                      }
                    }
                    if (titleSave == '') {
                      Scaffold.of(context).showSnackBar(titleSnackBar);
                    } else if (tagsNum == 0) {
                      Scaffold.of(context).showSnackBar(tagsSnackBar);
                    } else if (contentString == '') {
                      Scaffold.of(context).showSnackBar(contentSnackBar);
                    } else {
                      print(imageGet);
                      print("3333333333333333333333333333333333");
                      print(contentString);
                      print("33333333333333333333333333333333333");
                      print(titleSave);
                      print(tagsSave);
                      var imagePushError;
                      var contentPushError;
                      var oldContext = context;
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
//                          didChangeDependencies();
                          return AlertDialog(
                            content: Padding(
                              padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '    我们必须获取你的位置信息以便你的发布能够被看到。',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Builder(builder: (BuildContext context) {
                                    didChangeDependencies();
                                    return RaisedButton(
                                      color: Color.fromARGB(255, 252, 201, 45),
                                      highlightColor:
                                          Color.fromARGB(127, 255, 217, 102),
                                      // splashColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(999))),
                                      child: Text(
                                        '　　　　　  确认　　  　　　',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      onPressed: () {
                                        didChangeDependencies();
                                        Navigator.of(context).pop();
                                        LocationData locationDataGot;
                                        setData() async {
                                          locationDataGot =
                                          await locationDataGet();
                                          locationGetX =
                                              locationDataGot.longitude;
                                          locationGetY =
                                              locationDataGot.latitude;
                                          imagePushError =
                                          await postPublishImage();
                                          contentPushError =
                                          await postPublishContent();
                                          print(contentPushError);
                                          print(imagePushError);

                                          if (imagePushError != null) {
                                            if(imagePushError != "succeed"){
                                              Scaffold.of(oldContext).showSnackBar(imagePushError);
                                            }
                                          }else{
                                            Scaffold.of(oldContext).showSnackBar(imagePushError);
                                          }
                                          print("66666666666666666666666666666");
                                          print(imagePushError);
                                          print("66666666666666666666666666");
                                          if (contentPushError != null) {
                                            if(contentPushError != ""){
                                              Scaffold.of(oldContext)
                                                  .showSnackBar(failedSnackBar);
                                            }else{
                                              Scaffold.of(oldContext).showSnackBar(succeedSnackBar);
                                            }
                                          }else{
                                            Scaffold.of(oldContext)
                                                .showSnackBar(failedSnackBar);
                                          }


                                          print("8888888888888888888888888888888");
                                          print(contentPushError);
                                          print("88888888888888888888888888888");

                                          print(locationDataGot.latitude);
                                          print(locationDataGot.longitude);
                                        }

                                        setData();
                                      },
                                    );
                                  }),
                                  FlatButton(
                                    color: Colors.transparent,
                                    highlightColor:
                                        Color.fromARGB(127, 205, 220, 57),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(999)),
                                    ),
                                    // splashColor: Colors.transparent,
                                    child: Text(
                                      '　　　　    取消　　　 　 　',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                                mainAxisSize: MainAxisSize.min,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(0),
                          );
                        },
                      );
                    }
                  },
                );
              }),
            ],
          ),
          preferredSize: Size.fromHeight(heightMedia * 0.07)),
      body: ListView(
        children: <Widget>[
          Center(
            child: Container(
              width: widthMedia - 29,
              height: heightMedia * 0.93,
              child: ListView(
                children: <Widget>[
                  Wrap(
                    children: publishList,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          elevation: 4.0,
          backgroundColor: thisPageColor,
          child: Container(
            width: 200.0,
            height: 200.0,
            child: Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: heightMedia * 0.07 * 0.68,
            ),
          ),
          onPressed: () {
            setImage() async {
              pickImage = await getImage();
              publishList.add(CreateImageView(pickImage));
              imageGet.add(pickImage);
              publishList.add(CreateTextField());
              pickImage = null;
              setState(() {});
            }

            print(imageGet.length);
            if (imageGet.length == 30) {
              Scaffold.of(context).showSnackBar(imageNumSnackBar);
              print(imageGet);
            } else {
              setImage();
            }
            setState(() {});
          },
        );
      }),
      resizeToAvoidBottomPadding: true,
    );
  }
}

// ignore: must_be_immutable
class CreateImageView extends StatefulWidget {
  var image;
  CreateImageView(this.image);
  @override
  _CreateImageViewState createState() => _CreateImageViewState();
}

class _CreateImageViewState extends State<CreateImageView> {
  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    if (widget.image != null) {
      return Stack(
        alignment: const FractionalOffset(1.0, 0.0),
        children: <Widget>[
          Container(
            child: Image.file(widget.image),
          ),
          Container(
            width: 40.0,
            height: 40.0,
            color: Colors.black38,
            child: IconButton(
              onPressed: () {
                publishList.remove(widget);
                imageGet.remove(widget.image);
                widget.image = null;
                setState(() {});
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

// ignore: must_be_immutable
class CreateTextField extends StatefulWidget {
  String text;
  @override
  _CreateTextFieldState createState() => _CreateTextFieldState();
}

class _CreateTextFieldState extends State<CreateTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        autofocus: true,
        textInputAction: TextInputAction.newline,
        maxLines: null,
        style: TextStyle(
          fontSize: 20.0,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "这里可以输入哦。",
        ),
        onChanged: (String value) {
          widget.text = value;
        });
  }
}

class TitleTextField extends StatefulWidget {
  @override
  _TitleTextFieldState createState() => _TitleTextFieldState();
}

class _TitleTextFieldState extends State<TitleTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      textInputAction: TextInputAction.done,
      maxLines: null,
      maxLength: 42,
      decoration: InputDecoration(
        counterText: ' ',
        hintText: '标题',
        border: UnderlineInputBorder(),
        contentPadding: EdgeInsets.fromLTRB(3, 12, 3, 8),
      ),
      style: TextStyle(color: Colors.black87, fontSize: 26),
      onChanged: (value) {
        titleSave = value;
      },
    );
  }
}

class TagsGetWidget extends StatefulWidget {
  @override
  _TagsGetWidgetState createState() => _TagsGetWidgetState();
}

class _TagsGetWidgetState extends State<TagsGetWidget> {
  final tagsNumSnackBar = new SnackBar(
      content: new Text(
    '你最多只能添加5个标签。',
    style: TextStyle(fontSize: 20.0),
  ));

  @override
  void initState() {
    addTagsIndex = 1;
    tagsList = List<Widget>();
    tagsList..insert(0, CreateTags())..insert(1, addTagsButton());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: tagsList,
    );
  }

  Widget addTagsButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: GestureDetector(
        onTapUp: (TapUpDetails details) {
          if (tagsSave.length < 5) {
            tagsList.insert(tagsList.length - 1, CreateTags());
            setState(() {});
          } else {
            Scaffold.of(context).showSnackBar(tagsNumSnackBar);
          }
          print(tagsList);
          print(tagsSave);
        },
        child: Container(
          width: 40.0,
          height: 40.0,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class CreateTags extends StatefulWidget {
  @override
  _CreateTagsState createState() => _CreateTagsState();
}

class _CreateTagsState extends State<CreateTags> {
  TextEditingController _titleTextController = TextEditingController();
  double containerWidth = 104;
  bool exit = true;
  int inputIndex;

  @override
  void initState() {
    tagsSave.add('.T');
    inputIndex = tagsSave.indexOf('.T');
    tagsSave[inputIndex] = '';
    super.initState();
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (exit) {
      return Container(
        width: containerWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: Container(
                width: containerWidth - 40,
                child: TextField(
                  controller: _titleTextController,
                  textInputAction: TextInputAction.done,
                  maxLength: 15,
                  autofocus: true,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '标签',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(25.0),
                      ),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(13.0, 8.0, 8.0, 4.0),
                  ),
                  style: TextStyle(color: Colors.black87, fontSize: 17.5),
                  onChanged: (value) {
                    tagsSave[inputIndex] = value;
                    final textPainter = TextPainter(
                      textDirection: TextDirection.ltr,
                      text: TextSpan(
                        text: _titleTextController.text,
                        style: TextStyle(fontSize: 17.8, color: Colors.black),
                      ),
                    );
                    textPainter.layout();
                    var textWidth = textPainter.width;
                    print(textWidth);
                    print(_titleTextController.text.length);
                    containerWidth = textWidth + 21 + 40;
                    setState(() {});
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
              child: GestureDetector(
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  child: Icon(Icons.close),
                ),
                onTapUp: (TapUpDetails details) {
                  tagsSave.remove(_titleTextController.text);
                  exit = false;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
