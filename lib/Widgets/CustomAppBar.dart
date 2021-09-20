// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  String title;

  CustomAppbar([this.title]);

  @override
  Widget build(BuildContext context) {
    return AppBar(

      backgroundColor: Color(0xffE5F7FF),
      elevation: 0,
      title:   AutoSizeText(title,style: TextStyle(fontSize: 20,color: Colors.blue),maxLines: 1,),
      leading:    InkWell(onTap: () {
        Navigator.pop(context);
      },child: Container(child: Icon(Icons.arrow_back_rounded,size: 30,color: Colors.blue,),)
      ),
      centerTitle: true,
    );
  }

}
