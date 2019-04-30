class Categories{
  List<String> type = ["男生","女生","漫画","出版社"];
  List<String> type2 = ["male","female","picture","press"];
  List<List<TypeNum>> list = List();
  List<TypeNum> female = [];
  List<TypeNum> male = [];
  List<TypeNum> picture = [];
  List<TypeNum> press = [];

  Categories.fromJson(Map jsonRes){
    for (var item in jsonRes["male"]?? []){
      male.add(TypeNum.fromJson(item));
    }

    for (var item in jsonRes["female"] ?? []){
      female.add(TypeNum.fromJson(item));
    }

    for (var item in jsonRes["picture"] ?? []){
      picture.add(TypeNum.fromJson(item));
    }

    for (var item in jsonRes["press"] ?? []){
      press.add(TypeNum.fromJson(item));
    }
    list.add(male);
    list.add(female);
    list.add(picture);
    list.add(press);
  }
}

class TypeNum {
  int bookCount;
  int monthlyCount;
  String icon;
  String name;


  TypeNum.fromParams({this.bookCount, this.monthlyCount, this.icon, this.name});

  TypeNum.fromJson(jsonRes) {
    bookCount = jsonRes['bookCount'];
    monthlyCount = jsonRes['monthlyCount'];
    icon = jsonRes['icon'];
    name = jsonRes['name'];
  }

}


