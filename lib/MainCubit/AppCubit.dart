import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';

class AppCubit extends Cubit<AppCubitStates> {

  AppCubit() : super(initialState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  CollectionReference userscollection = FirebaseFirestore.instance.collection('Users');

  List<user> users = [];

  bool isloging=false;

  user currentuser;

  void GetCurrentUser(user user)async{
    currentuser=user;
    await getusers();
    emit(GetUserIDSate());
  }
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
      // emit(loginsistart());
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${username.replaceAll(' ', '')}@stepone.com',
          password: password + "steponeapp"
      ).catchError((error) {
        emit(invaliduser());
      });
      //userCredential=userCredentiall;
      // return userCredentiall;
    }catch (e) {
      emit(invaliduser());
    }
  }

  Future<void>isValidUser(UserCredential userCredential)async{
    await FirebaseFirestore.instance.collection('Users').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (user.fromJson(doc.data()).id == userCredential.user.uid) {
          GetCurrentUser(user.fromJson(doc.data()));
          //emit(currentuserdata());
          emit(validuser());
        }
      });
    });
  }

  Future<void> loginwithusernameandpassword(String username, String password) async {
    emit(loginsistart());
    isloging=true;
    if (!checkvalidatyofinputs(username,password)) {
      emit(emptyfeildsstate());
      isloging=false;
    }
    else {
      //emit(validateiuser());
      UserCredential userCredential =await GetUserCredentialFromFireBase(username,password);
      if(userCredential!=null){
        await isValidUser(userCredential);

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
    userscollection.add(newuser.toJson()).then((value) {
      userscollection.doc(value.path.split('/').last).update({"location": value.path.split('/').last});
      emit(userregistered());
    });
  }

  Future<void>RegisterNewUser(TextEditingController username, TextEditingController password)async{
    try {
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

  Future deleteUserfromauth(String email, String password) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User user = _auth.currentUser;
      AuthCredential credentials =
      EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credentials).then((value) {
        value.user.delete();
      });
    } catch (e) {}
  }

  Future UpdateUserfromauth(String password, TextEditingController newusername,TextEditingController newpassword) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      User user =  _auth.currentUser;

      AuthCredential credentials = EmailAuthProvider.credential(email: user.email, password: password + "steponeapp");
      await user.reauthenticateWithCredential(credentials).then((value) async {
        await value.user.updateEmail('${newusername.text.replaceAll(' ', '')}@stepone.com').then((valueeee) {
          value.user.updatePassword("${newpassword.text}steponeapp").then((value) {
            getusers().then((value) {
              emit(userupdatedsuccfully());
            });
          }).onError((error, stackTrace) {
          });
        });
      });
    } catch (e) {}
  }

  Future<void> getusers() async {
    users = [];
    emit(loaddatafromfirebase());
    await userscollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        users.add(user.fromJson(doc.data()));
      });
      emit(getusersstate());
    }).catchError((error) {
      print(error);
    });
  }
}