import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double kMaxRate = 5.0;
const int kNumberOfStarts = 5;
const double kSize = 50.0;

/*
* 星星评分控件
* 原理： 先画5个暗的星星，然后在将画5个亮的星星进行裁剪，覆盖上去
* */
class RatingBar extends StatelessWidget {
  static List<String> ratingText = ["垃圾","亮瞎眼","值得一看","非常喜欢","必看神作"];
  /// 星星数量
  final int count;

  /// 评分多少（即相对count的大小）
  final double rate;

  /// 单个星星的大小
  final double size;
  final Color colorLight;
  final Color colorDark;

  RatingBar({count, double rate, size, colorLight, colorDark})
      : rate = rate ?? kMaxRate,
        count = count ?? kNumberOfStarts,
        size = size ?? kSize,
        colorDark = colorDark ?? new Color(0xffeeeeee),
        colorLight = colorLight ?? new Color(0xffFF962E);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        buildStar(colorDark),
        new ClipRect(
          clipper: _RatingBarClipper(width: rate * size),
          child: buildStar(colorLight),
        )
      ],
    );
  }

  Widget buildStar(Color color) {
    var stars = List.generate(
        count,
        (index) => SizedBox(
              width: size,
              height: size,
              child: Padding(
                padding: EdgeInsets.all(size/9),
                child: Image.asset(
                  'images/star.png',
                  color: color,
                ),
              ),
            ));
    return Row(
      children: stars,
    );
  }
}

class _RatingBarClipper extends CustomClipper<Rect> {
  final double width;

  _RatingBarClipper({this.width}) : assert(width != null);

  @override
  Rect getClip(Size size) {
    return new Rect.fromLTRB(0.0, 0.0, width, size.height);
  }

  @override
  bool shouldReclip(_RatingBarClipper oldClipper) {
    return width != oldClipper.width;
  }
}
