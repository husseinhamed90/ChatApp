// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  String title;
  bool isFromNotification=false;
  CustomAppbar({this.title,this.isFromNotification=false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0xffE5F7FF),
      elevation: 0,
      title: AutoSizeText(title,style: TextStyle(fontSize: 20,color: Colors.blue),maxLines: 1,),
      leading: InkWell(onTap: () {

        if(isFromNotification!=null){
          if(isFromNotification){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FriendsList()));
          }
          else
            Navigator.pop(context);
        }
        else{
          Navigator.pop(context);

        }

      },child: Container(child: Icon(Icons.arrow_back_rounded,size: 30,color: Colors.blue,),)
      ),
    );
  }
}
