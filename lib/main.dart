import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Screens/FriendsList.dart';
import 'package:google_fonts/google_fonts.dart';

import 'MainCubit/AppCubit.dart';
import 'Screens/Login.dart';
import 'package:chatapp/Models/User.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  user userr;
  String id;
  MyApp([this.id,this.userr]);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit()..getusers(),),
      ],
      child: BlocConsumer<AppCubit,AppCubitStates>(

        listener: (context, state) {},
        builder:(context, state) => ScreenUtilInit(
          designSize: Size(1080,2280),
          builder: () => GetMaterialApp(
            theme: ThemeData(
              textTheme: GoogleFonts.tajawalTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            home: Login(),
            debugShowCheckedModeBanner: false,
            //locale: Locale("ar"),
          ),
        ),
      ),
    );
  }
}
