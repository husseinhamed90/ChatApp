// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Models/User.dart';
import 'package:chatapp/Network/remote/NotificationApi.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helpers/ResuableWidgets.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:chatapp/Screens/Register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatelessWidget {
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body:  BlocConsumer<AuthCubit,AuthCubitStates>(
          listener: (context, state) async {
            if(state is GetUserIDDate){
              UserAccount comingMessageSender;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String openedMessage=(prefs.get('openedMessage') ?? "");
              if(openedMessage!=""){
                Map valueMap = json.decode(openedMessage);
                comingMessageSender=UserAccount.fromJson(valueMap);
              }
              if(comingMessageSender==null){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FriendsList()));
              }
              else{
                ChatRoomCubit.get(context).setChosenUser(comingMessageSender);
                await prefs.setString("openedMessage","");
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(comingMessageSender.name,isFromNotification: true,)));
              }
            }
            else if(state is InvalidUser){
              getSnackBar(context,"The password or username is incorrect");
            }
            else if(state is EmptyFieldsFoundState){
              getSnackBar(context,"There are empty fields");
            }
          },
          builder: (context, state) {
            AuthCubit appCubit =AuthCubit.get(context);
            if(state is LoginIsStart){
              return Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            else{
              return SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xffE5F7FF), Color(0xffFFFFFF)])),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width-50,
                            child: TextFormField(
                              controller: username,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  labelText: "Username"

                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                          Container(
                            width: MediaQuery.of(context).size.width-50,
                            child: TextFormField(
                              obscureText: appCubit.isSecure,
                              controller: password,

                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                      borderSide: new BorderSide(color: Colors.teal)),
                                  labelText: "Password",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      appCubit.changePasswordVisibilityState();
                                    },
                                    icon: (appCubit.isSecure)?Icon(Icons.visibility_off):Icon(Icons.visibility),
                                  )
                              ),
                            ),
                          ),
                          SizedBox(height: 30,),
                          TextButton(onPressed: ()async{

                            await appCubit.loginWithUsernameAndPassword(username.text,password.text,ConversationsCubit.get(context),ChatRoomCubit.get(context));
                          }, child: Text("Log in",style: TextStyle(
                              fontSize: 20,fontWeight: FontWeight.bold
                          ),)),
                          TextButton(onPressed: (){
                            appCubit.resetTextVisibilityState();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Register(),));
                          }, child: Text("Create Account",style: TextStyle(
                              fontSize: 20,fontWeight: FontWeight.bold
                          ),)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        )
    );
  }
}
