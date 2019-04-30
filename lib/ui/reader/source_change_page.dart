import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/book_source.dart';
import 'package:zhuishu/util/file.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/text.dart';

/*
* 换源
* */
class SourceChangePage extends StatelessWidget {
  final Key key;
  final List<BookSource> sources;
  final int curId;
  final String articleId;
  final void Function(int index) callback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("换源列表"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ListView.builder(
          itemCount: sources.length,
            itemBuilder: buildItem),
      ),
    );
  }

  Widget buildItem(context, index){
    return Container(
      height: 70.0,
      child: Card(
        elevation: 1.0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),  //设置圆角
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(14.0)),
          child: ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Icon(MyIcon.menu, color: Colors.red[300]),
            ),
            title: TextUtil.build(sources[index].name,fontSize: 16, color: Colors.black87),
            subtitle: TextUtil.build(sources[index].lastChapter),
            trailing: index == curId ?Icon(Icons.check_circle,color: Colors.redAccent,) : null,
          ),
          onTap: (){
            if(index == curId) return;
            callback(index);
            SpHelper.saveBookSource(articleId, sources[index].id);
            FileUtil.removeAllFile(articleId);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  SourceChangePage({this.key, this.articleId,this.curId,this.sources, this.callback});
}

