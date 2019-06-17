import 'package:shared_preferences/shared_preferences.dart';
import 'package:zhuishu/model/book_shelf_data.dart';

class SpUtil{
  static set(String key, Object value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (value is int) {
      sp.setInt(key, value);
    } else if (value is String) {
      sp.setString(key, value);
    } else if (value is bool) {
      sp.setBool(key, value);
    } else if (value is double) {
      sp.setDouble(key, value);
    } else if (value is List<String>) {
      sp.setStringList(key, value);
    }
  }

  static get(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.get(key);
  }

  static Future<List<String>> getStringList(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getStringList(key);
  }

  static setStringListNull(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setStringList(key, null);
  }

  /*
  * 存在bug，类似的也会删除，列表不要使用
  * */
  static remove(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove(key);
    sp.clear();
  }
}

const String SEARCH_HISTORY = "search_history";
const String SEARCH_HOT_WORDS = "search_hotwords";
const String SEARCH_HOT_BOOKS = "search_hotbooks";
const String READ_HISTORY = "read_history";

class SpHelper {
  //主题
  static saveTheme(int index) {
    SpUtil.set("themeIndex", index);
  }

  static Future<dynamic> getTheme() {
    return SpUtil.get("themeIndex");
  }

  //阅读字体大小
  static saveFontSetting(double fontSize) {
    SpUtil.set("fontSize", fontSize);
  }

  static Future<dynamic> getFontSetting() {
    return SpUtil.get("fontSize");
  }

  //阅读间隙
  static saveSpaceSetting(double space) {
    SpUtil.set("space", space);
  }

  static Future<dynamic> getSpaceSetting() {
    return SpUtil.get("space");
  }

  //阅读背景图片
  static saveBackgroundSetting(int imgIndex) {
    SpUtil.set("readerBackground", imgIndex);
  }

  static Future<dynamic> getBackgroundSetting() {
    return SpUtil.get("readerBackground");
  }

  //存书架的书籍id列表
  /*
  * 单个存储颇为麻烦，建议bean转换json存储，不过好处是可以单个修改字段，bean需要整体替换
  * */
  static saveBookIntoShelf(BookData data) async {
    //先存id,存入列表中
    List<String> bookIdList = await SpUtil.getStringList("bookShelfList")??[];

    //更新为最新的
    if (!bookIdList.contains(data.bookId)) {
      bookIdList.add(data.bookId);
    }
    SpUtil.set("bookShelfList", bookIdList);
    //存源相关
    saveShelfBookChapterId(data.bookId, data.chapterId);
    saveBookSource(data.bookId, data.sourceId);
    //存列表相关
    SpUtil.set(data.bookId + "bookName", data.bookName??"");
    SpUtil.set(data.bookId + "lastUpdate", data.lastUpdate);
    if (data.coverUrl != null && data.coverUrl.isNotEmpty) {
      SpUtil.set(data.bookId + "coverUrl", data.coverUrl);
    }
    SpUtil.set(data.bookId + "lastChapterInfo", data.lastChapterInfo);
    SpUtil.set(data.bookId + "lastReadDate", data.lastReadDate);
    SpUtil.set(data.bookId + "isUpdate", data.isUpdate);
    if (data.isEnd != null) {
      SpUtil.set(data.bookId + "isEnd", data.isEnd);
    }
  }


  static clearBookInShelf(BookData data) async {
    List<String> bookIdList = await SpUtil.getStringList("bookShelfList")??[];
    //更新为最新的
    if (bookIdList.contains(data.bookId)) {
      bookIdList.remove(data.bookId);
      print(data.bookId + "chapterId");

      //源相关
      SpUtil.set(data.bookId + "chapterId",null);
      SpUtil.set(data.bookId + "sourceId",null);
      //列表相关
      SpUtil.set(data.bookId + "bookName",null);
      SpUtil.set(data.bookId + "lastUpdate",null);
      SpUtil.set(data.bookId + "coverUrl",null);
      SpUtil.set(data.bookId + "lastChapterInfo",null);
      SpUtil.set(data.bookId + "lastReadDate",null);
      SpUtil.set(data.bookId + "isUpdate",null);
      SpUtil.set(data.bookId + "isEnd",null);
    }

    SpUtil.set("bookShelfList", bookIdList);
  }

  static Future<List<BookData>> getBookShelfDatas() async {
    List<BookData> bookIdList = [];
    var list = await SpUtil.get("bookShelfList");
    for (String bookId in list ?? []) {
      BookData data = await getBookShelfData(bookId);
      bookIdList.add(data);
    }
    return bookIdList;
  }

  static Future<bool> isAddToShelf(String bookId) async {
    List<String> bookIdList = [];
    var list = await SpUtil.get("bookShelfList");
    for (String bookId in list ?? []) {
      bookIdList.add(bookId);
    }
    if (bookIdList.contains(bookId)) {
      return true;
    }
    return false;
  }

  static Future<BookData> getBookShelfData(String bookId) async {
    BookData data = BookData();
    data.bookId = bookId;
    //取源相关
    data.sourceId = await getBookSource(bookId);
    data.chapterId = await getShelfBookChapterId(bookId);
    //取列表相关
    data.bookName = await SpUtil.get(bookId + "bookName");
    data.lastUpdate = await SpUtil.get(bookId + "lastUpdate");
    data.coverUrl = await SpUtil.get(bookId + "coverUrl");
    data.lastChapterInfo = await SpUtil.get(bookId + "lastChapterInfo");
    data.lastReadDate = await SpUtil.get(bookId + "lastReadDate") ?? 0;
    data.isUpdate = await SpUtil.get(bookId + "isUpdate") ?? false;
    data.isEnd = await SpUtil.get(bookId + "isEnd");
    return data;
  }

  //书籍是否更新
  static saveShelfBookUpdate(BookData data) {
    SpUtil.set(data.bookId + "isUpdate", data.isUpdate);
  }

  //存储选择的源，和阅读的章节
  static saveBookSource(String bookId, String sourceId) {
    SpUtil.set(bookId + "sourceId", sourceId);
  }

  static Future<dynamic> getBookSource(String bookId) {
    return SpUtil.get(bookId + "sourceId");
  }

  //存章节
  static saveShelfBookChapterId(String articleId, int chapterId) {
    SpUtil.set(articleId + "chapterId", chapterId);
  }

  static Future<dynamic> getShelfBookChapterId(String articleId) {
    return SpUtil.get(articleId + "chapterId");
  }


}