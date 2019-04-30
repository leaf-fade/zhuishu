import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/router/route.dart';
import 'package:zhuishu/router/route_util.dart';
import 'package:zhuishu/router/router_const.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/widget/book_list_tile.dart';
import 'package:zhuishu/util/net.dart';
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
  CategoriesInfo info;

  @override
  Widget buildBody() {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index){
        BookIntro book = info.books[index];
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
    );
  }

  @override
  void loadData() {
    String uri = "/book/by-categories?gender=${widget.gender}&type=$_type&major=${widget.title}&minor=$_minor&start=$_start&limit=$_limit";
    HttpUtil.getJson(uri).then((data){
      dealData(data);
      loadSuccessState();
    }).catchError((error){
      print(error.toString());
      Toast.show(error is Error? error.msg :"网络请求失败");
      loadFailState();
    });
  }

  void dealData(Map<String, dynamic> data) {
    info = CategoriesInfo.fromJson(data);
  }
}
