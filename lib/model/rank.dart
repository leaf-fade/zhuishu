import 'dart:convert' show json;

class RankItemInfo {

  bool collapse;
  String id;
  String cover;
  String shortTitle;
  String title;

  RankItemInfo.fromParams({this.collapse, this.id, this.cover, this.shortTitle, this.title});

  RankItemInfo.fromJson(jsonRes) {
    collapse = jsonRes['collapse'];
    id = jsonRes['_id'];
    cover = jsonRes['cover'];
    shortTitle = jsonRes['shortTitle'];
    title = jsonRes['title'];
  }

  static List<RankItemInfo> getRankItemList(data){
    List<RankItemInfo> list = [];
    for(var info in data??[]){
      list.add(RankItemInfo.fromJson(info));
    }
    return list;
  }

  @override
  String toString() {
    return '{"collapse": $collapse,"_id": ${id != null?'${json.encode(id)}':'null'},"cover": ${cover != null?'${json.encode(cover)}':'null'},"shortTitle": ${shortTitle != null?'${json.encode(shortTitle)}':'null'},"title": ${title != null?'${json.encode(title)}':'null'}}';
  }
}

