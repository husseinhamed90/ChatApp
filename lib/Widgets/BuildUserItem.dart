import '../MainCubit/AppCubit.dart';
import '../Screens/ChatScreen.dart';
import 'package:flutter/material.dart';

import '../Models/User.dart';

class BuildUserItem extends StatefulWidget {
  user currentuser;
  AppCubit appCubit;
  int CurrentIndex;
  BuildUserItem(this.currentuser,this.appCubit,this.CurrentIndex);
  @override
  _BuildUserItemState createState() => _BuildUserItemState();
}

class _BuildUserItemState extends State<BuildUserItem> {
  @override
  Widget build(BuildContext context) {
    print(AppCubit.get(context).currentuser.id);
    return LayoutBuilder(
      builder: (context, constraints) => (widget.currentuser.id!=AppCubit.get(context).currentuser.id)?InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TestStream(widget.currentuser.id,widget.currentuser.name),));
        },
        child: Container(
          height: 50,
          width: constraints.maxWidth,
          margin: EdgeInsets.only(bottom: 10,top: 10,left: 10,right: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: (constraints.maxWidth-20)*0.5,
                        child: Text(
                          widget.currentuser.name,style: TextStyle(
                            fontSize: 22
                        ),),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                      width:  ((constraints.maxWidth-20)*0.3)*0.3,
                      child:(widget.currentuser.isonline=="true")?Icon(Icons.circle,color: Colors.green,size: ((constraints.maxWidth-20)*0.3)*0.3-((((constraints.maxWidth-20)*0.3)*0.3)*0.3)):Icon(Icons.circle,color: Colors.red,size: ((constraints.maxWidth-20)*0.3)*0.3-((((constraints.maxWidth-20)*0.3)*0.3)*0.3))
                  ),
                ],
              ),
            ],
          ),
        ),
      ):Container(),
    );
  }
}
