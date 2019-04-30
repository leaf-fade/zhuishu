
import 'dart:convert';

class AutoTip {

  String contentType;
  String tag;
  String text;
  String id;
  String author;

  AutoTip.fromParams({this.contentType, this.tag, this.text});

  AutoTip.fromJson(jsonRes) {
    contentType = jsonRes['contentType'];
    tag = jsonRes['tag'];
    text = jsonRes['text'];
    id = jsonRes["id"];
    author = jsonRes["author"];
  }

  static List<AutoTip> getAutoTips(jsonRes){
    List<AutoTip> list = [];
    for (var item in jsonRes ?? []){
      list.add(AutoTip.fromJson(item));
    }
    return list;
  }
}

class HotWord {
  int isNew;
  int soaring;
  int times;
  String word;

  HotWord.fromParams({this.isNew, this.soaring, this.times, this.word});

  HotWord.fromJson(jsonRes) {
    isNew = jsonRes['isNew'];
    soaring = jsonRes['soaring'];
    times = jsonRes['times'];
    word = jsonRes['word'];
  }

  HotWord.fromString(String str){
    var jsonRes = json.decode(str);
    HotWord.fromJson(jsonRes);
  }

  @override
  String toString() {
    return '{"isNew": $isNew, "soaring": $soaring,"times": $times,"word": ${word != null?'${json.encode(word)}':'null'}}';
  }

  static List<HotWord> getHotWords(jsonRes){
    List<HotWord> list = [];
    for (var item in jsonRes ?? []){
      list.add(HotWord.fromJson(item));
    }
    return list;
  }

  static List<String> toJson(List<HotWord> list){
    return list.map((word)=> word.toString()).toList();
  }
}


class HotBook{

  String book;
  String word;

  HotBook.fromParams({this.book, this.word});

  HotBook.fromJson(jsonRes) {
    book = jsonRes['book'];
    word = jsonRes['word'];
  }

  HotBook.fromString(String str) {
    var jsonRes = json.decode(str);
    HotBook.fromJson(jsonRes);
  }

  @override
  String toString() {
    return '{"book": ${book != null?'${json.encode(book)}':'null'},"word": ${word != null?'${json.encode(word)}':'null'}}';
  }

  static List<HotBook> getHotBooks(jsonRes){
    List<HotBook> list = [];
    for (var item in jsonRes ?? []){
      list.add(HotBook.fromJson(item));
    }
    return list;
  }

  static List<String> toJson(List<HotBook> list){
    return list.map((word)=> word.toString()).toList();
  }

}




