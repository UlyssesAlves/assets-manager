import 'package:flutter/material.dart';

class SimpleButtonWithIcon extends StatelessWidget {
  SimpleButtonWithIcon(
    this.text,
    this.icon,
    this.onPressed, {
    this.foregroundColor = Colors.white,
    this.backgroundColor = const Color.fromARGB(255, 33, 136, 255),
    this.padding = const EdgeInsets.all(8.0),
  });

  final Widget icon;
  final Function()? onPressed;
  final String text;
  Color? foregroundColor;
  Color? backgroundColor;
  EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(text),
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        padding: MaterialStatePropertyAll(padding),
        foregroundColor: MaterialStatePropertyAll(foregroundColor),
        backgroundColor: MaterialStatePropertyAll(backgroundColor),
      ),
    );
  }
}
