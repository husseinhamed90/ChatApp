// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Helpers/ResuableWidgets.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:chatapp/Widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart'as ss;
import 'package:flutter_bloc/flutter_bloc.dart';

class Register extends StatelessWidget {

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit,AuthCubitStates>(
      listener: (context, state) {
      },
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            child: CustomAppbar(title: "Create New Account"),
            preferredSize: Size.fromHeight(70),
          ),
          body: BlocConsumer<AuthCubit,AuthCubitStates>(
            listener: (context, state) {

              if(state is UserRegistered){
                ss.Toast.show("The user has been successfully registered", context, duration: 2, gravity: ss.Toast.BOTTOM);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FriendsList()));
              }
              else if(state is EmptyFieldRegistersState){
                getSnackBar(context,"There are empty fields");
              }
              else if(state is AccountAlreadyExists){
                getSnackBar(context,"This name already exists");
              }
              else if(state is WeakPassword){
                getSnackBar(context,"weak password");
              }
            },
            builder: (context, state) {
              AuthCubit appCubit =AuthCubit.get(context);
              if(state is LoadDataFromFirebase){
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Container(
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
                        InkWell(
                          onTap: () {
                            appCubit.capturePhoto(imageSource: ImageSource.gallery);
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            alignment: Alignment.bottomRight,
                            child:    Padding(
                              padding: const EdgeInsets.all(15),
                              child: CircleAvatar(radius: 15,backgroundColor: Colors.blue,child: Icon(appCubit.imageFile==null?Icons.add:Icons.edit,size: 20,color: Colors.white,)),
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: appCubit.imageFile==null?
                                  AssetImage("images/defaultImage.png"):FileImage(File(appCubit.imageFile.path)),
                                  fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
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
                        ElevatedButton(onPressed: ()async{

                          appCubit.register(username,password,ConversationsCubit.get(context),ChatRoomCubit.get(context));
                        }, child: Text("Create Account",style: TextStyle(
                            fontSize: 20
                        ),)),
                        SizedBox(height: 30,),
                      ],
                    ),
                  ),
                ),
              );
            },

          ),
        );
      },
    );
  }

}

