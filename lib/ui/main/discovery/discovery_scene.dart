import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/util/icon.dart';
import 'package:zhuishu/router/index.dart';

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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: buildIcon(
              icon: Icons.search,
              onTap: () {
                RouteUtil.push(context, PageUrl.SEARCH_PAGE);
              },
            ),
          ),
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
        switch(index){
          case 0:
            RouteUtil.push(context, PageUrl.RANK_PAGE);
            break;
          case 1:
            RouteUtil.push(context, PageUrl.BOOK_CATEGORIES_PAGE);
            break;
          case 2:
            RouteUtil.push(context, PageUrl.BOOKS_LIST_PAGE);
            break;
        }
      },
    );
  }
}
