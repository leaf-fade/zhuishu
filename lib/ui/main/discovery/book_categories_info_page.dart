import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/const.dart';
import 'package:zhuishu/ui/widget/book_list_tile.dart';
import 'package:zhuishu/ui/widget/refresh.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';
import 'package:zhuishu/util/string.dart';
/*
* 主界面：发现 - 分类 - 玄幻
* */
@ARoute(url: PageUrl.BOOK_CATEGORIES_INFO_PAGE)
class CategoriesInfoPage extends StatelessWidget {
  final RouteOption option;
  CategoriesInfoPage(this.option);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(option.params["name"]),
        elevation: 0.0,
      ),
      body: CategoriesInfoWidget(option.params["gender"],option.params["name"]),
    );
  }
}

class CategoriesInfoWidget extends StatefulWidget {
  final String title;
  final String gender;
  CategoriesInfoWidget(this.gender,this.title);

  @override
  _CategoriesInfoWidgetState createState() => _CategoriesInfoWidgetState();

}

class _CategoriesInfoWidgetState extends BasePageState<CategoriesInfoWidget> {
  String _type = "hot";
  String _minor = "";
  int _start = 0;
  int _limit = 20;
  int _total;
  List<BookIntro> books = [];
  List<String> mins = [];
  String _firstLine;
  String _secondLine;
  GlobalKey<RefreshHeaderState> _headerKey = GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = GlobalKey<RefreshFooterState>();
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  String error;


  @override
  void initState() {
    _firstLine = map3.keys.toList()[0];
    super.initState();
  }

  @override
  Widget buildBody() {
    return Column(
      children: <Widget>[
        buildMainHeader(),
        Divider(height: 1.0,),
        Expanded(child: buildList(),),
      ],
    );
  }

  Widget buildMainHeader(){
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildLineOne(),
          mins.isEmpty ? SizedBox.shrink(): Divider(height: 1.0,),
          buildLineTwo(),
        ],
      ),
    );
  }

  Widget buildEmpty(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("images/icon_cartoon.png"),
          SizedBox(
            height: 30,
          ),
          TextUtil.build("暂无数据",
              fontWeight: FontWeight.w500, fontSize: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget buildList(){
    return books.isEmpty? buildEmpty() : EasyRefresh(
      key: _easyRefreshKey,
      behavior: ScrollOverBehavior(),
      refreshHeader: buildHeader(_headerKey,error: error),
      refreshFooter: buildFooter(_footerKey,error: error),
      onRefresh: onRefresh,
      loadMore: loadMore,
      autoLoad: true,
      child: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index){
          BookIntro book = books[index];
          return InkWell(
            child: BookListTile(
              icon: StringAmend.imgUriAmend(book.cover),
              name: book.title,
              author: book.author,
              shortIntro: book.shortIntro,
              follower: StringAmend.numAmend(book.latelyFollower),
              minor: book.minorCate==null||book.minorCate.isEmpty ? book.majorCate : book.minorCate,
            ),
            onTap: (){
              //跳转到对应界面
              RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE, params: {"id": book.id});
            },
          );
        },
      ),
    );
  }

  Widget buildLineOne() {
    return SizedBox(
      height: 50,
      child: HeadCellItemGroup(
        texts: map3.keys.toList(),
        onCheck: (String value) {
          if(_firstLine == value) return;
          _firstLine = value;
          _type = map3[value];
          setState((){});
          _easyRefreshKey.currentState.callRefresh();
        },
        checkText: _firstLine,
      ),
    );
  }

  Widget buildLineTwo() {
    return mins.isEmpty ? SizedBox.shrink() :SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HeadCellItemGroup(
          texts: mins,
          onCheck: (String value) {
            if(_secondLine == value) return;
            _secondLine = value;
            setState((){
              _minor = value == mins[0] ? "": value;
            });
            _easyRefreshKey.currentState.callRefresh();
          },
          checkText: _secondLine,
        ),
      ),
    );
  }

  @override
  void loadData() async{
    String url = "/cats/lv2";
    await HttpUtil.getJson(url).then((data){
      List<CatsTag> list = CatsTag.getCatsTags(data["${widget.gender}"]);
      CatsTag catsTag = list.firstWhere((tag)=> tag.major == widget.title);
      if(mins.isNotEmpty){
        mins.add("全部");
        _secondLine = mins[0];
      }
      mins.addAll(catsTag.mins);
    }).catchError((error){
      if (pageState != PageState.Fail) {
        Toast.show(error is Error ? error.msg : "网络请求失败");
        loadFailState();
      }
    });
    await onNetConnect(init: true,clear: true);

  }

  Future<void> onRefresh() async{
    _start = 0;
    await onNetConnect(clear: true);
  }

  Future<void> loadMore() async{
    if (_start + _limit >= _total) return null;
    _start += _limit;
    await onNetConnect();
  }

  Future<void> onNetConnect({bool init = false, bool clear = false}) async{
    error = null;
    String uri = "/book/by-categories?gender=${widget.gender}&type=$_type&major=${widget.title}&minor=$_minor&start=$_start&limit=$_limit";
    await HttpUtil.getJson(uri).then((data){
      CategoriesInfo info = CategoriesInfo.fromJson(data);
      if(clear) books.clear();
      books.addAll(info.books);
      _total = info.total;
      loadSuccessState();
    }).catchError((error){
      print(error.toString());
      if(init){
        if (pageState != PageState.Fail) {
          Toast.show(error is Error ? error.msg : "网络请求失败");
          loadFailState();
        }
      }else{
        Toast.show(error is Error? error.msg :"网络请求失败");
        error = error.toString();
      }
    });
  }

}
