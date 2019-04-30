import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/ui/main/discovery/discovery_scene.dart';
import 'package:zhuishu/ui/main/me/me_scene.dart';
import 'package:zhuishu/ui/main/shelf/shelf_scene.dart';
/*
* 主界面
* */
class AppScene extends StatefulWidget {
  @override
  _AppSceneState createState() => _AppSceneState();
}

class _AppSceneState extends State<AppScene> {
  int _tabIndex = 0;
  List<Widget> _tabImg;
  List<Widget> _tabImgSelect;
  List<String> _appBarTitles;
  List<Widget> _pageList;
  List<BottomNavigationBarItem> _itemList;
  Color unSelectColor = Colors.grey;
  Color selectColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    init();
  }

  init(){
    _tabImg = [
      Icon(MyIcon.book,color: unSelectColor,),
      Icon(MyIcon.found,color: unSelectColor,),
      Icon(Icons.person,color: unSelectColor,),
    ];
    _tabImgSelect = [
      Icon(MyIcon.book,color: selectColor,),
      Icon(MyIcon.found,color: selectColor,),
      Icon(Icons.person,color: selectColor,),
    ];
    _appBarTitles = ['书架', '发现', '我的'];
    _pageList = [ShelfScene(), DiscoveryScene(), MeScene()];
  }

  buildItem(int index) {
    return BottomNavigationBarItem(icon: getTabIcon(index), title: Text(_appBarTitles[index],textScaleFactor: 1.0,));
  }

  @override
  Widget build(BuildContext context) {
    _itemList = List.generate(_appBarTitles.length,(index)=> buildItem(index));
    return Scaffold(
      body: _pageList[_tabIndex],
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: Colors.red,
        items: _itemList,
        currentIndex: _tabIndex,
        onTap: (index) {
          if(_tabIndex == index) return;
          setState(() {
            _tabIndex = index;
          });
        },
      ),
    );
  }

  Widget getTabIcon(int index) {
    if (index == _tabIndex) {
      return _tabImgSelect[index];
    } else {
      return _tabImg[index];
    }
  }
}

