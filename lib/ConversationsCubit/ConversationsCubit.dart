import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubitStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsCubit extends Cubit<ConversationsCubitStates> {

  ConversationsCubit() : super(initialState());

  static ConversationsCubit get(BuildContext context) => BlocProvider.of(context);
  user chosenUser;
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  user currentUser;
  DocumentReference chatDocument() => usersCollection.doc(currentUser.id).collection("chats").doc(chosenUser.id);
  Conversation currentConversation;


  void setCurrentUser(user user){
    currentUser=user;
    emit(currentUserUpdated());
  }
  void setCurrentConversation(Conversation conversation,ChatRoomCubit chatRoomCubit,AuthCubit appCubit){
    currentConversation=conversation;
    chatRoomCubit.setChosenUserAndCurrentConversation(chosenUser, currentConversation,appCubit);
    emit(getConversationsDetailsState());
  }

  Future setChosenUser(user chosen,ChatRoomCubit chatRoomCubit,{Conversation conversation})async{
    chosenUser=chosen;
    currentConversation=null;
    chatRoomCubit.setChosenUser(chosenUser);
    chatRoomCubit.resetPageSize();
    chatRoomCubit.resetCurrentConversation();
    if(conversation==null){
      await chatDocument().get().then((conversationDocument) async {
        if(conversationDocument.data()!=null){

          currentConversation=Conversation.fromJson(conversationDocument.data());
        }
        emit(newconversationAddedSuccssefully());
      });
    }
    else{
      currentConversation =conversation;
    }

    emit(searchbarresetState());
  }

  Stream<QuerySnapshot> getStreamOfConversations() => usersCollection.doc(currentUser.id).collection("chats").orderBy("dateOfConversation",descending: true).snapshots();


  bool isSearch=false;

  List<user>searchList=[];

  void getUsers(QuerySnapshot value, String searchedWord) {
    searchList=[];
    value.docs.forEach((element) {
      if(user.fromJson(element.data()).id!=currentUser.id) {
        if (user.fromJson(element.data()).name.startsWith(searchedWord)) {
          bool isFound =false;
          searchList.forEach((item) {
            if(user.fromJson(element.data()).id==item.id){
              isFound=true;
            }
          });
          if(isFound==false){
            searchList.add(user.fromJson(element.data()));
          }

        }
      }
    });
    emit(SearchedListCome());
  }

  void emptyTheSearchList(){
    searchList=[];
    emit(searchlistisNowEmpty());
  }

  Future getSearchedList(String searchedWord)async{
    QuerySnapshot querySnapshotOfUsers =await usersCollection.get();
    getUsers(querySnapshotOfUsers, searchedWord);
  }

  void changeSearchBarState(){
    isSearch=!isSearch;
    searchList=[];
    emit(searchbarresetState());
  }
}