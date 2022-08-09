import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;
  final colorBtn;
  final bool isLoading;

  const CircleButton({Key key, this.onTap, this.iconData, this.colorBtn, this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 50.0;

    return new InkResponse(
      onTap: isLoading ? null : onTap,
      child: new Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
          color: this.colorBtn != null ? this.colorBtn : Colors.white,
          shape: BoxShape.circle,
        ),
        child: new Icon(
          iconData,
          color: Colors.white,
        ),
      ),
    );
  }
}