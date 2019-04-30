import 'package:flutter/material.dart';

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
              background == null ? Border.all(color: Color(0xffeeeeee)) : null,
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
}
