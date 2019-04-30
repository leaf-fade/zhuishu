library font_social_flutter;

import 'package:flutter/widgets.dart';

class MyIcon {
  static const IconData pen = const _MyIconData(0xe6f5);
  static const IconData book = const _MyIconData(0xe6c5);
  static const IconData sun = const _MyIconData(0xe602);
  static const IconData found = const _MyIconData(0xe60d);
  static const IconData message = const _MyIconData(0xe640);
  static const IconData star = const _MyIconData(0xe612);
  static const IconData moon = const _MyIconData(0xe639);

  static const IconData list = const _MyIconData(0xe743);
  static const IconData menu = const _MyIconData(0xe623);
  static const IconData change = const _MyIconData(0xe75e);
  static const IconData me = const _MyIconData(0xe605);
  static const IconData rank = const _MyIconData(0xe600);

  static const IconData minSpace = const _MyIconData(0xe6c7);
  static const IconData midSpace = const _MyIconData(0xe6c8);
  static const IconData maxSpace = const _MyIconData(0xe6c6);
}

class _MyIconData extends IconData {
  const _MyIconData(int codePoint)
      : super(
    codePoint,
    fontFamily: 'MyIcon',
    fontPackage: 'my_icon',
  );
}