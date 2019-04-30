import 'package:flutter/material.dart';
/*
* 纵向可拖动滚动条, 滑块不消失，可反向
* 
* */

/// 滑块构造器
typedef Widget ScrollThumbBuilder(
    Animation<double> thumbAnimation, double height);

/// 列表构造器
typedef Widget ListViewBuilder(
  int itemCount,
  IndexedWidgetBuilder itemBuilder,
);

class DraggableScrollbar extends StatefulWidget {
  final Key key;
  final bool reverse;
  final BoxScrollView child;
  final double heightScrollThumb;
  final ScrollThumbBuilder scrollThumbBuilder;
  final ScrollController controller;

  @override
  _DraggableScrollbarState createState() => _DraggableScrollbarState();

  DraggableScrollbar(
      {this.key,
      this.reverse,
      this.child,
      this.heightScrollThumb,
      this.scrollThumbBuilder,
      this.controller})
      : super(key: key);

  DraggableScrollbar.def(
      {this.key,
      this.reverse,
      this.child,
      this.heightScrollThumb,
      this.controller})
      : this.scrollThumbBuilder = _defaultBuilder(),
        super(key: key);

  static ScrollThumbBuilder _defaultBuilder() {
    return (Animation<double> thumbAnimation, double height) {
      return Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: CustomPaint(
          foregroundPainter: LineCustomPainter(Colors.grey[300]),
          child: Material(
            elevation: 4.0,
            child: Container(
              height: height,
              width: 20.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      );
    };
  }
}

class _DraggableScrollbarState extends State<DraggableScrollbar>
    with TickerProviderStateMixin {
  double _barOffset; //滑块的位置
  double _viewOffset; //列表中视图的位置
  bool _isDragInProcess;
  double saveBarMaxScrollExtent;
  double saveViewMaxScrollExtent;

  AnimationController _thumbAnimationController;
  Animation<double> _thumbAnimation;

  @override
  void initState() {
    _barOffset = 0.0;
    _viewOffset = 0.0;
    _isDragInProcess = false;

    _thumbAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _thumbAnimation = CurvedAnimation(
      parent: _thumbAnimationController,
      curve: Curves.fastOutSlowIn,
    );
    saveLength();
    super.initState();
  }

  saveLength() {
    //当界面已渲染完
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      saveBarMaxScrollExtent = barMaxScrollExtent;
      saveViewMaxScrollExtent = viewMaxScrollExtent;
    });
  }

  @override
  void dispose() {
    _thumbAnimationController.dispose();
    super.dispose();
  }

  double get barMaxScrollExtent =>
      context.size.height - widget.heightScrollThumb;

  double get barMinScrollExtent => 0.0;

  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;

  double get viewMinScrollExtent => widget.controller.position.minScrollExtent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          changePosition(notification);
        },
        child: Stack(
          children: <Widget>[
            RepaintBoundary(
              child: widget.child,
            ),
            RepaintBoundary(
                child: GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(
                    top: widget.reverse
                        ? saveBarMaxScrollExtent - _barOffset
                        : _barOffset),
                child: widget.scrollThumbBuilder(
                  _thumbAnimation,
                  widget.heightScrollThumb,
                ),
              ),
            )),
          ],
        ),
      );
    });
  }

  changePosition(ScrollNotification notification) {
    if (_isDragInProcess) {
      return;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _barOffset += getBarDelta(
          notification.scrollDelta,
          barMaxScrollExtent,
          viewMaxScrollExtent,
        );

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        _viewOffset += notification.scrollDelta;
        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
      }

      if (notification is ScrollUpdateNotification ||
          notification is OverscrollNotification) {
        if (_thumbAnimationController.status != AnimationStatus.forward) {
          _thumbAnimationController.forward();
        }
      }
    });
  }

  double getBarDelta(
    double scrollViewDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {
    return scrollViewDelta * barMaxScrollExtent / viewMaxScrollExtent;
  }

  double getScrollViewDelta(
    double barDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {
    return barDelta * viewMaxScrollExtent / barMaxScrollExtent;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragInProcess = true;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_thumbAnimationController.status != AnimationStatus.forward) {
        _thumbAnimationController.forward();
      }
      if (_isDragInProcess) {
        if (widget.reverse) {
          _barOffset -= details.delta.dy;
        } else {
          _barOffset += details.delta.dy;
        }

        if (_barOffset < barMinScrollExtent) {
          _barOffset = barMinScrollExtent;
        }
        if (_barOffset > barMaxScrollExtent) {
          _barOffset = barMaxScrollExtent;
        }

        double viewDelta = getScrollViewDelta(
            details.delta.dy, barMaxScrollExtent, viewMaxScrollExtent);

        if (widget.reverse) {
          _viewOffset = widget.controller.position.pixels - viewDelta;
        } else {
          _viewOffset = widget.controller.position.pixels + viewDelta;
        }

        if (_viewOffset < widget.controller.position.minScrollExtent) {
          _viewOffset = widget.controller.position.minScrollExtent;
        }
        if (_viewOffset > viewMaxScrollExtent) {
          _viewOffset = viewMaxScrollExtent;
        }
        widget.controller.jumpTo(_viewOffset);
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragInProcess = false;
    });
  }
}

class LineCustomPainter extends CustomPainter {
  Color color;
  Paint _paint;

  LineCustomPainter(this.color) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = size.width / 2;
    final baseY = size.height / 2;
    double lineWidth = 10.0;
    double space = 6.0;
    canvas.drawLine(Offset(baseX - lineWidth / 2, baseY - space),
        Offset(baseX + lineWidth / 2, baseY - space), _paint);
    canvas.drawLine(Offset(baseX - lineWidth / 2, baseY),
        Offset(baseX + lineWidth / 2, baseY), _paint);
    canvas.drawLine(Offset(baseX - lineWidth / 2, baseY + space),
        Offset(baseX + lineWidth / 2, baseY + space), _paint);
  }
}
