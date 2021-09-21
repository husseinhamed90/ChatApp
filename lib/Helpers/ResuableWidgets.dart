import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart' as intl;

InkWell buildSingleItemInSearchList(ConversationsCubit conversationsCubit, int index,
    BuildContext context,AuthCubit appCubit,ChatRoomCubit chatRoomCubit) {
  return InkWell(
    onTap: () {
      conversationsCubit.setChosenUser(conversationsCubit.searchList[index],chatRoomCubit);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(conversationsCubit.chosenUser.name,conversationsCubit.chosenUser.imagepath),));
      conversationsCubit.changeSearchBarState();
    },
    child: AutoSizeText(
      conversationsCubit.searchList[index].name,
      style: TextStyle(
          color: Color(0xff505664), fontSize: 18),maxLines: 1,
    ),
  );
}

Container buildMessageBody(List<Message> messages, int index, BuildContext context,ChatRoomCubit chatRoomCubit) {
  return Container(
    padding: EdgeInsets.all(5),
    child: Column(
      children: [
        Align(
          child: Text(messages[index].dateOfMassage,style: TextStyle(
            fontSize: 12,fontWeight: FontWeight.w600
          ),),
          alignment: Alignment.center,
        ),
        SizedBox(height: 5,),
        Row(
          textDirection: (messages[index].senderId==AuthCubit.get(context).currentUser.id)?TextDirection.rtl:TextDirection.ltr,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                 shape: BoxShape.circle
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    (messages[index].senderId==AuthCubit.get(context).currentUser.id)?chatRoomCubit.currentUser.imagepath:chatRoomCubit.chosenUser.imagepath,
                    fit: BoxFit.fill,)),
            ),
            SizedBox(width: 10,),
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
          ],
        ),
        // SizedBox(height: 5,),

      ],
    ),
  );
}

InkWell buildSingleConversation(ConversationsCubit conversationsCubit, AsyncSnapshot<dynamic> snapshot, int index,
    BuildContext context,ChatRoomCubit chatRoomCubit,AuthCubit appCubit) {

  DateTime lastMessageDate =DateTime.fromMillisecondsSinceEpoch(int.parse(Conversation.fromJson(snapshot.data.docs[index].data()).dateOfConversation));
  return InkWell(
    onTap: () {
      conversationsCubit.setChosenUser(Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson,chatRoomCubit,conversation: Conversation.fromJson(snapshot.data.docs[index].data()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(conversationsCubit.chosenUser.name,conversationsCubit.chosenUser.imagepath)));
    },
    child: Container(
      height: 70,
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
                    Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.name,
                    style: TextStyle(
                        color: Color(0xff505664), fontSize: 20,fontWeight: FontWeight.w700),maxLines: 1,
                  ),

                  (Conversation.fromJson(snapshot.data.docs[index].data()).istyping=="false")?Row(

                    children: [
                      Text(
                        Conversation.fromJson(snapshot.data.docs[index].data()).lastMassage,
                        style: TextStyle(
                            fontSize: 15, color: Color(0xff505664)),maxLines: 1,overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Text(
                        intl.DateFormat('yyyy-MM-dd – kk:mm').format(lastMessageDate),
                        style: TextStyle(
                            fontSize: 12, color: Color(0xff505664)),maxLines: 1,overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ):Text(
                    "typing...",
                    style: TextStyle(
                        fontSize: 16, color: Colors.green),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 20,),
          Container(
            height: 55,
            width:55,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Color(0xff3570EC),
                  width: 1,
                )),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                 Conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.imagepath,
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
      label: 'UNDO',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}