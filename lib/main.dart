import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MainCubit/AppCubit.dart';
import 'Screens/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit(),),
      ],
      child: BlocConsumer<AppCubit,AppCubitStates>(

        listener: (context, state) {},
        builder:(context, state) => MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.tajawalTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: Login(),
          debugShowCheckedModeBanner: false,
        )
      ),
    );
  }
}
