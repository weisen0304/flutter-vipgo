import 'package:flutter/material.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';

class CommonButton extends StatefulWidget {
  final double height;
  final String text;
  final GestureTapCallback onTap;

  CommonButton({@required this.text, @required this.height, @required this.onTap});

  @override
  State<StatefulWidget> createState() => CommonButtonState();
}

class CommonButtonState extends State<CommonButton> {
  Color color = ThemeUtils.currentColorTheme;
  TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        this.widget.onTap();
      },
      child: Container(
        height: this.widget.height,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(color: const Color(0xffcccccc)),
            borderRadius: BorderRadius.all(Radius.circular(this.widget.height / 2))),
        child: Center(
          child: Text(
            this.widget.text,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
