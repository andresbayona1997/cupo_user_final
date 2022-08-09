import 'package:flutter/material.dart';
import 'package:promociones/utils/options.dart';

class DialogCircularProgress extends StatelessWidget {
  DialogCircularProgress({this.isLoading});
  final bool isLoading;

  Widget loading() {
    return Stack(
      children: <Widget>[
        new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: CircularProgressIndicator(
              value: null,
              valueColor: AlwaysStoppedAnimation(primaryColor),
          ),
        ),
      ]
    );
  }

  Widget notLoading() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? loading() : notLoading();
  }
}