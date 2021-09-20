import 'package:bloc/bloc.dart';
import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Models/User.dart';
import 'package:chatapp/Network/remote/FirebaseApi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatRoomCubit extends Cubit<ChatRoomCubitStates> {

  ChatRoomCubit() : super(initialState());
  static ChatRoomCubit get(BuildContext context) => BlocProvider.of(context);
  user currentUser;
  user chosenUser;
  Conversation currentConversation;
  int pageSize=6;

  Stream<QuerySnapshot> streamOfMessages() {
    return FirebaseApiServices.streamOfMessages(currentUser.id,chosenUser.id,pageSize);
  }


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
    await FirebaseApiServices.updateMessagesInFirebase(newMessage,currentUser.id,chosenUser.id);
  }



 Future addnewconversation(List<Message>messages)async{
   Conversation newConversation =Conversation(currentUser, chosenUser);
   newConversation.dateOfConversation=DateTime.now().millisecondsSinceEpoch.toString();
   Conversation receiverConversation =Conversation(chosenUser, currentUser);
   receiverConversation.dateOfConversation=DateTime.now().millisecondsSinceEpoch.toString();
   currentConversation=newConversation;
   await FirebaseApiServices.addConversationToUserAccount(currentUser.id, chosenUser.id, newConversation, receiverConversation);
   emit(newconversationAddedSuccssefully());
 }

 Future<void> changeTypingState(bool typingState) async {
   await FirebaseApiServices.changeTypingState(typingState, currentUser.id, chosenUser.id);

   emit(TypingStateIsChanged());
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