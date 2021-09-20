import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import '../Helpers/ResuableWidgets.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:chatapp/Screens/Register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool issecure=true;
  @override
  Widget build(BuildContext context) {
       return Scaffold(

         body:  BlocConsumer<AuthCubit,AuthCubitStates>(
           listener: (context, state) async {
             if(state is GetUserIDDate){
               Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsList()));
             }
             else if(state is invaliduser){
               getsnackbar(context,"كلمة المرور او اسم المستخدم غير صحيح");
             }
             else if(state is emptyfeildsstate){
               getsnackbar(context,"توجد حقول فارغة");
             }
           },
           builder: (context, state) {
             AuthCubit v =AuthCubit.get(context);
             if(state is loginsistart){
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
                                   labelText: "اسم المستخدم"

                               ),
                             ),
                           ),
                           SizedBox(height: 30,),
                           Container(
                             width: MediaQuery.of(context).size.width-50,
                             child: TextFormField(
                               obscureText: issecure,
                               controller: password,

                               decoration: InputDecoration(
                                   border: new OutlineInputBorder(
                                       borderSide: new BorderSide(color: Colors.teal)),
                                   labelText: "كلمة السر",
                                   suffixIcon: IconButton(
                                     onPressed: () {
                                       setState(() {
                                         issecure=!issecure;
                                       });
                                     },
                                     icon: (issecure)?Icon(Icons.visibility_off):Icon(Icons.visibility),
                                   )
                               ),
                             ),
                           ),
                           SizedBox(height: 30,),
                           TextButton(onPressed: ()async{
                            await v.loginWithUsernameAndPassword(username.text,password.text,ConversationsCubit.get(context),ChatRoomCubit.get(context));
                           }, child: Text("تسجيل دخول",style: TextStyle(
                               fontSize: 20
                           ),)),
                           TextButton(onPressed: (){
                             Navigator.push(context, MaterialPageRoute(builder: (context) => Register(),));
                           }, child: Text("عمل اكونت",style: TextStyle(
                               fontSize: 20
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
