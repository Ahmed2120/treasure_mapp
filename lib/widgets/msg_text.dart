import 'package:flutter/material.dart';


class MsgText extends StatelessWidget {
  const MsgText({
    required this.msg,
    Key? key,
  }) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(msg, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF827773).withOpacity(0.7))));
  }
}