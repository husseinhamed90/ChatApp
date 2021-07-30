import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import '../MainCubit/AppCubit.dart';
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

  List<String > ss=[];
  Timer timer;

  Stream<String>stream;

  @override
  void initState() {
    stream=Stream<String>.periodic(Duration(seconds: 1), (t) => _getTime());
    super.initState();
  }
  String _getTime() {
    ss= DateFormat.yMEd().add_jms().format(DateTime.now()).split(' ');
    String last =ss[1].split('/')[1]+"/"+ss[1].split('/')[0]+"/"+ss[1].split('/')[2]+" - "+ss[2];
    List<String>ff=last.split('-');

    return ff[1]+" - "+ff[0];
  }
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        InkWell(onTap: () {
          Navigator.pop(context);
        },child: Container(child: Image.asset("assets/backbutton.jpg",),margin: EdgeInsets.only(left: 10,top: 10),)),

      ],
      backgroundColor: Colors.white,
      elevation: 0,
      title:   AutoSizeText(widget.title,style: TextStyle(fontSize: 25,color: Colors.black),maxLines: 1,),
      leading:  Container(
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
        },child: Container(child: Image.asset("assets/exit.jpg",),margin: EdgeInsets.only(right: 10,top: 5),)),
      ),
      centerTitle: true,

    );
  }
  Future<void> updateuserstatus(String newstatus) {
    List<user> userss = [];
    FirebaseFirestore.instance.collection("Users").where("id", isEqualTo:AppCubit.get(context).currentuser.id).get().then((value) {
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
