import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/reviews.dart';
import 'package:zhuishu/ui/base/const.dart';

/*
* text 相关封装
* */
class TextUtil {
  /*
  * 带圆角边框的文本
  * */
  static Widget buildBorder(
    String str, {
    color = Colors.grey,
    double fontSize = 10.0,
    FontWeight fontWeight,
    double vertical = 4.0,
    double horizontal = 4.0,
    borderRadius = 12.0,
    Color background,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      decoration: BoxDecoration(
          border:
              background == null ? Border.all(color: Color(0x1F000000)) : null,
          color: background,
          borderRadius: BorderRadius.circular(borderRadius)),
      child:
          build(str, color: color, fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  /*
  * 默认修改字体大小和颜色
  * */
  static Text build(
    String str, {
    Color color = Colors.grey,
    double fontSize = 14.0,
    FontWeight fontWeight,
    int maxLines,
    bool softWrap,
    double height,
    TextAlign textAlign,
  }) {
    return Text(
      str,
      softWrap: softWrap,
      maxLines: maxLines,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
    );
  }

  /*
  * 设置超出部分
  * */
  static Text buildOverFlow(
    String str, {
    int maxLines = 1,
    overflow = TextOverflow.ellipsis,
    Color color = Colors.grey,
    double fontSize = 14.0,
    FontWeight fontWeight,
  }) {
    return Text(
      str,
      maxLines: maxLines,
      overflow: overflow, //超出部分以省略号结尾
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }

  /*
  * 全部处理
  * */

  static Widget buildAll(String content, {
    Color color = Colors.grey,
    Color clickColor = Colors.red,
    double fontSize = 14.0,
    FontWeight fontWeight,
    @required void Function(String type, String value) onValue,
  }){
    if(content==null||content.isEmpty) return SizedBox.shrink();
    //图片
    RegExp regExp = RegExp("\\{\\{(.*?)\\}\\}");
    return Column(
      children: split(content, regExp).map((String s){
        if(s.startsWith("{{")){
          //去头去尾转json格式
          ReviewImageInfo imgInfo = ReviewImageInfo.fromString(s.substring(2,s.length-2));
          return Image.network(imgInfo.url);
        }else {
          return buildClick(s, onValue: onValue);
        }
      }).toList(),
    );
  }
  /*
  * 以书名号里的可以点击
  * */
  static Widget buildClick(String content, {
    Color color = Colors.grey,
    Color clickColor = Colors.red,
    double fontSize = 14.0,
    FontWeight fontWeight,
    @required void Function(String type, String value) onValue,
  }){
    List<String> str = [];
    //另一篇书评讨论
    RegExp regExp = RegExp("\\[\\[(.*?)\\]\\]");
    //书本
    RegExp regExp2 = RegExp("《(.*?)》");
    split(content, regExp).forEach((String s){
      if(s.startsWith("[[")){
        print("=============$s");
        str.add(s);
      }else{
        str.addAll(split(s, regExp2));
      }
    });
    return str.length==1? build(content,fontSize: fontSize,color: color, fontWeight: fontWeight): RichText(
      text: TextSpan(
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        children: str.map((String s){
          if(s.startsWith("《")){
           return TextSpan(
             text: s,
             style: TextStyle(color: clickColor),
             recognizer: TapGestureRecognizer()..onTap = (){
               onValue("tag", s.substring(1,s.length-1));
             },
           );
          }else if(s.startsWith("[[")){
            List<String> l= s.split(" ");
            if(l.length > 1&&l[1].isNotEmpty){
              return TextSpan(
                text: l[1].substring(0,l[1].length-2),
                style: TextStyle(color: clickColor),
                recognizer: TapGestureRecognizer()..onTap = (){
                  onValue("url",l[0].substring(2));
                },
              );
            }
          }
          return TextSpan(
              text: s,
          );
        }).toList(),
      ),
    );
  }

  static Text buildRandomText(){
    String str = poetryList[Random().nextInt(poetryList.length)];
    return build(str,fontSize: 12);
  }

  static List<String> split(String content,RegExp regExp){
    if(content.contains(regExp)){
      List<String> str = [];
      int end = 0;
      regExp.allMatches(content).forEach((match){
        if(match.start > end) {
          str.add(content.substring(end,match.start));
        }
        str.add(content.substring(match.start,match.end));
        end = match.end;
      });
      if(end < content.length){
        str.add(content.substring(end,content.length));
      }
      return str;
    }else{
      return [content];
    }
  }

}
