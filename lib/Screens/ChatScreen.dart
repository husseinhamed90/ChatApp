
import 'dart:async';

import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Massage.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../MainCubit/AppCubit.dart';
import '../Widgets/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatScreen extends StatelessWidget {
  String receiver;
  String name;
  ChatScreen(this.receiver,this.name);
  final _controller = ScrollController();

  TextEditingController controller=new TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppbar(name),
        preferredSize: Size.fromHeight(70),
      ),
      body:BlocConsumer<AppCubit,AppCubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          AppCubit appCubit =AppCubit.get(context);
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffE5F7FF), Color(0xffFFFFFF)])),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: CombineLatestStream.list([
                        if(appCubit.currentConversation!=null)
                          FirebaseFirestore.instance.collection("Conversations").doc(appCubit.currentConversation.conversationId).snapshots()
                      ]),
                      builder: (context, snapshot) {
                        if(_controller.hasClients){
                          _controller.jumpTo(_controller.position.maxScrollExtent);

                        }

                        if(snapshot.hasData){

                          DocumentSnapshot sender=snapshot.data[0];
                          List<Massage>messages=[];
                          sender.data()["Messages"].forEach((element){
                             messages.add(Massage.fromJson(element));
                          });


                          return ListView.builder(
                            controller: _controller,
                            itemBuilder: (context, index) {
                              messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
                              return Container(
                                child: Column(
                                  children: [
                                    Align(
                                      child: Text("${DateTime.fromMillisecondsSinceEpoch(int.parse(messages[index].timeStamp))}",style: TextStyle(
                                        fontSize: 15,
                                      ),),
                                      alignment: Alignment.center,
                                    ),
                                    Align(
                                      child:  Card(child: Text(messages[index].massage,style: TextStyle(
                                        fontSize: 20,
                                      ),),),
                                      alignment: (messages[index].senderId==AppCubit.get(context).currentuser.id)?Alignment.centerRight:Alignment.centerLeft,
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: messages.length,
                          );
                        }
                        else{
                          return Container(
                            child: Center(child: Text("NO MESSAGES FOUND")),
                          );
                        }
                      }
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width-20)*0.8,
                      child: TextFormField(
                        controller: controller,
                        onTap: () {
                          _controller.jumpTo(_controller.position.maxScrollExtent);
                        },
                        onChanged: (value) async{

                          if(value.isEmpty==false){
                            if(appCubit.currentConversation!=null)
                              await FirebaseFirestore.instance.collection("Conversations").doc(appCubit.currentConversation.conversationId).update({"istyping": "true"});
                          }
                          else{
                            if(appCubit.currentConversation!=null)
                              await FirebaseFirestore.instance.collection("Conversations").doc(appCubit.currentConversation.conversationId).update({"istyping": "false"});
                          }
                        },
                        onFieldSubmitted: (value) async{
                        _controller.jumpTo(_controller.position.maxScrollExtent);
                        if(controller.text!="") {
                          await appCubit.sendMessage(controller.text, appCubit);
                        }},
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
                    Container(
                      alignment: Alignment.centerRight,
                      width: (MediaQuery.of(context).size.width-20)*0.2,
                      child: FloatingActionButton(onPressed: () async {
                       _controller.jumpTo(_controller.position.maxScrollExtent);
                        if(controller.text!=""){
                          await appCubit.sendMessage(controller.text,appCubit);
                        }
                      },child: Icon(Icons.send,),backgroundColor: Colors.blue,),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      )
    );
  }
}