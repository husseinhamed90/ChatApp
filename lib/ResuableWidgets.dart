import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatapp/MainCubit/AppCubit.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:flutter/material.dart';

InkWell buildSingleItemInSearchList(AppCubit appCubit, int index, BuildContext context) {
  return InkWell(
    onTap: () {
      appCubit.setChosenUser(appCubit.searchlist[index]);
      appCubit.resetCurrentConversation();
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(appCubit.chosenUser.name),));
      appCubit.changesearchbarState();
    },
    child: AutoSizeText(
      appCubit.searchlist[index].name,
      style: TextStyle(
          color: Color(0xff505664), fontSize: 18),maxLines: 1,
    ),
  );
}

InkWell buildSingleConversation(AppCubit appCubit, AsyncSnapshot<dynamic> snapshot, int index, BuildContext context) {
  return InkWell(
    onTap: () {
      appCubit.resetPageSize();
      appCubit.setChosenUser(conversation.fromJson(snapshot.data.docs[index].data()).secondPerson);
      appCubit.setCurrentConversation(conversation.fromJson(snapshot.data.docs[index].data()));
      if(conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.id==appCubit.currentuser.id){
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatScreen(conversation.fromJson(snapshot.data.docs[index].data()).firstPerson.name,)));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            ChatScreen( conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.name,)));
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
                    (conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.id==appCubit.currentuser.id)?
                    conversation.fromJson(snapshot.data.docs[index].data()).firstPerson.name : conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.name,
                    style: TextStyle(
                        color: Color(0xff505664), fontSize: 18),maxLines: 1,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  (  conversation.fromJson(snapshot.data.docs[index].data()).istyping=="false")?Text(
                    conversation.fromJson(snapshot.data.docs[index].data()).lastMassage,
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
                  (conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.id==appCubit.currentuser.id)?
                  conversation.fromJson(snapshot.data.docs[index].data()).firstPerson.imagepath: conversation.fromJson(snapshot.data.docs[index].data()).secondPerson.imagepath,
                  fit: BoxFit.fill,)),
          )
        ],
      ),
    ),
  );
}

Widget getsnackbar(BuildContext context,String message){
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