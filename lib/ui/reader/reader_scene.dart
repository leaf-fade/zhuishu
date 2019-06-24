import 'package:flutter/material.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/model/book_source.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/ui/reader/reader_menu.dart';
import 'package:zhuishu/ui/reader/reader_view.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/file.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/screen.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/toast.dart';
import 'package:screen/screen.dart' as display;

/*
* 阅读界面
*
* 原理：
* PageView实现翻页, 预加载，整体存3章
* 1. 章节分3个状态， 加载中，成功 ，失败
* 2. 先加载当前章节，等后续章节加载完成，在跳转过来
*
* */
@ARoute(url: PageUrl.READER_SCENE)
class ReaderScene extends StatelessWidget {
  final dynamic option;

  ReaderScene(this.option);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReaderPage(
        option.params["bookId"],
        option.params["bookName"],
        chapterId: option.params["chapterId"],
        coverUrl: option.params["coverUrl"],
      ),
    );
  }
}

class ReaderPage extends StatefulWidget {
  final String bookId;
  final int chapterId;
  final String bookName;
  final String coverUrl;

  @override
  _ReaderPageState createState() => _ReaderPageState();

  ReaderPage(this.bookId, this.bookName, {this.chapterId = 0, this.coverUrl});
}

class _ReaderPageState extends BasePageState<ReaderPage> {
  //当前章节的第几页
  int pageIndex = 0;

  //字体大小
  double _fontSize;

  //行间距
  double _space;
  int _imgIndex ;
  int _oldImgIndex;
  List<Color> _colorUris = MyColor.bgMap.values.toList();
  List<String> _imgUris = MyColor.bgImgList;
  Color textColor = Colors.black;

  PageController _pageController;

  //单章文章页数列表
  ChapterInfo preChapter;
  ChapterInfo curChapter;
  ChapterInfo nextChapter;

  //当前章节的id,主要是防止重复存储
  int _currentChapterId = 0;
  int curSourceIndex = 0;
  List<BookSource> _sourceList;
  SourceChapters _sourceChapters;
  List<String> readHistory;

  bool isMenuShow = false;
  bool isLoading = false;
  bool isPre = false;

