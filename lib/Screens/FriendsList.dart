import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubitStates.dart';
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
          print("conversationCubit is rebuild");
          ConversationsCubit conversationCubit =ConversationsCubit.get(context);
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
                              child: Icon((!conversationCubit.isSearch)?Icons.search:Icons.close, color: Color(0xffD1DFFD),
                              )
                          ),
                          onTap: () {
                            conversationCubit.changeSearchBarState();
                          },
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: (!conversationCubit.isSearch)?Container(
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
                                  conversationCubit.currentUser.name,
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
                                  conversationCubit.emptyTheSearchList();
                                }
                                else{
                                  await conversationCubit.getSearchedList(value);
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
                    child: (!conversationCubit.isSearch)?
                    StreamBuilder(
                      stream: conversationCubit.getStreamOfConversations(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          if(snapshot.data.docs.length==0){
                            return Container(child: Center(child: Text("NO CONVERSATIONS FOUND")));
                          }
                          else{
                            return ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return buildSingleConversation(conversationCubit, snapshot, index, context,ChatRoomCubit.get(context),AuthCubit.get(context));
                              },
                            );
                          }
                        }
                        else{
                          return Container(child: Center(child:CircularProgressIndicator()));
                        }

                      },
                    ) : (conversationCubit.searchList.length>0)?ListView.builder(
                      itemCount:  conversationCubit.searchList.length,
                      itemBuilder: (context, index) {
                        return buildSingleItemInSearchList(conversationCubit, index, context,AuthCubit.get(context),ChatRoomCubit.get(context));
                      },
                    ):Container(
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
