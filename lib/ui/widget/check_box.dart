import 'package:flutter/material.dart';

class RoundCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  _RoundCheckboxState createState() => _RoundCheckboxState();

  RoundCheckbox({
    Key key,
    @required this.value,
    @required this.onChanged,
  }) : super(key: key);
}

class _RoundCheckboxState extends State<RoundCheckbox>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool isOver = true;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        isOver = true;
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(RoundCheckbox oldWidget) {
    if (widget.value == oldWidget.value) return;
    isOver = false;
    if (widget.value) {
      _controller.forward();
    } else {
      _controller.reverse();
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
    return InkWell(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: CustomPaint(
          foregroundPainter: CircleCustomPainter(Color(0x1f000000)),
          child: buildCheck()),
    );
  }

  Widget buildCheck() {
    return FadeTransition(
      opacity: _controller,
      child: CustomPaint(
        painter: CheckCustomPainter(Colors.red),
        size: Size(20,20),
      ),
    );
  }
}

class CheckCustomPainter extends CustomPainter {
  Color color;
  Paint _paint;
  Paint _checkPaint;
  Path _path;

  CheckCustomPainter(this.color) {
    _paint = Paint()
      ..color = color;

    _checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round  //圆形尖角
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke; //默认填充

    _path = Path();

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width *0.5;
    final baseY = size.height *0.5;
    double lineWidth = 0.4 * size.width;
    double space = 0.2 * size.width;
    //画背景圆
    canvas.drawCircle(Offset(baseX, baseY), baseX, _paint);
    //画√
    _path.moveTo(baseX - lineWidth *0.5, baseY);
    _path.lineTo(baseX - lineWidth *0.2, baseY + space * 0.5);
    _path.lineTo(baseX + lineWidth *0.5, baseY - space*0.75);
    canvas.drawPath(_path, _checkPaint);
  }
}

class CircleCustomPainter extends CustomPainter {
  Color color;
  Paint _paint;

  CircleCustomPainter(this.color) {
    _paint = Paint()
      ..strokeWidth = 1.0
      ..color = color
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke; //默认填充
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width *0.5;
    final baseY = size.height *0.5;
    //画圆
    canvas.drawCircle(Offset(baseX, baseY), baseX, _paint);
  }
}