  @override
  void initState() {
    _pageController = PageController()
      ..addListener(onScroll);
    //从sp中加载保存的字体设置爱好
    SpHelper.getFontSetting().then((fontSize) {
      _fontSize = fontSize ?? 16;
      SpHelper.getSpaceSetting().then((space) {
        _space = space ?? 1.6;
        SpHelper.getBackgroundSetting().then((imgIndex) {
          _imgIndex = imgIndex ?? 0;
          SpHelper.getTheme().then((themeIndex){
            _oldImgIndex = _imgIndex;
            if(themeIndex == 1){
              textColor =  Colors.grey[300];
              _imgIndex = _imgUris.length + _colorUris.length -1;
            }else{
              textColor =  Colors.black87;
              _imgIndex = _oldImgIndex;
            }
          });
        });
      });
    });
    eventBus.on<ThemeEvent>().listen((event){
      var themeIndex = event.index ?? 0;
      if(themeIndex == 1){
        textColor =  Colors.grey[300];
        _oldImgIndex = _imgIndex;
        _imgIndex = _imgUris.length + _colorUris.length -1;
      }else{
        textColor =  Colors.black87;
        _imgIndex = _oldImgIndex;
      }
      setState(() {});
    });
    display.Screen.keepOn(true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    display.Screen.keepOn(false);
    _pageController.dispose();
  }

  onScroll() {
    if(curChapter==null) return;
    var page = _pageController.offset / Screen.width;
    if (page >=
        curChapter.pageCount +
            (preChapter != null ? preChapter.pageCount : 0)) {
      isPre = false;
      print('到达下个章节了');
      //加载下下一页
      preChapter = curChapter;
      curChapter = nextChapter;
      nextChapter = null;
      pageIndex = 0;
      _pageController.jumpToPage(preChapter.pageCount);
      fetchNextChapter(curChapter.nextChapterId);
      setState(() {});
    }

    if (preChapter != null && page <= preChapter.pageCount - 1) {
      print('到达上个章节了');
      isPre = true;
      //加载前前一页
      nextChapter = curChapter;
      curChapter = preChapter;
      preChapter = null;
      pageIndex = curChapter.pageCount - 1;
      _pageController.jumpToPage(curChapter.pageCount - 1);
      fetchPreChapter(curChapter.preChapterId);
      setState(() {});
    }
  }

  @override
  Widget buildBody() {
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
            decoration: _imgIndex < _imgUris.length
                ? BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(_imgUris[_imgIndex]),
                        fit: BoxFit.fill))
                : BoxDecoration(
                    color: _colorUris[_imgIndex - _imgUris.length],
                  ),
            child: PageView.builder(
              itemCount: (preChapter != null ? preChapter.pageCount : 0) +
                  curChapter.pageCount +
                  (nextChapter != null ? nextChapter.pageCount : 0),
              itemBuilder: (context, index) {
                ChapterInfo chapter;
                var preLength = preChapter != null ? preChapter.pageCount : 0;
                var curLength = curChapter.pageCount;
                if (index < preLength) {
                  //前一页
                  chapter = preChapter;
                } else if (index < preLength + curLength) {
                  chapter = curChapter;
                  index = index - preLength;
                } else {
                  chapter = nextChapter;
                  index = index - preLength - curLength;
                }
                return ReaderView(
                  chapter.title,
                  _fontSize,
                  _space,
                  chapter.pageInfo[index],
                  "${index + 1}/${chapter.pageInfo.length}",
                  bookColor: textColor,
                  state: chapter.state,
                  onTap: (){
                    setState((){
                      curChapter.state = 1;
                    });
                    //重新网络请求
                    resetData(curChapter.chapterId);
                  },
                );
              },
              controller: _pageController,
              onPageChanged: (index) {
                var page =
                    index - (preChapter != null ? preChapter.pageCount : 0);
                if (page < curChapter.pageCount && page >= 0) {
                  pageIndex = page;
                }
              },
            ),
          ),
          onTapUp: (TapUpDetails details) {
            onTap(details.globalPosition);
          },
        ),
        buildMenu(),
      ],
    );
  }

  onTap(Offset position) {
    double xRate = position.dx / Screen.width;
    if (xRate > 0.33 && xRate < 0.66) {
      setState(() {
        isMenuShow = true;
      });
    } else if (xRate >= 0.66) {
      nextPage();
    } else {
      previousPage();
    }
  }

  previousPage() {
    //当前页的第一页
    if (pageIndex == 0 && curChapter.chapterId == 0) {
      Toast.show("已经是第一页了");
      return;
    }
    _pageController.previousPage(
        duration: Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  nextPage() {
    //到了当前页面的最后一页
    if (pageIndex >= curChapter.pageCount - 1 &&
        curChapter.chapterId == _sourceChapters.chapters.length - 1) {
      Toast.show('无最新章节了！');
      return;
    }
    _pageController.nextPage(
        duration: Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  buildMenu() {
    if(_sourceList == null){
      return Container();
    }
    BookData bookData = getBookData();
    return IgnorePointer(
      ignoring: !isMenuShow,
      child: Opacity(
        opacity: isMenuShow ? 1.0 : 0.0,
        child: ReaderMenu(
          bookData,
          _sourceChapters,
          _sourceList,
          onTap: hideMenu,
          catalogCallback: (String link, int chapterId) {
            print("=============目录回调=============");
            preChapter = null;
            nextChapter = null;
            setState((){
              curChapter.state = 1;
              curChapter.chapterId = chapterId;
              curChapter.link = _sourceChapters.chapters[chapterId].link;
              curChapter.title =  _sourceChapters.chapters[chapterId].title;
            });
            //重新网络请求
            resetData(chapterId);
          },
          settingCallback: setting,
          sourceCallback: (index) {
            curSourceIndex = index;
            preChapter = null;
            nextChapter = null;
            //加载数据
            reloadSourceData(_sourceList[index].id, curChapter.chapterId);
          },
        ),
      ),
    );
  }

  BookData getBookData()=> BookData(
    bookId: widget.bookId,
    bookName: widget.bookName,
    chapterId: curChapter.chapterId,
    lastChapterInfo: _sourceList[curSourceIndex].lastChapter,
    coverUrl: widget.coverUrl,
    lastUpdate: _sourceList[curSourceIndex].updated,
    sourceId: _sourceList[curSourceIndex].id,
    lastReadDate: DateTime.now().millisecondsSinceEpoch,
  );

  void setting(font, space, imgIndex) {
    if (imgIndex > -1) {
      setState(() {
        _imgIndex = imgIndex;
      });
      return;
    }
    if (font != -1) {
      _fontSize = font;
    }
    if (space != -1) {
      _space = space;
    }
    curChapter.pageInfo = buildPageListData(dealData(curChapter.content));
    if (preChapter != null) {
      preChapter.pageInfo = buildPageListData(dealData(preChapter.content));
    }
    if (nextChapter != null) {
      nextChapter.pageInfo = buildPageListData(dealData(nextChapter.content));
    }
    setState(() {});
  }

  hideMenu() {
    setState(() {
      this.isMenuShow = false;
    });
  }

  List<String> buildPageListData(String list) {
    return getReaderViewData(
      list,
      fontSize: _fontSize,
      space: _space,
    );
  }

  @override
  void loadData() {
    SpHelper.getBookSource(widget.bookId).then((source) async {
      var bookSource = source;
      print(bookSource);
      if (source == null) {
        //网络加载获取
        bookSource = await loadSourceList();
        print(bookSource);
      }else{
        loadSourceList();
      }
      String url = "/atoc/$bookSource?view=chapters";
      netConnect(
        url,
        (data) {
          print("===========2.加载目录============");
          _sourceChapters = SourceChapters.fromJson(data);
          resetData(widget.chapterId, firstInit: true);
        },
        checkOk: () => false,
      );
    });
  }

  Future<String> loadSourceList() async {
    String uri = "/atoc?view=summary&book=${widget.bookId}";
    String sourceId;
    await netConnect(
      uri,
      (data) {
        print("=========1. 选择书籍源 ============");
        List list = data == null ? [] : data;
        _sourceList = data == null ? null : [];
        for (var source in list) {
          _sourceList.add(BookSource.fromJson(source));
        }
        SpHelper.saveBookSource(widget.bookId, _sourceList[curSourceIndex].id);
        sourceId =  _sourceList[curSourceIndex].id;
      },
      checkOk: () => false,
    );
    return sourceId;
  }

  void reloadSourceData(String sourceId, int chapterId) {
    setState((){
      curChapter.state = 1;
    });
    String uri = "/atoc/$sourceId?view=chapters";
    HttpUtil.getJson(uri).then((data) {
      print("=========2. 选择源章节列表 ============");
      var _oldSourceCount = _sourceChapters.chapters.length;
      _sourceChapters = SourceChapters.fromJson(data);
      //章节数不同则加载第一章
      if(_sourceChapters.chapters.length != _oldSourceCount){
        chapterId = 0;
        curChapter.chapterId = 0;
      }
      resetData(chapterId);
    }).catchError((error) {
      print(error.toString());
      Toast.show(error is Error ? error.msg : "网络请求失败");
      loadFailState();
    });
  }

  fetchPreChapter(int chapterId) async {
    if (preChapter != null || isLoading || chapterId == 0) {
      return;
    }
    isLoading = true;
    ChapterInfo chapterInfo = await fetchChapter(chapterId);
    if (isPre) {
      preChapter = chapterInfo;
    }
    _pageController.jumpToPage(preChapter.pageCount + pageIndex);
    isLoading = false;
    setState(() {});
  }

  fetchNextChapter(int chapterId) async {
    if (nextChapter != null ||
        isLoading ||
        chapterId == _sourceChapters.chapters.length - 1) {
      return;
    }
    isLoading = true;
    ChapterInfo chapterInfo = await fetchChapter(chapterId);
    //来回切换，延迟高则不加载
    if (!isPre) {
      nextChapter = chapterInfo;
    }
    isLoading = false;
    setState(() {});
  }

  saveReadHistory() async{
    if(readHistory == null){
      readHistory = await SpUtil.getStringList(READ_HISTORY);
    }
    if(curChapter == null || curChapter.chapterId == _currentChapterId) return;

    _currentChapterId = curChapter.chapterId;
    BookData data = getBookData();
    if(readHistory!=null && readHistory.isNotEmpty){
      for(String str in readHistory ?? []){
        if(str.contains(data.bookId)){
          readHistory.remove(str);
          break;
        }
      }
    }else{
      readHistory = [];
    }
    readHistory.add(data.toString());
    SpUtil.set(READ_HISTORY, readHistory);
  }

  Future<ChapterInfo> fetchChapter(int chapterId) async {
    ChapterInfo chapterInfo = await accessPageData(chapterId);
    if (chapterInfo != null && chapterInfo.state == 0) {
      chapterInfo.pageInfo = buildPageListData(dealData(chapterInfo.content));
    }
    return chapterInfo;
  }

  resetData(int chapterId, {bool firstInit = false}) async {
    pageIndex = 0;
    curChapter = await fetchChapter(chapterId);
    if (curChapter != null) {
      if(!firstInit){
        _pageController.jumpToPage(0);
      }
      loadSuccessState();
    }

    if (chapterId > 0) {
      preChapter = await fetchChapter(chapterId - 1);
      if (preChapter != null) {
        _pageController.jumpToPage(preChapter.pageCount + pageIndex);
        setState(() {});
      }
    } else {
      preChapter = null;
    }

    if (chapterId < _sourceChapters.chapters.length - 1) {
      nextChapter = await fetchChapter(chapterId + 1);
      setState(() {});
    } else {
      nextChapter = null;
    }
  }

  /*
  * 先从本地存储中获取，如果不存在，再从网络中获取
  * */
  Future<ChapterInfo> accessPageData(int chapterId) async {
    if (chapterId < 0 || chapterId >= _sourceChapters.chapters.length)
      return null;
    if(curChapter!=null && curChapter.chapterId != null && curChapter.chapterId != _currentChapterId){
      _currentChapterId =  curChapter.chapterId;
      SpHelper.saveShelfBookChapterId(curChapter.bookId,_currentChapterId);
    }
    ChapterInfo chapterInfo;
    await FileUtil.readFile(widget.bookId, chapterId).then((str) async {
      if (str == null || str.isEmpty) {
        chapterInfo = await loadNetData(
            _sourceChapters.chapters[chapterId].link, chapterId);
      } else {
        chapterInfo = ChapterInfo(
          chapterId: chapterId,
          link: _sourceChapters.chapters[chapterId].link,
          title: _sourceChapters.chapters[chapterId].title,
          bookName: widget.bookName,
          bookId: widget.bookId,
          content: str,
        );
      }
    });
    saveReadHistory();
    return chapterInfo;
  }

  Future<ChapterInfo> loadNetData(String link, int chapterId) async {
    print("=========3.  网络加载 ====================");
    ChapterInfo chapterInfo = ChapterInfo(
      chapterId: chapterId,
      link: link,
      title: _sourceChapters.chapters[chapterId].title,
      bookName: widget.bookName,
      bookId: widget.bookId,
      state: 1,
    );
    String url = "http://chapterup.zhuishushenqi.com/chapter/" + StringAmend.urlEncode(link);
    await HttpUtil.getJson(url).then((data) {
      var ch = data["chapter"];
      String str;
      if (_sourceList[curSourceIndex].source == "zhuishuvip") {
        str = ch["cpContent"];
      } else {
        str = ch["body"];
      }
      chapterInfo.state = 0;
      chapterInfo.content = str;
      cacheBookData(chapterInfo);
    }).catchError((error) {
      print(error.toString());
      if (pageState != PageState.Fail) {
        Toast.show(error is Error ? error.msg : "网络请求失败");
        chapterInfo.state = 2;
        chapterInfo.pageInfo = [""];
      }
    });
    return chapterInfo;
  }

  void cacheBookData(ChapterInfo info) {
    //存储文章数据
    print("======= 文件存储操作 =======");
    FileUtil.createFile(info.bookId, info.chapterId, info.content);
  }
}
