// ignore_for_file: must_be_immutable

import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubitStates.dart';
import 'package:flutter/painting.dart';
import '../Helpers/ResuableWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsList extends StatelessWidget {

   TextEditingController controller =new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocConsumer<ConversationsCubit,ConversationsCubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          ConversationsCubit conversationCubit =ConversationsCubit.get(context);
          return SafeArea(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffE5F7FF), Color(0xffFFFFFF)])),
              child: Column(
                children: [

                  Container(
                    height: 60,
                    width: double.infinity,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(

                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon((!conversationCubit.isSearch)?Icons.search:Icons.close, color: Color(0xffD1DFFD),
                              )
                          ),
                          onTap: () {
                            conversationCubit.changeSearchBarState();
                          },
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: (!conversationCubit.isSearch)?Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(40),
                                          border: Border.all(
                                            color: Color(0xff3570EC),
                                            width: 1.5,
                                          )
                                      ),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          child: Image.network(
                                            conversationCubit.currentUser.imagepath,
                                            fit: BoxFit.fill,)),
                                    ),
                                    SizedBox(width: 15,),
                                    Text(
                                      conversationCubit.currentUser.name,
                                      style: TextStyle(
                                          color: Color(0xff3570EC), fontSize: 25,fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ):Container(
                            height: 50,
                            child: TextFormField(
                              onChanged: (value) async{
                                if(value==""){
                                  conversationCubit.emptyTheSearchList();
                                }
                                else{
                                  await conversationCubit.getSearchedList(value);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "Enter Username",
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
                    child: (!conversationCubit.isSearch)?
                    StreamBuilder(
                      stream: conversationCubit.getStreamOfConversations(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          if(snapshot.data.docs.length==0){
                            return Container(child: Center(child: Text("NO CONVERSATIONS FOUND")));
                          }
                          else{
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  return buildSingleConversation(conversationCubit, snapshot, index, context,ChatRoomCubit.get(context),AuthCubit.get(context));
                                },
                              ),
                            );
                          }
                        }
                        else{
                          return Container(child: Center(child:CircularProgressIndicator()));
                        }

                      },
                    ) :
                      (conversationCubit.searchList.length>0)?
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          itemCount:  conversationCubit.searchList.length,
                          itemBuilder: (context, index) {
                            return buildSingleItemInSearchList(conversationCubit, index, context,AuthCubit.get(context),ChatRoomCubit.get(context));
                          },
                        ),
                      ): Container(
                        child: Center(
                          child: Text("NO USERS FOUND WITH THIS NAME"),
                        ),
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
