import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/model/rank.dart';
import 'package:zhuishu/ui/base/base_future_page.dart' show BaseFutureWidget;
import 'package:zhuishu/ui/widget/book_list_tile.dart';
import 'package:zhuishu/ui/widget/refresh.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/router/index.dart';

@ARoute(url: PageUrl.RANK_PAGE)
class RankPage extends StatelessWidget {
  final RouteOption option;
  final List list = [
    "男频",
    "女频",
    "出版",
    "漫画",
  ];
  final List menuList = [
    "male",
    "female",
    "epub",
    "picture",
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: list.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("排行榜"),
          elevation: 0.0,
          bottom: TabBar(
            tabs: list
                .map((str) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(str),
                    ))
                .toList(),
            indicatorColor: Colors.red[200],
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: BaseFutureWidget(
          future: loadCacheData(),
          buildSuccess: (context, data) {
            return TabBarView(
              children:
                  menuList.map((str) => buildRankWidget(str, data)).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget buildRankWidget(String str, dynamic data) {
    return RankWidget(RankItemInfo.getRankItemList(data[str]));
  }

  loadCacheData() async {
    String rankUrl = "/ranking/gender";
    return await HttpUtil.getJson(rankUrl);
  }

  RankPage(this.option);
}


class RankWidget extends StatefulWidget {
  final List<RankItemInfo> info;

  @override
  _RankWidgetState createState() => _RankWidgetState();

  RankWidget(this.info);
}

class _RankWidgetState extends State<RankWidget> with AutomaticKeepAliveClientMixin{
  List<BookIntro> books;
  int curIndex = 0;
  GlobalKey<RefreshHeaderState> _headerKey = GlobalKey<RefreshHeaderState>();

  @override
  void initState() {
    loadBooksInfo();
    super.initState();
  }

  Future<void> loadBooksInfo() async{
    String url = "/ranking/${widget.info[curIndex].id}";
    return await HttpUtil.getJson(url).then((data){
      if(mounted){
        setState(() {
          books = BookIntro.getBooksList(data["ranking"]["books"]);
        });
      }
    }).catchError((error){
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: buildLeftList(),
        ),
        Expanded(
          flex: 7,
          child: books== null||books.isEmpty ? buildLoading(context) : buildRightList(),
        ),
      ],
    );
  }

  buildLeftList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0x1F000000),
          width: 0.5,
        ),
      ),
      child: ListView.separated(
          itemBuilder: buildLeftListItem,
          separatorBuilder: (context, index) => Divider(height: 1.0,),
          itemCount: widget.info.length),
    );
  }

  Widget buildLeftListItem(context, index) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: TextUtil.build(widget.info[index].shortTitle, color: index == curIndex ? Colors.red : Colors.grey),
      ),
      onTap: () {
        curIndex = index;
        loadBooksInfo();
      },
    );
  }

  Widget buildLoading(BuildContext context) {
    return Center(
        child: CupertinoActivityIndicator(
          radius: 15.0,
        ));
  }

  Widget buildRightList() {
    return EasyRefresh(
      behavior: ScrollOverBehavior(),
      refreshHeader: buildHeader(_headerKey),
      onRefresh: loadBooksInfo,
      autoLoad: true,
      child: ListView.builder(
        itemCount: books.length+1,
        itemBuilder: (context, index) {
          if(index == books.length) return Container(
            height: 30,
            alignment: Alignment.center,
            child: TextUtil.build("--到底部了--"),
          );
          BookIntro book = books[index];
          return InkWell(
            child: BookListTile(
              height: 70,
              icon: StringAmend.imgUriAmend(book.cover),
              name: book.title,
              author: book.author,
              shortIntro: book.shortIntro,
              follower: StringAmend.numAmend(book.latelyFollower),
              minor: book.minorCate==null||book.minorCate.isEmpty ? book.majorCate : book.minorCate,
            ),
            onTap: () {
              //跳转到对应界面
              RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE,
                  params: {"id": book.id});
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
