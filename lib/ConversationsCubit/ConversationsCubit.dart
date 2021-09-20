import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubitStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/User.dart';
import 'package:chatapp/Network/remote/FirebaseApi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsCubit extends Cubit<ConversationsCubitStates> {

  ConversationsCubit() : super(InitialState());

  static ConversationsCubit get(BuildContext context) => BlocProvider.of(context);
  UserAccount chosenUser;
  UserAccount currentUser;

  bool isSearch=false;

  List<UserAccount>searchList=[];

  Conversation currentConversation;


  void setCurrentUser(UserAccount user){
    currentUser=user;
    emit(CurrentUserUpdated());
  }
  void setCurrentConversation(Conversation conversation,ChatRoomCubit chatRoomCubit,AuthCubit appCubit){
    currentConversation=conversation;
    chatRoomCubit.setChosenUserAndCurrentConversation(chosenUser, currentConversation,appCubit);
    emit(GetConversationsDetailsState());
  }

  Future setChosenUser(UserAccount chosen,ChatRoomCubit chatRoomCubit,{Conversation conversation})async{
    chosenUser=chosen;
    currentConversation=null;
    chatRoomCubit.setChosenUser(chosenUser);
    chatRoomCubit.resetPageSize();
    chatRoomCubit.resetCurrentConversation();
    await checkIfThereIsAlreadyAConversationFound(conversation);

    emit(SearchBarState());
  }

  Future<void> checkIfThereIsAlreadyAConversationFound(Conversation conversation) async {
    if(conversation==null){
      await FirebaseApiServices.getChosenUserChat(currentUser.id,chosenUser.id).get().then((conversationDocument) async {
        if(conversationDocument.data()!=null){
          currentConversation=Conversation.fromJson(conversationDocument.data());
        }
        emit(NewConversationAddedSuccessfully());
      });
    }
    else{
      currentConversation = conversation;
      emit(ThereIsAlreadyAConversationFound());
    }
  }

  Stream<QuerySnapshot> getStreamOfConversations() => FirebaseApiServices.getStreamOfConversations(currentUser.id);

  void getUsers(QuerySnapshot value, String searchedWord) {
    searchList=[];
    value.docs.forEach((element) {
      if(UserAccount.fromJson(element.data()).id!=currentUser.id) {
        if (UserAccount.fromJson(element.data()).name.startsWith(searchedWord)) {
          bool isFound =false;
          searchList.forEach((item) {
            if(UserAccount.fromJson(element.data()).id==item.id){
              isFound=true;
            }
          });
          if(isFound==false){
            searchList.add(UserAccount.fromJson(element.data()));
          }

        }
      }
    });
    emit(SearchedListCome());
  }

  void emptyTheSearchList(){
    searchList=[];
    emit(SearchListIsNowEmpty());
  }

  Future getSearchedList(String searchedWord)async{
    QuerySnapshot querySnapshotOfUsers =await FirebaseApiServices.usersCollection.get();
    getUsers(querySnapshotOfUsers, searchedWord);
  }

  void changeSearchBarState(){
    isSearch=!isSearch;
    searchList=[];
    emit(SearchBarState());
  }
}