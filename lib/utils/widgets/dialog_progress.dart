import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DialogProgress extends StatelessWidget {
  DialogProgress({this.isLoading});
  final bool isLoading;

  Widget loading() {
    return Stack(
      children: <Widget>[
        new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: SpinKitThreeBounce(color: Color.fromRGBO(148, 3, 123, 1.0), size: 35.0,),
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