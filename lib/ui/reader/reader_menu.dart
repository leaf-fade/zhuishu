import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/model/book_source.dart';
import 'package:zhuishu/ui/reader/catalogue_list_page.dart';
import 'package:zhuishu/ui/reader/setting_menu.dart';
import 'package:zhuishu/ui/reader/source_change_page.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/file.dart';
import 'package:zhuishu/util/icon.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';

/*
* 阅读器的功能菜单，点击中间唤醒,带动画效果
* */
typedef SourceCallback = void Function(int index);
//目录菜单回调，返回章节link
typedef CatalogCallback = void Function(String link, int chapterId);
//夜间模式回调，修改颜色
//设置回调
typedef SettingCallback = void Function(
    double fontSize, double space, int imgIndex);
//下载回调，显示下载多少章   0，后续50章   1，后面全部  2，全部
typedef DownloadCallback = void Function(int type);

class ReaderMenu extends StatefulWidget {
  final BookData bookData;
  final SourceChapters chapters;
  final List<BookSource> sourceList;
  final VoidCallback onTap;
  final SourceCallback sourceCallback;
  final CatalogCallback catalogCallback;
  final VoidCallback nightCallback;
  final SettingCallback settingCallback;
  final DownloadCallback downloadCallback;

  ReaderMenu(this.bookData, this.chapters, this.sourceList,
      {this.catalogCallback,
      this.nightCallback,
      this.settingCallback,
      this.downloadCallback,
      this.sourceCallback,
      this.onTap});

  @override
  _ReaderMenuState createState() => _ReaderMenuState();
}

class _ReaderMenuState extends State<ReaderMenu> {
  Color _color = Colors.white;
  IconData nightIcon = MyIcon.moon;

