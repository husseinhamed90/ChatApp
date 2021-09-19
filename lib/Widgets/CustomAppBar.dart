import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomAppbar extends StatefulWidget {
  String title;

  DateTime currentdate;
  CustomAppbar([this.title,this.currentdate]);
  @override
  _AppbarState createState() => _AppbarState();
}

class _AppbarState extends State<CustomAppbar> {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Container(
          child: GestureDetector(onTap: () {

            showDialog(context: context, builder: (context) {
              return AlertDialog(
                content: Container(
                  child: Text("هل تريد اغلاق التطبيق ؟"),
                ),
                actions: [

                  TextButton(onPressed: () {
                    Navigator.pop(context);
                    updateuserstatus('false');
                  }, child: Text("نعم")),
                  TextButton(onPressed: () => Navigator.pop(context), child: Text("لا")),
                ],
              );
            },
            );
          },child: Container(child: Icon(Icons.close,size: 30,color: Colors.blue,),margin: EdgeInsets.only(right: 10),)),
        ),
      ],

      backgroundColor: Color(0xffE5F7FF),
      elevation: 0,
      title:   AutoSizeText(widget.title,style: TextStyle(fontSize: 20,color: Colors.blue),maxLines: 1,),
      leading:    InkWell(onTap: () {
        Navigator.pop(context);
      },child: Container(child: Icon(Icons.arrow_back_rounded,size: 30,color: Colors.blue,),)
      ),
      centerTitle: true,

    );
  }
  Future<void> updateuserstatus(String newstatus) {
    List<user> userss = [];
    FirebaseFirestore.instance.collection("Users").where("id", isEqualTo:AuthCubit.get(context).currentUser.id).get().then((value) {
      FirebaseFirestore.instance.collection("Users").doc(value.docs.first.id).update({'isonline': newstatus}).then((value) {
        if (newstatus == "true") {
          FirebaseFirestore.instance.collection("Users").get().then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              userss.add(user.fromJson(doc.data()));
            });
          }).catchError((error) {});
        } else {
          SystemNavigator.pop();
        }
      }).catchError((error) {
      });
    }).catchError((error) {});
  }
}
