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

  AuthCubit() : super(InitialState());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  UserAccount currentUser;

  bool checkvalidatyofinputs(String username,String password){
    if(username == "" || password == ""){
      return false;
    }
    else{
      return true;
    }
  }

  Future<UserAccount>getUserAccountInformation(UserCredential userCredential)async{
    DocumentSnapshot querySnapshot = await FirebaseApiServices.getUserAccountData(userCredential);
    if(querySnapshot.data()!=null){
      return UserAccount.fromJson(querySnapshot.data());
    }
    else{
      return null;
    }
  }

  Future<void> loginWithUsernameAndPassword(String username, String password,ConversationsCubit conversationsCubit,ChatRoomCubit chatRoomCubit) async {
    emit(LoginIsStart());
    if (!checkvalidatyofinputs(username,password)) {
      emit(EmptyFieldsFoundState());
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
      emit(InvalidUser());
    }
  }

  void resetTextVisibilityState(){
    isSecure = true;
    emit(TextVisibilityStateChanged());
  }

  Future<void> loginSuccessful(UserCredential userCredential, ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
    UserAccount newUser = await getUserAccountInformation(userCredential);
    if(newUser!=null){
      currentUser=newUser;
      isSecure=true;
      chatRoomCubit.setCurrentUser(currentUser);
      conversationsCubit.setCurrentUser(newUser);
      emit(GetUserIDDate());
    }
    else{
      emit(NoUserFound());
    }
  }
  bool isSecure=true;

  void changePasswordVisibilityState(){
    isSecure=!isSecure;
    emit(PasswordVisibilityState());
  }

  Future<UserAccount>createAccountInFireBaeAuthentication(TextEditingController username, TextEditingController password)async{
    UserCredential userCredential= await FirebaseApiServices.createUserInFirebase(username.text, password.text);
    return UserAccount(username.text, password.text, 'user', userCredential.user.uid);
  }


  Future<void>createNewUser(UserAccount newUser,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit)async{
    await FirebaseApiServices.createNewDocumentForNewUserInFirebase(newUser);
    currentUser=newUser;
    chatRoomCubit.setCurrentUser(currentUser);
    conversationsCubit.setCurrentUser(newUser);
    emit(UserRegistered());
  }

  Future<void>registerNewUser(TextEditingController username, TextEditingController password,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit)async{
    try {
      emit(LoadDataFromFirebase());
      UserAccount newuser =await createAccountInFireBaeAuthentication(username,password);
      await createNewUser(newuser,conversationsCubit,chatRoomCubit);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(WeakPassword());
      }
      else if (e.code == 'email-already-in-use') {
        emit(AccountAlreadyExists());
      }
    } catch (e) {
      print(e);
    }
  }

  Future register(TextEditingController username, TextEditingController password,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
    if (!checkvalidatyofinputs(username.text, password.text)) {
      emit(EmptyFieldRegistersState());
    }
    else {
      await registerNewUser(username,password, conversationsCubit,  chatRoomCubit);
    }
  }
}