  @override
  void initState() {
    SpHelper.getTheme().then((themeIndex){
      if(themeIndex == 1){
        nightIcon = MyIcon.sun;
      }else{
        nightIcon = MyIcon.moon;
      }
      if(mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            widget.bookData.bookName,
            style: TextStyle(color: _color),
          ),
          elevation: 0,
          backgroundColor: Colors.black,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: buildIcon(
                icon: MyIcon.change,
                color: _color,
                onTap: () {
                  //换源
                  widget.onTap();
                  var curId = getSourceIndex();
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return SourceChangePage(
                        curId: curId,
                        articleId: widget.bookData.bookId,
                        sources: widget.sourceList,
                        callback: (index) {
                          widget.sourceCallback(index);
                        },
                      );
                    },
                    transitionDuration: Duration(milliseconds: 400),
                    barrierDismissible: false,
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: GestureDetector(
              onTapDown: (_) {
                widget.onTap();
              },
              child: Container(color: Colors.transparent),
            )),
            DownloadProgress(),
            buildBottomView(),
          ],
        ),
      ),
    );
  }

  int getSourceIndex() {
    int i = 0;
    for (BookSource source in widget.sourceList) {
      if (source.id == widget.bookData.sourceId) {
        break;
      }
      i++;
    }
    return i;
  }

  //记录是否加入书架
  Future<bool> _requestPop() async {
    widget.bookData.lastReadDate = DateTime.now().millisecondsSinceEpoch;
    await SpHelper.isAddToShelf(widget.bookData.bookId).then((isAdd) {
      if (isAdd) {
        //退出当前页面
        Navigator.of(context).pop();
        //缓存数据
        SpHelper.saveBookIntoShelf(widget.bookData);
        return Future.value(false);
      }
      showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: TextUtil.build("添书",
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                    color: Colors.black),
                content: TextUtil.build("是否将本书加入书架?", color: Colors.black87),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        //关dialog
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                      child: TextUtil.build("不了")),
                  FlatButton(
                      onPressed: () {
                        //关dialog
                        Navigator.pop(context);
                        //退出当前页面
                        Navigator.of(context).pop();
                        print("图片地址：" + widget.bookData.coverUrl);
                        //缓存数据
                        SpHelper.saveBookIntoShelf(widget.bookData);
                        eventBus.fire(AddShelfEvent(true));
                      },
                      child: TextUtil.build("加入书架", color: Colors.redAccent)),
                ],
              ));
    });
    return Future.value(false);
  }

  //4图标 目录，夜间，设置，下载
  Widget buildBottomView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      color: Colors.black,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildIcon(
              icon: MyIcon.list,
              color: _color,
              onTap: () {
                //目录
                widget.onTap();
                showGeneralDialog(
                  context: context,
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return CatalogueListPage(
                      chapters: widget.chapters,
                      bookData: widget.bookData,
                      callback: (String link, int chapterId) {
                        widget.catalogCallback(link, chapterId);
                      },
                    );
                  },
                  transitionDuration: Duration(milliseconds: 400),
                  transitionBuilder: (BuildContext context,
                      Animation<double> animation1,
                      Animation<double> animation2,
                      Widget child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                          .animate(CurvedAnimation(
                              parent: animation1, curve: Curves.fastOutSlowIn)),
                      child: child,
                    );
                  },
                  barrierDismissible: false,
                );
              }),
          buildIcon(
              icon: nightIcon,
              color: _color,
              onTap: () {
                if (nightIcon == MyIcon.moon) {
                  eventBus.fire(ThemeEvent(1));
                  SpHelper.saveTheme(1);
                  nightIcon = MyIcon.sun;
                } else {
                  eventBus.fire(ThemeEvent(0));
                  SpHelper.saveTheme(0);
                  nightIcon = MyIcon.moon;
                }
                setState(() {});
              }),
          buildIcon(
              icon: Icons.settings,
              color: _color,
              onTap: () {
                widget.onTap();
                //设置，弹出一个dialog
                SpHelper.getFontSetting().then((fontSize) {
                  double _font = fontSize ?? 13;
                  SpHelper.getSpaceSetting().then((space) {
                    double _space = space ?? 1.6;
                    SpHelper.getBackgroundSetting().then((imgIndex) {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SettingMenu(_font, _space, imgIndex,
                                (font, space, imgIndex) {
                              widget.settingCallback(font, space, imgIndex);
                            });
                          });
                    });
                  });
                });
              }),
          buildIcon(
              icon: Icons.file_download,
              color: _color,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Center(
                        child: TextUtil.build(
                          "下载",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      children: List.generate(downloadList.length,
                          (index) => buildDownloadItem(index)),
                    );
                  },
                  barrierDismissible: true,
                );
              }),
        ],
      ),
    );
  }

  List<String> downloadList = ["后50章", "后面全部", "全部"];

  Widget buildDownloadItem(index) {
    return SimpleDialogOption(
      child: Container(
        height: 50,
        alignment: Alignment(0, 0),
        child: TextUtil.build(downloadList[index]),
      ),
      onPressed: () async {
        Navigator.of(context).pop();
        int start = index == 2 ? 0 : widget.bookData.chapterId + 1;
        int end = widget.chapters.chapters.length - 1;
        if (index == 0 && start + 50 < end) {
          end = start + 50;
        }
        int downloadCount = 0;
        int totalCount = end - start;
        eventBus.fire(DownloadEvent(downloadCount, totalCount));
        var sourceIndex = getSourceIndex();
        for (int i = start; i < end; i++) {
          loadNetData(sourceIndex, widget.chapters.chapters[i].link, i).then((data){
            downloadCount++;
            if (downloadCount == totalCount) {
              totalCount = 0;
            }
            eventBus.fire(DownloadEvent(downloadCount, totalCount));
          });
        }
      },
    );
  }

  Future<bool> loadNetData(int sourceIndex, String link, int chapterId) async {
    String url = "/chapters/" + StringAmend.urlEncode(link);
    await HttpUtil.getJson(url).then((data) {
      var ch = data["chapter"];
      String str;
      if (widget.sourceList[sourceIndex].source == "zhuishuvip") {
        str = ch["cpContent"];
      } else {
        str = ch["body"];
      }
      FileUtil.createFile(
          widget.bookData.bookId, widget.bookData.chapterId, str);
      return true;
    }).catchError((error) {
      print(error.toString());
      Toast.show(error is Error ? error.msg : "网络请求失败");
      return false;
    });
    return false;
  }
}

class DownloadProgress extends StatefulWidget {
  @override
  _DownloadProgressState createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  int downloadCount = 0;
  int totalCount = 0;

  @override
  void initState() {
    eventBus.on<DownloadEvent>().listen((event) {
      if(!mounted) return;
      setState(() {
        totalCount = event.totalCount;
        downloadCount = event.downloadCount;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: totalCount == 0
          ? SizedBox()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 6.0),
                  child: TextUtil.build("下载进度  $downloadCount/$totalCount",
                      fontSize: 12),
                ),
                LinearProgressIndicator(
                  value: downloadCount / totalCount,
                  backgroundColor: Colors.black87,
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                ),
              ],
            ),
    );
  }
}
