import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Network/remote/FirebaseApi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';


class AuthCubit extends Cubit<AuthCubitStates> {

  AuthCubit() : super(initialState());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  user currentUser;

  bool checkvalidatyofinputs(String username,String password){
    if(username == "" || password == ""){
      return false;
    }
    else{
      return true;
    }
  }

  Future<user>getUserAccountInformation(UserCredential userCredential)async{
    DocumentSnapshot querySnapshot = await FirebaseApiServices.getUserAccountData(userCredential);
    if(querySnapshot.data()!=null){
      return user.fromJson(querySnapshot.data());
    }
    else{
      return null;
    }
  }

  Future<void> loginWithUsernameAndPassword(String username, String password,ConversationsCubit conversationsCubit,ChatRoomCubit chatRoomCubit) async {
    emit(loginsistart());
    if (!checkvalidatyofinputs(username,password)) {
      emit(emptyfeildsstate());
    }
    else {
      await tryLogin(username, password, conversationsCubit, chatRoomCubit);
    }
  }

  Future<void> tryLogin(String username, String password, ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
     UserCredential userCredential =await FirebaseApiServices.getUserCredentialFromFireBase(username,password);
    if(userCredential!=null){
      await loginSuccessful(userCredential, conversationsCubit, chatRoomCubit);
    }
    else{
      emit(invaliduser());
    }
  }

  Future<void> loginSuccessful(UserCredential userCredential, ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
    user newUser = await getUserAccountInformation(userCredential);
    if(newUser!=null){
      currentUser=newUser;
      chatRoomCubit.setCurrentUser(currentUser);
      conversationsCubit.setCurrentUser(newUser);
      emit(GetUserIDDate());
    }
    else{
      emit(noUserFound());
    }
  }

  Future<user>createAccountInFireBaeAuthentication(TextEditingController username, TextEditingController password)async{
    UserCredential userCredential= await FirebaseApiServices.createUserInFirebase(username.text, password.text);
    return user(username.text, password.text, 'user', userCredential.user.uid);
  }


  Future<void>createNewUser(user newUser,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit)async{
    await FirebaseApiServices.createNewDocumentForNewUserInFirebase(newUser);
    currentUser=newUser;
    chatRoomCubit.setCurrentUser(currentUser);
    conversationsCubit.setCurrentUser(newUser);
    emit(userregistered());
  }

  Future<void>registerNewUser(TextEditingController username, TextEditingController password,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit)async{
    try {
      emit(loaddatafromfirebase());
      user newuser =await createAccountInFireBaeAuthentication(username,password);
      await createNewUser(newuser,conversationsCubit,chatRoomCubit);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(weakpassword());
      }
      else if (e.code == 'email-already-in-use') {
        emit(accountalreadyexists());
      }
    } catch (e) {
      print(e);
    }
  }

  Future register(TextEditingController username, TextEditingController password,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
    if (!checkvalidatyofinputs(username.text, password.text)) {
      emit(emptyfeildregistersstate());
    }
    else {
      await registerNewUser(username,password, conversationsCubit,  chatRoomCubit);
    }
  }
}