import 'package:flutter/material.dart';
import 'package:zhuishu/ui/main/shelf/history_page.dart';

class MeScene extends StatelessWidget {
  final List menuTitles = [
    '我的主题',
    '阅读记录',
    '收藏书单',
  ];
  final List menuIcons = [
    Icons.music_note,
    Icons.history,
    Icons.favorite,
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          //AppBar，包含一个导航栏
          SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('我的'),
              background: Image.asset(
                "./images/read_bg_1.png", fit: BoxFit.cover,),
            ),
          ),
          //List
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              buildItem,
              childCount: menuTitles.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index){
    return ListTile(
      leading: Icon(menuIcons[index]),
      title: Text(menuTitles[index]),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HistoryPage()));
            break;
        }
      },
    );
  }
}
