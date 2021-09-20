import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:flutter/material.dart';

InkWell buildSingleItemInSearchList(ConversationsCubit conversationsCubit, int index,
    BuildContext context,AuthCubit appCubit,ChatRoomCubit chatRoomCubit) {
  return InkWell(
    onTap: () {
      conversationsCubit.setChosenUser(conversationsCubit.searchList[index],chatRoomCubit);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(conversationsCubit.chosenUser.name),));
      conversationsCubit.changeSearchBarState();
    },
    child: AutoSizeText(
      conversationsCubit.searchList[index].name,
      style: TextStyle(
          color: Color(0xff505664), fontSize: 18),maxLines: 1,
    ),
  );
}

Container buildMessageBody(List<Message> messages, int index, BuildContext context) {
  return Container(
    padding: EdgeInsets.all(5),
    child: Column(
      children: [
        Align(
          child: Text("${DateTime.fromMillisecondsSinceEpoch(int.parse(messages[index].timeStamp))}",style: TextStyle(
            fontSize: 12,
          ),),
          alignment: Alignment.center,
        ),
        SizedBox(height: 5,),
        Align(
          alignment: (messages[index].senderId==AuthCubit.get(context).currentUser.id)?Alignment.centerRight:Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(messages[index].massage,style: TextStyle(
                fontSize: 14,color: Colors.white,fontWeight: FontWeight.w600
            ),),
          ),
        ),
        // SizedBox(height: 5,),

      ],
    ),
  );
}

InkWell buildSingleConversation(ConversationsCubit conversationsCubit, AsyncSnapshot<dynamic> snapshot, int index,
    BuildContext context,ChatRoomCubit chatRoomCubit,AuthCubit appCubit) {
  return InkWell(
    onTap: () {

      conversationsCubit.setChosenUser(Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson,chatRoomCubit,conversation: Conversation.fromJson(snapshot.data.docs[index].data()));
     // conversationsCubit.setCurrentConversation(Conversation.fromJson(snapshot.data.docs[index].data()),chatRoomCubit,appCubit);
      if(Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.id==conversationsCubit.currentUser.id){
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatScreen(Conversation.fromJson(snapshot.data.docs[index].data()).firstPerson.name,)));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatScreen( Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.name,)));
      }
    },
    child: Container(
      height: 80,
      width: double.infinity,
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    (Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.id==conversationsCubit.currentUser.id)?
                    Conversation.fromJson(snapshot.data.docs[index].data()).firstPerson.name : Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.name,
                    style: TextStyle(
                        color: Color(0xff505664), fontSize: 18),maxLines: 1,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  (  Conversation.fromJson(snapshot.data.docs[index].data()).istyping=="false")?Text(
                    Conversation.fromJson(snapshot.data.docs[index].data()).lastMassage,
                    style: TextStyle(
                        fontSize: 18, color: Color(0xff505664)),maxLines: 1,overflow: TextOverflow.ellipsis,
                  ):Text(
                    "typing...",
                    style: TextStyle(
                        fontSize: 18, color: Colors.green),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 20,),
          Container(
            height: 60,
            width:60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Color(0xff3570EC),
                  width: 1.5,
                )),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  (Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.id==conversationsCubit.currentUser.id)?
                  Conversation.fromJson(snapshot.data.docs[index].data()).firstPerson.imagepath: Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.imagepath,
                  fit: BoxFit.fill,)),
          )
        ],
      ),
    ),
  );
}

void getSnackBar(BuildContext context,String message){
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'تراجع',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}