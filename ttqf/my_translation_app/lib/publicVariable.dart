import 'dart:math';
import 'dart:convert';  // for the utf8.encode method and json decode
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PublicVar {
  @override
  PublicVar({this.sessionID, this.userAvatar, this.userNickName, this.userSignature, this.userSex, this.userBirthday, this.userCity, this.userMail, this.userPhone, this.lineHeightMultiply});
  String sessionID;
  String userAvatar = 'http://backupserver.tencent.ttqf.tech/useravatar/20180908%20%E5%A4%B4%E5%83%8F.JPG';
  String userNickName = '前端滔滔清风';
  String userSignature = "这家伙很懒，什么都没有开发";
  String userSex = '男';
  String userBirthday = '2000-00-00';
  String userCity = '不存在市';
  String userMail = 'pacteradxteam@gmail.com';
  String userPhone = 'pacteradx0411';
  // 实际渲染像素高度与字体大小的比值
  double lineHeightMultiply = 1.0;
}


/// 补充前置和后置零
String prefixZero(Object numberORstring, int digits) {
  String output = "";
  num number = (numberORstring is String) ? num.parse(numberORstring) : numberORstring;
  for (int i = 1; i < digits; i++) {
    if (number / pow(10, i) < 1) {
      output += "0";
    }
  }
  output += number.toString();
  return output;
}

String suffixZero(Object numberORstring, int digits) {
  String output = "";
  num number = (numberORstring is String) ? num.parse(numberORstring) : numberORstring;
  if (number * pow(10, 1) % 10 == 0) {
    output += ".0";
  }
  for (int i = 1; i < digits; i++) {
    if (number * pow(10, i + 1) % 10 == 0) {
      output += "0";
    }
  }
  output = number.toString() + output;
  return output;
}


/// 自定义输入框弹窗
/// 接收参数：标题、默认输入框文本、限制输入长度、是否使用大输入框、输入文本类型、帮助文本、选择确认时的回调、选择取消时的回调
/// 输入框消失时返回输入文本
class TextEditingDialog extends StatefulWidget {

  final String title;
  final String content;
  final int contentMaxLength;
  final bool contentUseBigTextfield;
  final String helperText;
  final TextInputType textInputType;
  final Function(String content) onOKCallBack;
  final Function(String content) onCancelCallBack;
  TextEditingDialog(this.title, this.content, this.contentMaxLength, this.contentUseBigTextfield, this.textInputType, this.helperText, {this.onOKCallBack, this.onCancelCallBack, Key key}) : super(key: key);

  @override
  TextEditingDialogState createState() => new TextEditingDialogState(title, content, contentMaxLength, contentUseBigTextfield, textInputType, helperText, onOKCallBack, onCancelCallBack);
}

class TextEditingDialogState extends State<TextEditingDialog> {

  final String title;
        String content;
  final int contentMaxLength;
  final bool contentUseBigTextfield;
  final TextInputType textInputType;
  final String helperText;
  final Function(String content) onOKCallBack;
  final Function(String content) onCancelCallBack;
  // 初始化预设文字
  TextEditingDialogState(this.title, this.content, this.contentMaxLength, this.contentUseBigTextfield, this.textInputType, this.helperText, this.onOKCallBack, this.onCancelCallBack) {
    contentController.text = content;
    contentLength = content.length;
  }

  TextEditingController contentController = TextEditingController();
  int contentLength = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: <Widget>[
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Container(    // 文本框
            width: 540,
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                helperText: helperText,
                counterText: contentLength.toString(),
                border: contentUseBigTextfield ? OutlineInputBorder() : UnderlineInputBorder()
              ),
              maxLength: contentMaxLength,
              maxLines: contentUseBigTextfield ? 4 : 1,
              keyboardType: textInputType,
              onChanged: (String text){
                content = text;
                setState(() {
                  contentLength = content.length;
                });
              },
            ),
          ),
          SizedBox(height: 8),
          Column(       // 按钮
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Color.fromARGB(255, 252, 201, 45),
                highlightColor: Color.fromARGB(127, 255, 217, 102),
                // splashColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(999))),
                child: Text('　　　　　　确认　　　　　　'),
                onPressed: (){
                  onOKCallBack != null ? onOKCallBack(content) : {};
                  Navigator.of(context).pop(content);
                },
              ),
              FlatButton(
                color: Colors.transparent,
                highlightColor: Color.fromARGB(127, 205, 220, 57),
                // splashColor: Colors.transparent,
                child: Text('　　取消　　'),
                onPressed: (){
                  onCancelCallBack != null ? onCancelCallBack(content) : {};
                  Navigator.of(context).pop(content);
                },
              ),
            ],
          )
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}


class HeadIcon extends StatelessWidget {
  final String url;
  final double diameter;
  final EdgeInsetsGeometry margin;
  HeadIcon(this.url, [this.diameter, this.margin]);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipOval(       // 头像
        child: new FadeInImage.assetNetwork(
          width: diameter,
          height: diameter,
          placeholder: "src/icons/navigation_tools.png",  // 把头像独立出来而不是放在 decorationImage 里是为了 placeholder
          fit: BoxFit.contain,
          image: url,
        ),
      ),
    );
  }
}


/// 限制字符串视觉长度（大致），返回删减后字符串
String limitStringLengthByAscii(String text, int asciiLength) {
  int currentStringLength = 1;
  int currentAsciiLength;
  do {
    if (currentStringLength >= text.length) { return text; }  // 未占满空间就已完整显示字符
    currentAsciiLength = utf8.encode(text.substring(0, currentStringLength)).length;
    if (currentAsciiLength > asciiLength) {                   // Ascii 长度超出，返回上次长度的字符串
      return text.substring(0, currentStringLength - 1);
    } else {                                                  // 没超出，字符串数量增加
      currentAsciiLength = currentAsciiLength;
      currentStringLength++;
    }
  } while (true);
}

/// 限制字符串视觉长度（根据 Text 的 Style），返回删减后字符串
String limitStringLengthByStyle(String text, int width, TextStyle style) {
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  int currentLength = 0;
  do {
    currentLength++;
    if (currentLength == text.length) { return text; }  // 未占满空间就已完整显示字符
    textPainter.text = TextSpan(
      text: text.substring(0, currentLength),
      style: style
    );
    textPainter.layout();
  } while (textPainter.width < width);
  return text.substring(0, currentLength - 1);
}


/// 根据指定行高获取适当行高倍率（废弃，没用）
double getHeightMutiplyByLineHeight(double lineHeight, TextStyle style) {
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: 'text',
    style: style
  );
  textPainter.layout();
  print('textPainter.height: '+ textPainter.height.toString());
  return lineHeight / textPainter.height;
}


/// 根据行像素高度和字体大小计算合适的行高倍率
double getHeightMutiply(double lineHeightInPixel, double fontSize, double lineHeightMultiply) {
  return lineHeightInPixel / (fontSize * lineHeightMultiply);
}


/// 经纬度与城市名之间的转换
String myLatLngToPlaceName(MyLatLng myLatLng) {
  return '已知城市';
}

class MyLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const MyLatLng(double latitude, double longitude)
      : assert(latitude != null),
        assert(longitude != null),
        latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;
  
}

String getFileNameSuffix(String fileName) {
  int currentPos = fileName.length - 1;
  while (currentPos > 0) {
    if (fileName[currentPos] == ".") {
      return fileName.substring(currentPos + 1);
    }
    currentPos--;
  }
  return null;
}