import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zhuishu/ui/base/my_color.dart';

class CoverImage extends StatelessWidget {
  final String imgUrl;
  final double width;
  final double height;

  CoverImage(this.imgUrl, {this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: buildSizeWidget(
          width: width,
          height: height,
          child: CupertinoActivityIndicator(
            radius: 15.0,
          ),
        ),
        errorWidget: buildSizeWidget(
          height: height,
          width: width,
          child: Icon(Icons.error),
        ),
      ),
      decoration: BoxDecoration(border: Border.all(color: MyColor.paper)),
    );
  }

  buildSizeWidget({double width, double height, Widget child}) {
    return Container(
        width: width,
        height: height,
        child: Center(
          child: child,
        ));
  }
}
