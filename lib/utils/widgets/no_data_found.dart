import 'package:flutter/material.dart';
import 'package:promociones/utils/options.dart';

class NoDataFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 30.0, right: 20.0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.filter_drama, size: 70.0, color: primaryColor,),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('No se ha encontrado información', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700),),
            )
          ],
        ),
      ),
    );
  }
}