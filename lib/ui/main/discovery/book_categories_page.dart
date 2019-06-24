import 'package:flutter/material.dart';
import 'package:zhuishu/ui/base/url.dart';
import 'package:zhuishu/model/categories.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/ui/widget/auto_table.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/toast.dart';
/*
* 主界面：发现 - 分类
* */
@ARoute(url: PageUrl.BOOK_CATEGORIES_PAGE)
class CategoriesPage extends StatelessWidget {
  final dynamic params;
  CategoriesPage(this.params);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("分类"),
      ),
      body: CategoriesWidget(),
    );
  }
}

class CategoriesWidget extends StatefulWidget {
  @override
  _CategoriesWidgetState createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends BasePageState<CategoriesWidget> {
  Categories _categories;
  @override
  Widget buildBody() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index){
        //奇数
        if(index.isOdd){
          return AutoTable<TypeNum>(
            _categories.list[index~/2],
            (typeNum){
              return buildCell(_categories.type2[index~/2],typeNum.name, typeNum.bookCount);
            },
            color: MyColor.divider,
          );
        }
        return Container(
          padding: EdgeInsets.all(15),
          child: Text(
            _categories.type[index~/2],
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 14,
            ),
          ),
        );
      }
    );
  }

  Widget buildCell(String gender,String name, int bookCount){
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: InkWell(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "$bookCount 本",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13
                ),
              )
            ],
          ),
        ),
        onTap: (){
          //跳转到对应界面
          RouteUtil.push(context, PageUrl.BOOK_CATEGORIES_INFO_PAGE, params: {"gender": gender,"name": name});
        },
      ),
    );
  }

  @override
  void loadData() {
    HttpUtil.getJson(BOOK_CATEGORIES_URL).then((data){
      dealData(data);
      loadSuccessState();
    }).catchError((error){
      print(error.toString());
      Toast.show(error is Error? error.msg :"网络请求失败");
      loadFailState();
    });
  }

  void dealData(Map<String, dynamic> data) {
    _categories = Categories.fromJson(data);
  }

}




