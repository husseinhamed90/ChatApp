import 'package:chatapp/MainCubit/AppCubit.dart';
import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/ResuableWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsList extends StatelessWidget {

   TextEditingController controller =new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocConsumer<AppCubit,AppCubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          AppCubit appCubit =AppCubit.get(context);
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffE5F7FF), Color(0xffFFFFFF)])),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 80,
                    width: double.infinity,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(

                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon((!appCubit.issearch)?Icons.search:Icons.close, color: Color(0xffD1DFFD),
                              )
                          ),
                          onTap: () {
                            appCubit.changesearchbarState();
                          },
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: (!appCubit.issearch)?Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello",
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0xff8FAEF1)),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  AppCubit.get(context).currentuser.name,
                                  style: TextStyle(
                                      color: Color(0xff3570EC), fontSize: 28),
                                )
                              ],
                            ),
                          ):Container(
                            height: 45,
                            child: TextFormField(
                              onChanged: (value) async{
                                if(value==""){
                                  appCubit.emptythesearchlist();
                                }
                                else{
                                  await appCubit.getsearchedlist(value);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "Enter User Name",
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blue, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: (!appCubit.issearch)?
                    StreamBuilder(
                      stream: appCubit.getStreamOfConversations(appCubit),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return buildSingleConversation(appCubit, snapshot, index, context);
                            },
                          );
                        }
                        else{
                          return Container(child: Center(child: Text("NO CONVERSATIONS FOUND")));
                        }

                      },
                    ) : ListView.builder(
                      itemCount:  appCubit.searchlist.length,
                      itemBuilder: (context, index) {
                        return buildSingleItemInSearchList(appCubit, index, context);
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
