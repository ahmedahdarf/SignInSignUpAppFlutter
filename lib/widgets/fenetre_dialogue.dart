import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class FenetreDialog extends StatelessWidget {
  final String title,
      description,
      primaryBtnText,
      primaryBtnRoute,
      secondaryBtnText,
      secondaryBtnRoute;
  FenetreDialog(
      {@required this.title,
      @required this.description,
      @required this.primaryBtnText,
      @required this.primaryBtnRoute,
      this.secondaryBtnText,
      this.secondaryBtnRoute});
  static const double padding = 20.0;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(padding)),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.orange[500],
                      blurRadius: 4.0,
                      offset: const Offset(0.0, 5.0),
                      spreadRadius: 0),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 24.0,
                ),
                AutoSizeText(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 25),
                ),
                SizedBox(
                  height: 24.0,
                ),
                AutoSizeText(
                  description,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RaisedButton(
                  color: Colors.orange[500],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      primaryBtnText,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(primaryBtnRoute);
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                showSecondaryBtn(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  showSecondaryBtn(BuildContext context) {
    if (secondaryBtnText != null && secondaryBtnRoute != null) {
      return FlatButton(
        child: AutoSizeText(
          secondaryBtnText,
          maxLines: 1,
          style: TextStyle(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.w400),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(secondaryBtnRoute);
        },
      );
    } else {
      return SizedBox(
        height: 10.0,
      );
    }
  }
}
