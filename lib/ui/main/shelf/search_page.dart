import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/model/search.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/widget/book_list_tile.dart';
import 'package:zhuishu/ui/widget/refresh.dart';
import 'package:zhuishu/util/icon.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';

List<String> historys;
int startTableIndex = 0;
bool isResult = false;

/*
* 备注：官方的搜索样式固定，所以这里重写
* */
@ARoute(url: PageUrl.SEARCH_PAGE)
class SearchPage extends StatefulWidget {
  final RouteOption option;

  @override
  _SearchPageState createState() => _SearchPageState();

  SearchPage(this.option);
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController queryTextController;
  final FocusNode _focusNode = FocusNode();
  String hintText = "";
  List<AutoTip> tips = [];
  List<HotWord> hotWords;
  List<HotBook> hotBooks;

  final ValueNotifier<_SearchBody> _currentBodyNotifier =
      ValueNotifier<_SearchBody>(null);

  _SearchBody get _currentBody => _currentBodyNotifier.value;

  int tableRow = 3;
  int tableCol = 2;

  set _currentBody(_SearchBody value) {
    _currentBodyNotifier.value = value;
  }

  String oldQuery;

  String get query => queryTextController.text;

  set query(String value) {
    assert(query != null);
    queryTextController.text = value;
  }

  @override
  void initState() {
    queryTextController = TextEditingController();
    queryTextController.addListener(_onQueryChanged);
    _focusNode.addListener(_onFocusChanged);
    _currentBodyNotifier.addListener(_onSearchBodyChanged);
    _currentBody = _SearchBody.suggestions;
    loadSuggestionsData();
    super.initState();
  }

  @override
  void dispose() {
    queryTextController.dispose();
    _focusNode.dispose();
    _currentBodyNotifier.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
//    if (_focusNode.hasFocus && _currentBody != _SearchBody.suggestions) {
//      showSuggestions(context);
//    }
  }

  void _onQueryChanged() async {
    print(query);
    if (query == oldQuery) return;
    oldQuery = query;
    if (isResult) return;
    if (query != null && query.isNotEmpty) {
      //网络请求，然后判断有无返回，无返回则显示suggestions
      tips = await autoQuery(query);
      if (tips == null || tips.isEmpty) {
        showSuggestions(context);
      } else {
        showAutoTips(context);
      }
    } else {
      showSuggestions(context);
    }
    setState(() {});
  }

