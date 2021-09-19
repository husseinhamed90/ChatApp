import 'package:bloc/bloc.dart';
import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatRoomCubit extends Cubit<ChatRoomCubitStates> {

  ChatRoomCubit() : super(initialState());

  static ChatRoomCubit get(BuildContext context) => BlocProvider.of(context);

 user currentUser;
 CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
 user chosenUser;
 Conversation currentConversation;
 int pageSize=6;

 DocumentReference chosenUserChat() => usersCollection.doc(currentUser.id).collection("chats").doc(chosenUser.id);

 DocumentReference currentUserChat() => usersCollection.doc(chosenUser.id).collection("chats").doc(currentUser.id);

 Stream<QuerySnapshot> streamOfMessages() =>chosenUserChat().collection("Messages").orderBy("timeStamp").limitToLast(pageSize).snapshots();


 void setCurrentUser(user user){
   currentUser=user;
   emit(currentUserUpdated());
 }

  void setChosenUser(user user){
    chosenUser=user;
    emit(currentUserUpdated());
  }
 Future setChosenUserAndCurrentConversation(user chosen,Conversation conversation,AuthCubit appCubit)async{
   chosenUser=chosen;
   currentConversation=conversation;
   currentUser=appCubit.currentUser;
  emit(searchbarresetState());
 }

 Future sendMessage(String massage)async{
   resetPageSize();
   Message newMessage =Message(massage, DateTime.now().toString(), DateTime.now().millisecondsSinceEpoch.toString(),currentUser.id);
   if(currentConversation==null){
     List<Message>messages=[];
     messages.add(newMessage);
     await addnewconversation(messages);
   }
   await updateMessagesInFirebase(newMessage);
 }

 Future updateMessagesInFirebase(Message newMessage)async{
   await chosenUserChat().collection("Messages").add(newMessage.toJson());
   await chosenUserChat().update({'lastMassage':newMessage.massage,"istyping": "false","dateOfConversation":newMessage.timeStamp});

   await currentUserChat().collection("Messages").add(newMessage.toJson());
   await currentUserChat().update({'lastMassage':newMessage.massage,"istyping": "false","dateOfConversation":newMessage.timeStamp});
 }


 Future addnewconversation(List<Message>messages)async{

   Conversation newConversation =Conversation(currentUser, chosenUser);
   newConversation.dateOfConversation=DateTime.now().millisecondsSinceEpoch.toString();

   Conversation createReceiverConversation =Conversation(chosenUser, currentUser);
   createReceiverConversation.dateOfConversation=DateTime.now().millisecondsSinceEpoch.toString();

   await chosenUserChat().set(newConversation.toJson()).then((value) async {
     currentConversation=newConversation;
   });

   await currentUserChat().set(createReceiverConversation.toJson());
   emit(newconversationAddedSuccssefully());
 }

 Future<void> changeTypingState(bool typingState) async {
   await chosenUserChat().update({"istyping": typingState.toString()});
   await currentUserChat().update({"istyping": typingState.toString()});
 }

 List<Message> getListOfMessages(QuerySnapshot sender) {
   List<Message> messages=[];
   sender.docs.forEach((element){
     messages.add(Message.fromJson(element.data()));
   });
   messages = sortMessages(messages);
   return messages;
 }

  void resetCurrentConversation(){
    currentConversation=null;
    emit(resetCurrentConversationState());
  }

 List<Message> sortMessages(List<Message> messages) {
   messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
   return messages;
 }

 Future increasePageSize(){
   pageSize+=6;
   emit(increasePageSizeState());
 }

 void resetPageSize(){
   pageSize=6;
   emit(resetPageSizeState());
 }

}