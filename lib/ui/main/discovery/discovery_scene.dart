import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/router/route_util.dart';
import 'package:zhuishu/router/router_const.dart';
import 'package:zhuishu/ui/main/discovery/book_categories_page.dart';

class DiscoveryScene extends StatelessWidget {
  final icons = [
    Icon(MyIcon.list),
    Icon(MyIcon.menu),
    Icon(Icons.library_books),
  ];
  final texts = ["排行榜","分类","书单"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("发现"),
        actions: <Widget>[
          Icon(Icons.search),
        ],
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: List.generate(texts.length, (index)=> buildItem(index, context))
      )
    );
  }

  buildItem(int index, BuildContext context){
    return ListTile(
      leading: icons[index],
      title: Text(texts[index]),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: (){
        RouteUtil.push(context, PageUrl.BOOK_CATEGORIES_PAGE);
      },
    );
  }
}
