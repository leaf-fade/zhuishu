import 'package:flutter/material.dart';

class PinnedTabBar extends StatefulWidget {
  const PinnedTabBar({
    Key key,
    @required this.tabStr,
    this.tabController,
    this.scrollController,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.onTap,
  }) : assert(tabStr != null),
        super(key: key);

  final TabController tabController;
  final ScrollController scrollController;
  final List<String> tabStr;
  final Color indicatorColor;
  final Color labelColor;
  final Color unselectedLabelColor;
  final ValueChanged<int> onTap;

  @override
  _PinnedTabBarState createState() => _PinnedTabBarState();
}

class _PinnedTabBarState extends State<PinnedTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
