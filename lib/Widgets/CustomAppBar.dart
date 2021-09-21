// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  String title,userProfileImage;
  CustomAppbar({this.title, this.userProfileImage});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0xffE5F7FF),
      elevation: 0,
      // actions: [
      //   (userProfileImage!=null)?Row(
      //     children: [
      //       Container(
      //         margin: EdgeInsets.only(top: 5),
      //         height: 45,
      //         width: 45,
      //         decoration: BoxDecoration(
      //             shape: BoxShape.circle
      //         ),
      //         child: ClipRRect(
      //             borderRadius: BorderRadius.circular(40),
      //             child: Image.network(
      //               userProfileImage,
      //               fit: BoxFit.fill,)),
      //       ),
      //     ],
      //   ):Container(),
      //   SizedBox(width: 10,),
      // ],
      title: AutoSizeText(title,style: TextStyle(fontSize: 20,color: Colors.blue),maxLines: 1,),
      leading:    InkWell(onTap: () {
        Navigator.pop(context);
      },child: Container(child: Icon(Icons.arrow_back_rounded,size: 30,color: Colors.blue,),)
      ),
    );
  }
}
