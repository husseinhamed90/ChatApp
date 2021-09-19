import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';


class AuthCubit extends Cubit<AuthCubitStates> {

  AuthCubit() : super(initialState());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

  user currentUser;

  bool isloging=false;

  bool checkvalidatyofinputs(String username,String password){
    if(username == "" || password == ""){
      return false;
    }
    else{
      return true;
    }
  }

  Future<UserCredential>GetUserCredentialFromFireBase(String username,String password) async{
    try{
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${username.replaceAll(' ', '')}@stepone.com',
          password: password + "steponeapp"
      ).catchError((error) {
        emit(invaliduser());
      });
    }catch (e) {
      emit(invaliduser());
    }
  }

  Future<void>isValidUser(UserCredential userCredential,ConversationsCubit conversationsCubit,ChatRoomCubit chatRoomCubit)async{
    await usersCollection.doc(userCredential.user.uid).get().then((querySnapshot) {

      if(querySnapshot.data()!=null){
        currentUser=user.fromJson(querySnapshot.data());
        chatRoomCubit.setCurrentUser(currentUser);
        conversationsCubit.setCurrentUser(user.fromJson(querySnapshot.data()));
        emit(GetUserIDSate());
      }
    });
  }

  Future<void> loginwithusernameandpassword(String username, String password,ConversationsCubit conversationsCubit,ChatRoomCubit chatRoomCubit) async {
    emit(loginsistart());
    isloging=true;
    if (!checkvalidatyofinputs(username,password)) {
      emit(emptyfeildsstate());
      isloging=false;
    }
    else {

      UserCredential userCredential =await GetUserCredentialFromFireBase(username,password);
      if(userCredential!=null){
        await isValidUser(userCredential,conversationsCubit,chatRoomCubit);
        isloging=false;
      }
      else{
        isloging=false;
      }
    }
  }

  Future<user>CreateAccountInFireBaeAuthentication(TextEditingController username, TextEditingController password)async{

    UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${username.text.replaceAll(' ', '')}@stepone.com',
        password: password.text + "steponeapp");
    return user(username.text, password.text, 'user', userCredential.user.uid);
  }

  Future<void>CreateNewUser(user newuser){

    DocumentReference documentReference = usersCollection.doc(newuser.id);
    documentReference.set(newuser.toJson()).then((value){
      emit(userregistered());
    });
  }

  Future<void>RegisterNewUser(TextEditingController username, TextEditingController password)async{
    try {
      emit(loaddatafromfirebase());
      user newuser =await CreateAccountInFireBaeAuthentication(username,password);
      await CreateNewUser(newuser);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(weakpassword());
      } else if (e.code == 'email-already-in-use') {
        emit(accountalreadyexists());
      }
    } catch (e) {
      print(e);
    }
  }

  void register(TextEditingController username, TextEditingController password) async {
    if (!checkvalidatyofinputs(username.text, password.text)) {
      emit(emptyfeildregistersstate());
    }
    else {
      await RegisterNewUser(username,password);
    }
  }
}