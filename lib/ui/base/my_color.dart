import 'package:flutter/material.dart';

class MyColor {
  static const Color primary = Colors.red;
  static const Color paper = Color(0xFFF5F5F5);
  static const Color divider = Color(0xffeeeeee);
  static const Color orange = Color(0xFFFFD180);

  static Map<String, Color> bgMap = {
    "white": Color(0xffffffff),
    "old": Color(0xffe7dcbe),
    "green": Color(0xff66f9cf),
    "pink": Color(0xffffe5e6),
    "night": Color(0xff333232),
  };

  static List<String> bgImgList = List.generate(5, (index)=>"images/read_bg_$index.png");

  //主题列表 0为默认模式，1为夜间，
  static List<Color> themeList = [primary, Color(0xff333232),];

  //渐变色
  static LinearGradient getGradient() {
    return LinearGradient(
      colors: [
        Color(0xFFFFD180),
        Color(0xFFFFE290),
        Color(0xFFFFF8F0),
        Color(0xFFFFFFFF),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
