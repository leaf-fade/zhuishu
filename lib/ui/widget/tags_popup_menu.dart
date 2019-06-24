import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zhuishu/util/text.dart';

const int duration = 300;

class TagsButton extends StatelessWidget {
  final String text;
  final bool rotated;
  final VoidCallback onPressed;

  TagsButton({this.text, this.onPressed, this.rotated = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            TextUtil.build(text),
            RotateContainer(
              endAngle: pi,
              rotated: rotated,
              child: CustomPaint(
                painter: TrianglePainter(Colors.grey),
                child: SizedBox(
                  width: 12,
                  height: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}

class RotateContainer extends StatefulWidget {
  final double endAngle;
  final bool rotated;
  final Widget child;

  @override
  _RotateContainerState createState() => _RotateContainerState();

  RotateContainer({this.endAngle, this.child, this.rotated = false});
}

/*
* 中心处旋转动画，AnimatedContainer针对的是左上角的旋转，注意角度传递的是π
* */
class _RotateContainerState extends State<RotateContainer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double angle = 0;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: duration));
    _animation =
        Tween(begin: 0.0, end: widget.endAngle).animate(_controller)
          ..addListener(() {
            setState(() {
              angle = _animation.value;
            });
          });
    super.initState();
  }



  @override
  void didUpdateWidget(RotateContainer oldWidget) {
    if (oldWidget.rotated == widget.rotated) return;
    if (!widget.rotated) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: widget.child,
    );
  }
}

/*
* 画个三角形
* */
class TrianglePainter extends CustomPainter {
  Color color;
  Paint _paint;
  Path _path;
  double angle;

  TrianglePainter(this.color) {
    _paint = Paint()
      ..strokeWidth = 1.0
      ..color = color
      ..isAntiAlias = true;

    _path = Path();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width * 0.5;
    final baseY = size.height * 0.5;
    //三角形
    _path.moveTo(baseX - 0.86 * baseX, 0.5 * baseY);
    _path.lineTo(baseX, 1.5 * baseY);
    _path.lineTo(baseX + 0.86 * baseX, 0.5 * baseY);
    canvas.drawPath(_path, _paint);
  }
}

void showPopupMenu(context, content){
  showBottomSheet(context: context, builder: (_){
    return content;
  });
}

/*
* 淡出菜单
* */
class TagsPopupMenu extends StatefulWidget {
  final bool showed;
  final Widget child;
  @override
  _TagsPopupMenuState createState() => _TagsPopupMenuState();

  TagsPopupMenu({this.showed,this.child});
}


class _TagsPopupMenuState extends State<TagsPopupMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double offset;
  double oldOffset = 0;
  double initHeight;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: duration));
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(_animation==null){
        initHeight = context.size.height;
        offset = initHeight+50;
        _animation =
            Tween(begin: initHeight+50, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.linear))
              ..addListener(offsetChange);
        setState(() {});
      }
    });
    super.initState();
  }

  void offsetChange(){
    setState(() {
      offset = _animation.value;
    });
  }

  @override
  void didUpdateWidget(TagsPopupMenu oldWidget) {
    if (oldWidget.showed == widget.showed) return;

    if (!widget.showed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return offset != null ? Transform.translate(
      offset: Offset(0, offset,),
      child: widget.child,
    ): Container();
  }
}

