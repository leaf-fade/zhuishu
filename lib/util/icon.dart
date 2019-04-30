

import 'package:flutter/material.dart';

Widget buildIcon({IconData icon, VoidCallback onTap, Color color}) {
  return GestureDetector(
    child: Container(
      child: Icon(
        icon,
        size: 25.0,
        color: color,
      ),
    ),
    onTap: onTap,
  );
}