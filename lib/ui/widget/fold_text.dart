/*
* 可折叠的文本控件
* */
import 'package:flutter/material.dart';
import 'package:zhuishu/util/screen.dart';

class FoldTextView extends StatefulWidget {
  final String str;
  @override
  _FoldTextViewState createState() => _FoldTextViewState();

  FoldTextView(this.str);
}

class _FoldTextViewState extends State<FoldTextView> {
  bool isUnfold = false;
  bool isShow = true;
  @override
  void initState() {
    if(widget.str.length > 50){
      double width = Screen.width - 30.0;
      //计算是否需要折叠
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text =
          TextSpan(text: widget.str, style: TextStyle(fontSize: 14,color: Colors.grey),);
      textPainter.layout(maxWidth: width);
      //获取占满这个区域的String的最后一个字符的index(第几个就返回几)
      int end = textPainter.getPositionForOffset(Offset(width, 50.0)).offset;
      if(widget.str.length <= end) {
        isShow = false;
      }
    }else{
      isShow = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    Widget text = Text(
      widget.str,
      maxLines: isUnfold ? null : 3,
      overflow: isUnfold ? null : TextOverflow.ellipsis,
      style: TextStyle(fontSize: 14,color: Colors.grey),
    );
    list.add(text);
    if(isShow){
      list.add(Icon(isUnfold? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey,),);
    }

    return GestureDetector(
      onTap: (){
        if(!isShow) return;
        setState(() {
          isUnfold = !isUnfold;
        });
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: list,
      ),
    );
  }
}

