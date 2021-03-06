// ignore_for_file: must_be_immutable

import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomStates.dart';
import 'package:chatapp/Helpers/ResuableWidgets.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Widgets/CustomAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  String name;
  bool isFromNotification=false;
  ChatScreen(this.name,{this.isFromNotification});

  TextEditingController controller=new TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppbar(title: name,isFromNotification: isFromNotification),
        preferredSize: Size.fromHeight(65),
      ),
      body:BlocConsumer<ChatRoomCubit,ChatRoomCubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          ChatRoomCubit chatRoomCubit =ChatRoomCubit.get(context);
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffE5F7FF), Color(0xffFFFFFF)])),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: chatRoomCubit.streamOfMessages(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          if(snapshot.data.docs.length==0){
                            return Container(
                              child: Center(child: Text("NO MESSAGES IN THIS CONVERSATION",style: TextStyle(
                                fontSize: 15
                              ),)),
                            );
                          }
                          else{
                            List<Message>messages=chatRoomCubit.getListOfMessages(snapshot.data);
                            return RefreshIndicator(
                              onRefresh:() async =>  chatRoomCubit.increasePageSize(),
                              child: ListView.builder(
                                itemBuilder: (context, index) => buildMessageBody(messages, index, context,chatRoomCubit),
                                itemCount: messages.length,
                              ),
                            );
                          }
                        }
                        else{
                          return Container(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      }
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: (MediaQuery.of(context).size.width-20)*0.8,
                      child: TextFormField(
                        controller: controller,
                        onChanged: (value) async{
                          if(value.isEmpty==false){
                            if(chatRoomCubit.currentConversation!=null){
                              await chatRoomCubit.changeTypingState(true);
                            }
                          }
                          else{
                            if(chatRoomCubit.currentConversation!=null){
                              await chatRoomCubit.changeTypingState(false);
                            }
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Enter Message",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 1),borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: (MediaQuery.of(context).size.width-20)*0.05,),
                    Container(
                      height: 50,
                      alignment: Alignment.centerRight,
                      width: (MediaQuery.of(context).size.width-20)*0.15,
                      child: FloatingActionButton(onPressed: () async {
                        if(controller.text!=""){
                          chatRoomCubit.sendMessage(controller.text);
                          controller.text="";
                        }
                      },child: Icon(Icons.send,size:15,),backgroundColor: Colors.blue,),
                    )
                  ],
                ),
                SizedBox(height:10),
              ],
            ),
          );
        },
      )
    );
  }
}