import 'package:flutter/material.dart';
import 'package:promociones/utils/options.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  NavBar({this.title});
  final String title;

  @override
  Size get preferredSize => new Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: primaryColor,
    );
  }
}