  void _onSearchBodyChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        textTheme: TextTheme(body1: TextStyle(color: Colors.black87)),
        iconTheme: IconThemeData(color: Colors.black87),
        brightness: Brightness.light,
        titleSpacing: 0,
        elevation: 0.0,
        title: buildEditText(context),
        actions: buildActions(context),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    Widget body;
    switch (_currentBody) {
      case _SearchBody.suggestions:
        body = buildSuggestions(context);
        break;
      case _SearchBody.results:
        body = buildResults(context);
        break;
      case _SearchBody.autoTips:
        body = buildAutoTips(context);
    }
    return body;
  }

  List<Widget> buildActions(BuildContext context) {
    return [
      InkWell(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: TextUtil.build("搜索",
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
        onTap: () {
          isResult = true;
          if (query == null || query.isEmpty) {
            query = hintText;
          }
          showResults(context);
        },
      ),
    ];
  }

  Widget buildEditText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      alignment: Alignment.center,
      height: 36,
      decoration: BoxDecoration(
          color: Color(0xFFE9EAEC),
          border: new Border.all(color: Color(0XFFEEEEEE)),
          borderRadius: BorderRadius.circular(6.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: queryTextController,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (String _) {
                isResult = true;
                if (query == null || query.isEmpty) {
                  query = hintText;
                }
                showResults(context);
              },
              decoration: InputDecoration.collapsed(hintText: hintText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: query == null || query.isEmpty
                ? Container()
                : buildIcon(
                    icon: Icons.cancel,
                    color: Color(0xFFF6F6F6),
                    onTap: () {
                      query = "";
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void showSuggestions(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    _currentBody = _SearchBody.suggestions;
  }

  void showAutoTips(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    _currentBody = _SearchBody.autoTips;
  }

  void showResults(BuildContext context) {
    _focusNode.unfocus();
    _currentBody = _SearchBody.results;
  }

  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: <Widget>[
        SuggestionCell(
          leftTitle: "搜索热词",
          rightTip: "查看更多",
          rightIcon: Icons.keyboard_arrow_right,
          onTap: () {},
          bodyBuild: (context) {
            if (hotWords == null || hotWords.isEmpty) return null;
            return SizedBox(
              height: 105,
              child: Wrap(
                spacing: 10.0, // gap between adjacent chips
                runSpacing: 10.0, // gap between lines
                children:
                    hotWords.map((word) => buildHotWordItem(word)).toList(),
              ),
            );
          },
        ),
        SuggestionCell(
            leftTitle: "热门推荐",
            rightTip: "换一批",
            rightIcon: Icons.refresh,
            onTap: () {
              startTableIndex += tableCol * tableRow;
              if (startTableIndex >= hotBooks.length) {
                startTableIndex = 0;
              }
            },
            bodyBuild: (context) {
              if (hotBooks == null || hotBooks.isEmpty) return null;
              return Table(
                children: buildTables(startTableIndex, tableRow, tableCol),
              );
            }),
        SuggestionCell(
          leftTitle: "搜索历史",
          rightTip: "删除历史",
          rightIcon: Icons.delete,
          onTap: () {
            historys.clear();
            SpUtil.set(SEARCH_HISTORY, historys);
          },
          bodyBuild: (context) {
            if (historys == null || historys.isEmpty) return null;
            return Column(
              children: historys.reversed
                  .map((str) => buildHistoryItem(str))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget buildHotWordItem(HotWord word) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      child: TextUtil.buildBorder(word.word,
          fontSize: 14.0, horizontal: 10.0, vertical: 5.0),
      onTap: () {
        isResult = true;
        query = word.word;
        showResults(context);
      },
    );
  }

  List<TableRow> buildTables(int startIndex, int row, int col) {
    Widget buildTableItem(index) {
      return index < hotBooks.length
          ? InkWell(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.book,
                    color: Colors.grey[400],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextUtil.buildOverFlow(hotBooks[index].word,
                        color: Colors.blueGrey),
                  ),
                ],
              ),
              onTap: () {
                RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE,
                    params: {"id": hotBooks[index].book});
              },
            )
          : Container();
    }

    return List.generate(
        row,
        (rowIndex) => TableRow(
              children: List.generate(
                  col,
                  (colIndex) => Container(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: buildTableItem(
                            startIndex + (rowIndex + 1) * (colIndex + 1)),
                      )),
            ));
  }

  Widget buildHistoryItem(String str) {
    return InkWell(
      child: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.history,
              color: Colors.grey[300],
            ),
            SizedBox(
              width: 10.0,
            ),
            TextUtil.buildOverFlow(str),
          ],
        ),
      ),
      onTap: () async {
        isResult = true;
        query = str;
        //跳转到对应界面
        showResults(context);
      },
    );
  }

  Widget buildAutoTips(BuildContext context) {
    return ListView.separated(
        itemCount: tips.length,
        itemBuilder: (context, index) {
          AutoTip tip = tips[index];
          return InkWell(
            child: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    tip.tag == "bookname"
                        ? Icons.book
                        : (tip.tag == "bookauthor" ? Icons.person : MyIcon.tag),
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  TextUtil.buildOverFlow(tip.text),
                  tip.contentType == "picture"
                      ? Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: TextUtil.buildBorder("漫画",
                              color: Colors.white,
                              background: Colors.red[300],
                              fontSize: 8.0),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            onTap: () async {
              query = tip.text;
              //跳转到对应界面
              if (tip.tag == "bookname") {
                RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE,
                    params: {"id": tip.id});
              } else if (tip.tag == "bookauthor") {
                RouteUtil.push(context, PageUrl.AUTHOR_BOOKS_PAGE,
                    params: {"title": tip.text});
              } else {
                RouteUtil.push(context, PageUrl.AUTHOR_BOOKS_PAGE,
                    params: {"title": tip.text, "type": "tag"});
              }
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
          );
        });
  }

  Widget buildResults(BuildContext context) => SearchContent(query);

  //======网络加载部分========
  Future<String> getBookId(String keyWord) async {
    String url = "/book/fuzzy-search?query=$keyWord";
    String id;
    await HttpUtil.getJson(url).then((data) {
      id = CategoriesInfo.fromJson(data).books[0].id;
    });
    return id;
  }

  Future<List<AutoTip>> autoQuery(String keyword) async {
    String url = "/book/auto-suggest?query= $keyword";
    List<AutoTip> lists = [];
    var data = await HttpUtil.getJson(url).catchError((error) => error);
    if (data is! Error) {
      lists = AutoTip.getAutoTips(data["keywords"]);
    }
    return lists;
  }

  void loadSuggestionsData() {
    //搜索热词
    String hotWordsUrl = "/book/search-hotwords";
    HttpUtil.getJson(hotWordsUrl).then((data) {
      hotWords = HotWord.getHotWords(data["searchHotWords"]);
      SpUtil.set(SEARCH_HOT_WORDS, HotWord.toJson(hotWords));
      if (hotWords != null) {
        hintText = hotWords[0].word;
      }
      setState(() {});
    }).catchError((error) async {
      List<String> list = await SpUtil.getStringList(SEARCH_HOT_WORDS);
      hotWords = list?.map((str) => HotWord.fromString(str))?.toList();
      if (hotWords != null) {
        hintText = hotWords[0].word;
      }
      setState(() {});
    });

    //热门推荐
    String hotBooksUrl = "/book/hot-word";
    HttpUtil.getJson(hotBooksUrl).then((data) {
      hotBooks = HotBook.getHotBooks(data["newHotWords"]);
      SpUtil.set(SEARCH_HOT_WORDS, HotBook.toJson(hotBooks));
      setState(() {});
    }).catchError((error) async {
      List<String> list = await SpUtil.getStringList(SEARCH_HOT_BOOKS);
      hotBooks = list?.map((str) => HotBook.fromString(str))?.toList();
      setState(() {});
    });
    //搜索历史
    SpUtil.getStringList(SEARCH_HISTORY).then((List<String> list) {
      historys = list ?? [];
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

enum _SearchBody {
  //建议页
  suggestions,
  //查询补全
  autoTips,
  //查询结果页
  results,
}

class SuggestionCell extends StatefulWidget {
  final String leftTitle;
  final String rightTip;
  final IconData rightIcon;
  final VoidCallback onTap;
  final WidgetBuilder bodyBuild;

  @override
  _SuggestionCellState createState() => _SuggestionCellState();

  SuggestionCell(
      {this.leftTitle,
      this.rightTip,
      this.rightIcon,
      this.onTap,
      this.bodyBuild});
}

class _SuggestionCellState extends State<SuggestionCell> {
  Widget body;

  @override
  Widget build(BuildContext context) {
    body = widget.bodyBuild(context);
    return body == null ? Container() : buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextUtil.build(widget.leftTitle,
                  color: Colors.black87, fontWeight: FontWeight.w600),
              InkWell(
                child: Row(
                  children: <Widget>[
                    TextUtil.build(widget.rightTip, fontSize: 12.0),
                    SizedBox(
                      width: 5.0,
                    ),
                    Icon(
                      widget.rightIcon,
                      color: Colors.grey[300],
                      size: 16,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    if (widget.onTap != null) widget.onTap();
                  });
                },
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          body,
          SizedBox(
            height: 10.0,
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}

/*
* 搜索结果显示
* */
class SearchContent extends StatefulWidget {
  final String keyWord;

  @override
  _SearchContentState createState() => _SearchContentState();

  SearchContent(this.keyWord);
}

class _SearchContentState extends BasePageState<SearchContent> {
  List<BookIntro> books = [];
  int total;
  int start = 0;
  final int limit = 20;
  String error;
  GlobalKey<RefreshHeaderState> _headerKey = GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = GlobalKey<RefreshFooterState>();

  @override
  void initState() {
    isResult = false;
    super.initState();
  }

  @override
  Widget buildBody() {
    return EasyRefresh(
      behavior: ScrollOverBehavior(),
      refreshHeader: buildHeader(_headerKey,error: error),
      refreshFooter: buildFooter(_footerKey,error: error),
      onRefresh: onRefresh,
      loadMore: loadMore,
      autoLoad: true,
      child: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          BookIntro book = books[index];
          return InkWell(
            child: BookListTile(
              icon: StringAmend.imgUriAmend(book.cover),
              name: book.title,
              author: book.author,
              shortIntro: book.shortIntro,
              follower: StringAmend.numAmend(book.latelyFollower),
              minor: book.cat,
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
  void loadData() {
    onNetConnect(init: true,clear: true);
  }


  Future<void> onNetConnect({bool init = false, bool clear = false}) async{
    error = null;
    String url =
        "/book/fuzzy-search?query=${widget.keyWord}&start=$start&limit=$limit";
    await HttpUtil.getJson(url).then((data) {
      CategoriesInfo info = CategoriesInfo.fromJson(data);
      if(clear) books.clear();
      books.addAll(info.books);
      total = info.total;
      loadSuccessState();
      if(init){
        historys.remove(widget.keyWord);
        historys.add(widget.keyWord);
        SpUtil.set(SEARCH_HISTORY, historys);
      }
    }).catchError((error) {
      print(error.toString());
      Toast.show(error is Error ? error.msg : "网络请求失败");
      init? loadFailState() : error = error.toString();
    });
  }


  Future<void> onRefresh() async {
    start = 0;
    await onNetConnect(clear: true);
  }

  Future<void> loadMore() async {
    if (start + limit >= total) return null;
    start += limit;
    await onNetConnect();
  }
}
