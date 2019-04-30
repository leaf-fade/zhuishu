import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/text.dart';

/*
* 设置菜单
* 夜间模式用eventBus来做
* */
//设置回调
typedef SettingCallback = void Function(
    double fontSize, double space, int imgIndex);

class SettingMenu extends StatelessWidget {
  final double font;
  final double space;
  final int imgIndex;
  final SettingCallback settingCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      color: Colors.transparent,
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: <Widget>[
            FontSettingWidget(
              font: font,
              onChoose: (double fontSize) {
                settingCallback(fontSize,-1,-1);
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: BackgroundSettingWidget(imgIndex: imgIndex,onChoose: (int imgIndex){
                settingCallback(-1,-1,imgIndex);
              },),
            ),
            SpaceSettingWidget(
              space: space,
              onChoose: (double space) {
                settingCallback(-1,space,-1);
              },
            ),
          ],
        ),
      ),
    );
  }

  SettingMenu(this.font, this.space, this.imgIndex, this.settingCallback);
}

//字体设置
class FontSettingWidget extends StatefulWidget {
  final void Function(double font) onChoose;
  final double font;

  @override
  _FontSettingWidgetState createState() => _FontSettingWidgetState();

  FontSettingWidget({this.font, this.onChoose});
}

class _FontSettingWidgetState extends State<FontSettingWidget> {
  Map<double, String> _fontList = {
    12: "一号",
    13: "二号",
    14: "三号",
    15: "四号",
    16: "五号",
    17: "六号",
    18: "七号",
    19: "八号",
    20: "九号",
    21: "十号",
  };
  double _font = 14;

  @override
  void initState() {
    _font = widget.font;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          OutlineButton(
            child: TextUtil.build("Aa-",
                color: _font == 12 ? Colors.white24 : Colors.white,
                fontSize: 16),
            borderSide: BorderSide(
                color: _font == 12 ? Colors.white24 : Colors.white54,
                width: 1.5),
            onPressed: () {
              _font--;
              if (_font < 12) {
                _font = 12;
                return;
              }
              if (widget.onChoose != null) {
                widget.onChoose(_font);
              }
              setState(() {});
              SpHelper.saveFontSetting(_font);
            },
          ),
          TextUtil.build(_fontList[_font],
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          OutlineButton(
            child: TextUtil.build("Aa+",
                color: _font == 21 ? Colors.white24 : Colors.white,
                fontSize: 16),
            borderSide: BorderSide(
                color: _font == 21 ? Colors.white24 : Colors.white54,
                width: 1.5),
            onPressed: () {
              _font++;
              if (_font > 21) {
                _font = 21;
                return;
              }
              if (widget.onChoose != null) {
                widget.onChoose(_font);
              }
              setState(() {});
              SpHelper.saveFontSetting(_font);
            },
          ),
        ],
      ),
    );
  }
}

//背景图片选择
class BackgroundSettingWidget extends StatefulWidget {
  final int imgIndex;
  final void Function(int imgIndex) onChoose;

  @override
  _BackgroundSettingWidgetState createState() =>
      _BackgroundSettingWidgetState();

  BackgroundSettingWidget({this.imgIndex, this.onChoose});
}

class _BackgroundSettingWidgetState extends State<BackgroundSettingWidget> {
  List<Color> _colorUris = MyColor.bgMap.values.toList();
  List<String> _imgUris = MyColor.bgImgList;
  int curIndex = 0;

  @override
  void initState() {
    curIndex = widget.imgIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      child: ListView.builder(
          itemCount: _imgUris.length + _colorUris.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index){
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 60,
                      decoration: index < _imgUris.length ? BoxDecoration(borderRadius: BorderRadius.circular(5.0), image: DecorationImage(image: AssetImage(_imgUris[index]),fit: BoxFit.fill))
                          : BoxDecoration(borderRadius: BorderRadius.circular(5.0),color: _colorUris[index-_imgUris.length],),
                    ),
                    Container(
                      width: 60,
                      child: Center(
                        child: curIndex == index ? Icon(Icons.check,color: Colors.redAccent,): Container(),
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  if(curIndex == index) return;
                  setState(() {
                    curIndex = index;
                  });
                  widget.onChoose(curIndex);
                  SpHelper.saveBackgroundSetting(curIndex);
                },
              ),
            );
          }),
    );
  }
}

//间距
class SpaceSettingWidget extends StatefulWidget {
  final void Function(double font) onChoose;
  final double space;

  @override
  _SpaceSettingWidgetState createState() => _SpaceSettingWidgetState();

  SpaceSettingWidget({this.space, this.onChoose});
}

class _SpaceSettingWidgetState extends State<SpaceSettingWidget> {
  static const double minSpace = 1.2;
  static const double midSpace = 1.6;
  static const double maxSpace = 2.0;
  double _space;

  @override
  void initState() {
    _space = widget.space;
    print("======== $_space");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          OutlineButton(
            child: Icon(
              MyIcon.minSpace,
              color: Colors.white,
            ),
            borderSide: BorderSide(
                color: _space == minSpace ? Colors.redAccent : Colors.white24,
                width: 1.5),
            onPressed: () {
              if (_space == minSpace) {
                return;
              }
              setState(() {
                _space = minSpace;
              });
              SpHelper.saveSpaceSetting(_space);
              widget.onChoose(_space);
            },
          ),
          OutlineButton(
            child: Icon(
              MyIcon.midSpace,
              color: Colors.white,
            ),
            borderSide: BorderSide(
                color: _space == midSpace ? Colors.redAccent : Colors.white24,
                width: 1.5),
            onPressed: () {
              if (_space == midSpace) {
                return;
              }
              setState(() {
                _space = midSpace;
              });
              SpHelper.saveSpaceSetting(_space);
              widget.onChoose(_space);
            },
          ),
          OutlineButton(
            child: Icon(
              MyIcon.maxSpace,
              color: Colors.white,
            ),
            borderSide: BorderSide(
                color: _space == maxSpace ? Colors.redAccent : Colors.white24,
                width: 1.5),
            onPressed: () {
              if (_space == maxSpace) {
                return;
              }
              setState(() {
                _space = maxSpace;
              });
              SpHelper.saveSpaceSetting(_space);
              widget.onChoose(_space);
            },
          ),
        ],
      ),
    );
  }
}

