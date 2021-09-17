
import 'package:chatapp/MainCubit/AppCubit.dart';
import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Widgets/CustomAppBar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:toast/toast.dart'as ss;
import 'package:flutter_bloc/flutter_bloc.dart';
class Register extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Register> with WidgetsBindingObserver {

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool issecure=true;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppCubitStates>(
      listener: (context, state) {
        if(state is exitapp){
          SystemNavigator.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: PreferredSize(
              child: CustomAppbar("اضافة مستخدم"),
              preferredSize: Size.fromHeight(70),
            ),
            body: BlocConsumer<AppCubit,AppCubitStates>(
              listener: (context, state) {
                if(state is emptyfeildregistersstate){
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
                AppCubit v =AppCubit.get(context);
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

                            v.register(username,password);
                          }, child: Text("تسجيل مستخدم جديد",style: TextStyle(
                              fontSize: 20
                          ),)),
                          // TextButton(onPressed: ()async{
                          //   //Navigator.push(context, MaterialPageRoute(builder: (context) => Userslist(),));
                          //   // v.register(username,password);
                          // }, child: Text("اظهار المستخدمون",style: TextStyle(
                          //     fontSize: 20
                          // ),))
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

