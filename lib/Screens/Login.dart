import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Screens/Register.dart';
import 'package:chatapp/Screens/userslist.dart';

import '../MainCubit/AppCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      //username.text=widget.olduser.name;
      //password.text=widget.olduser.password;

    }
    static const channel = MethodChannel('service');
    OpenService() async {

      try {
        //await channel.invokeMethod('openservice',{"id":AppCubit.get(context).currentuser.location});
      } on PlatformException catch (ex) {
        print(ex.message);
      }
  }
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool issecure=true;
  @override
  Widget build(BuildContext context) {
   // Scale.setup(context, Size(1280, 720));
       return Scaffold(
         appBar: PreferredSize(
           preferredSize: Size.fromHeight(70),
           child: Padding(
             padding: const EdgeInsets.only(top:10),
             child: AppBar(
               centerTitle: true,
               backgroundColor: Colors.white,
               elevation: 0,
               leading:  InkWell(onTap: () {
                 //showdialogForExit(context);
               },child: Container(child: Image.asset("assets/exit.jpg",),margin: EdgeInsets.only(right: 10,top: 5),)
               ),
             ),
           ),
         ),
         body:  BlocConsumer<AppCubit,AppCubitStates>(
           listener: (context, state) async {
             // if(state is userisadminstate){
             //   OpenService();
             //   Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewrepresentative(state.id),));
             // }
             // else
             if(state is GetUserIDSate){
               print("dsfsdfsdfsdfsdfdsfsdf");
               //OpenService();
               //getsnackbar(context,"Done");
               Navigator.push(context, MaterialPageRoute(builder: (context) => Userslist()));
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
               return Container(
                 color: Colors.white,
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
                         TextButton(onPressed: (){
                           //v.getnumofnews(value);
                           v.loginwithusernameandpassword(username.text,password.text);
                         }, child: Text("تسجيل دخول",style: TextStyle(
                             fontSize: 20
                         ),)),
                         TextButton(onPressed: (){
                           //v.getnumofnews(value);
                           Navigator.push(context, MaterialPageRoute(builder: (context) => Register(),));
                         }, child: Text("عمل اكونت",style: TextStyle(
                             fontSize: 20
                         ),)),
                       ],
                     ),
                   ),
                 ),
               );
             }

           },
         )
       );
  }
  Widget getsnackbar(BuildContext context,String message){
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'تراجع',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
