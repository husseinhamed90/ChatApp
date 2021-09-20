import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Helpers/ResuableWidgets.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:chatapp/Widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            child: CustomAppbar("اضافة مستخدم"),
            preferredSize: Size.fromHeight(70),
          ),
          body: BlocConsumer<AuthCubit,AuthCubitStates>(
            listener: (context, state) {

              if(state is userregistered){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FriendsList()));
              }
              else if(state is emptyfeildregistersstate){
                getsnackbar(context,"توجد حقول فارغة");
              }
              else if(state is accountalreadyexists){
                getsnackbar(context,"هذا الاسم موجود مسبقا");
              }
              else if(state is weakpassword){
                getsnackbar(context,"كلمة المرور ضعيفة");
              }
              else if(state is userregistered){
                ss.Toast.show("تم تسجيل المستخدم بنجاج", context, duration: 2, gravity: ss.Toast.BOTTOM);
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              AuthCubit appCubit =AuthCubit.get(context);
              if(state is loaddatafromfirebase){
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
                            obscureText: appCubit.isSecure,
                            controller: password,
                            decoration: InputDecoration(
                                border: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.teal)),
                                labelText: "كلمة السر",
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

                          appCubit.register(username,password,ConversationsCubit.get(context),ChatRoomCubit.get(context));
                        }, child: Text("تسجيل مستخدم جديد",style: TextStyle(
                            fontSize: 20
                        ),)),
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

