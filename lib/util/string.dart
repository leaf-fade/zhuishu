/*
* 处理String字符串修正
* */

class StringAmend{

  //处理uri地址， 主要是图片的， 修正网络图片地址
  static String imgUriAmend(String imgUri){
     return imgUri.replaceAll("%3A", ":").replaceAll("%2F", "/").replaceAll("%3F", "?").replaceAll("%3D", "=").replaceAll("/agent/", "");
  }

  //url 编码
  static String urlEncode(String url){
    return url.replaceAll(":", "%3A").replaceAll("/","%2F").replaceAll("?", "%3F").replaceAll("=", "%3D");
  }

  //数字转化字符串，大于100 以万结束而大于100万以亿结束，保留2位小数
  static String numAmend(int num,{int digit = 2}){
    if(num >= 1000000){
      double newNum = num / 100000000;
      return "${newNum.toStringAsFixed(digit)}亿";
    }
    if(num >= 100){
      double newNum = num / 10000;
      return "${newNum.toStringAsFixed(digit)}万";
    }
    return "$num";
  }

  //数字转化字符串，大于10000 以万结束而大于10000万以亿结束，不保留小数
  static String numAmendInt(int num){
    if(num >= 100000000){
      double newNum = num / 100000000;
      return "${newNum.toStringAsFixed(0)}亿";
    }
    if(num >= 10000){
      double newNum = num / 10000;
      return "${newNum.toStringAsFixed(0)}万";
    }
    return "$num";
  }

  //转换时间
  static String getTimeDurationWithDate(DateTime compareTime) {
    var nowTime = DateTime.now();
    if (nowTime.isAfter(compareTime)) {
      if (nowTime.year == compareTime.year) {
        if (nowTime.month == compareTime.month) {
          if (nowTime.day == compareTime.day) {
            if (nowTime.hour == compareTime.hour) {
              if (nowTime.minute == compareTime.minute) {
                return '片刻之间';
              }
              return (nowTime.minute - compareTime.minute).toString() + '分钟前';
            }
            return (nowTime.hour - compareTime.hour).toString() + '小时前';
          }
          return (nowTime.day - compareTime.day).toString() + '天前';
        }
        return (nowTime.month - compareTime.month).toString() + '月前';
      }
      return (nowTime.year - compareTime.year).toString() + '年前';
    }
    return 'time error';
  }
  //转换时间
  static String getTimeDuration(String comTime) {
    var compareTime = DateTime.parse(comTime);
    return getTimeDurationWithDate(compareTime);
  }

  //获取时间格式 小时(24进制)：分钟
  static String getNowNormalTime(){
    var now = DateTime.now();
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }
    return "${twoDigits(now.hour)}:${twoDigits(now.minute)}";
  }


}