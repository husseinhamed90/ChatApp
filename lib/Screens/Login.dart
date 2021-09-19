import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/ResuableWidgets.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:chatapp/Screens/Register.dart';
import '../MainCubit/AppCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver{

  @override
    void initState() {
      // TODO: implement initState
      WidgetsBinding.instance.addObserver(this);
      super.initState();
    }

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool issecure=true;
  @override
  Widget build(BuildContext context) {
       return Scaffold(

         body:  BlocConsumer<AppCubit,AppCubitStates>(
           listener: (context, state) async {
             if(state is GetUserIDSate){
               Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsList()));
             }
             else if(state is noadmindatafound){
               getsnackbar(context,"لا توجد بيانات للادمن حتي الان");
             }
             else if(state is invaliduser){
               getsnackbar(context,"كلمة المرور او اسم المستخدم غير صحيح");
             }
             else if(state is emptyfeildsstate){
               getsnackbar(context,"توجد حقول فارغة");
             }
           },
           builder: (context, state) {
             AppCubit v =AppCubit.get(context);
             if(v.isloging){
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
                            await v.loginwithusernameandpassword(username.text,password.text);
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
