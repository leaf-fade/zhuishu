/*
* 目录列表，以dialog的形式出现
* */
import 'package:flutter/material.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/model/book_source.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/widget/drag.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/text.dart';

class CatalogueListPage extends StatelessWidget {
  final SourceChapters chapters;
  final BookData bookData;
  final void Function(String link, int chapterId) callback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          bookData.bookName,
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: CatalogueListView(
        chapters: chapters,
        callback: callback,
        bookData : bookData,
      ),
    );
  }

  CatalogueListPage(
      {this.chapters,this.callback, this.bookData});
}

class CatalogueListView extends StatefulWidget {
  final SourceChapters chapters;
  final BookData bookData;
  final void Function(String link, int chapterId) callback;

  @override
  _CatalogueListViewState createState() => _CatalogueListViewState();

  CatalogueListView({this.chapters, this.callback, this.bookData});
}

class _CatalogueListViewState extends BasePageState<CatalogueListView> {
  bool isReverse = false;
  ScrollController controller;
  SourceChapters chapters;
  List<BookSource> _sourceList;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();

  }

  @override
  Widget buildBody() {
    if(chapters==null) return Container();
    return Column(
      children: <Widget>[
        buildTitle(),
        Divider(height: 1,),
        Expanded(
          child: buildList(),
        ),
      ],
    );
  }

  Widget buildTitle() {
    return Container(
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextUtil.build("目录",
              fontWeight: FontWeight.w700, fontSize: 16.0, color: Colors.black),
          GestureDetector(
            child: Icon(isReverse ? Icons.arrow_upward : Icons.arrow_downward),
            onTap: () {
              setState(() {
                isReverse = !isReverse;
              });
            },
          )
        ],
      ),
    );
  }

  Widget buildList() {
    List<Chapter> list = chapters.chapters;
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: DraggableScrollbar.def(
        controller: controller,
        reverse: isReverse,
        child: ListView.builder(
            padding: EdgeInsets.all(0.0),
            itemExtent: 50.0,
            reverse: isReverse,
            itemCount: list.length,
            controller: controller,
            itemBuilder: (context, index) => buildItem(list, index)),
        heightScrollThumb: 40.0,
      ),
    );
  }

  Widget buildItem(List<Chapter> list, int index) {
    return InkWell(
      child: Container(
        alignment: Alignment(-1.0, 0),
        padding: EdgeInsets.fromLTRB(15.0, 0, 30.0, 0),
        child: TextUtil.build("${index + 1}.${list[index].title}",
            color: widget.bookData.chapterId == index ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500),
      ),
      onTap: () {
        if(widget.bookData.chapterId == index&&widget.callback != null) return;
        //获取保存的书籍信息
        //回调方法，返回选择的章节 link
        Navigator.pop(context);
        if (widget.callback != null) {
          widget.callback(list[index].link, index);
        }else{
          //路由跳转，这里是书详情进入的
          //阅读
          RouteUtil.push(context, PageUrl.READER_SCENE, params: {
            "bookId": widget.bookData.bookId,
            "chapterId": index,
            "bookName": widget.bookData.bookName,
            "coverUrl": widget.bookData.coverUrl,
          });
        }
      },
    );
  }

  @override
  void loadData() {
    chapters = widget.chapters;
    //重阅读器中来，已有数据
    if (chapters != null) {
      loadSuccess();
      return;
    }
    SpHelper.getBookSource(widget.bookData.bookId).then((source) async{
      var bookSource = source;
      //本地没存储源的id
      if(source == null){
        //网络加载获取
        bookSource = await loadSourceList();
      }
      print(bookSource);
      String url = "/atoc/$bookSource?view=chapters";
      netConnect(url, (data) {
        print("===========加载目录============");
        chapters = SourceChapters.fromJson(data);
      });
    });
  }

  Future<String> loadSourceList() async{
    String uri = "/atoc?view=summary&book=${widget.bookData.bookId}";
    String id;
    await netConnect(uri, (data) {
      print("=========选择书籍源 ============");
      List list = data == null ? [] : data;
      _sourceList = data == null ? null : [];
      for (var source in list) {
        _sourceList.add(BookSource.fromJson(source));
      }
      SpHelper.saveBookSource(widget.bookData.bookId, _sourceList[0].id);
      id = _sourceList[0].id;
    },checkOk: ()=>false);
    return id;
  }

  void loadSuccess() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      //跳转到对应章节
      controller.jumpTo((widget.bookData.chapterId) * 50.0);
    });
    loadSuccessState();
  }
}
