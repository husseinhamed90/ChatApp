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
import 'package:intl/intl.dart';

class ChatRoomCubit extends Cubit<ChatRoomCubitStates> {

  ChatRoomCubit() : super(InitialState());
  static ChatRoomCubit get(BuildContext context) => BlocProvider.of(context);
  UserAccount currentUser;
  UserAccount chosenUser;
  Conversation currentConversation;
  int pageSize=6;

  Stream<QuerySnapshot> streamOfMessages() {
    return FirebaseApiServices.streamOfMessages(currentUser.id,chosenUser.id,pageSize);
  }


  void setCurrentUser(UserAccount user){
    currentUser=user;
   emit(CurrentUserUpdated());
  }

  void setChosenUser(UserAccount user){
    chosenUser=user;
    emit(CurrentUserUpdated());
  }

  Future setChosenUserAndCurrentConversation(UserAccount chosen,Conversation conversation,AuthCubit appCubit)async{
   chosenUser=chosen;
   currentConversation=conversation;
   currentUser=appCubit.currentUser;
   emit(SearchBarSetState());
  }

  Future sendMessage(String massage)async{
    resetPageSize();

    print( DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()));
    Message newMessage =Message(massage, DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()), DateTime.now().millisecondsSinceEpoch.toString(),currentUser.id);
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
   emit(NewConversationAddedSuccessfully());
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
    emit(ResetCurrentConversationState());
  }

 List<Message> sortMessages(List<Message> messages) {
   messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
   return messages;
 }

 void increasePageSize(){
   pageSize+=6;
   emit(IncreasePageSizeState());
 }

 void resetPageSize(){
   pageSize=6;
   emit(ResetPageSizeState());
 }

}