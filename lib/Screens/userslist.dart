
import 'package:chatapp/MainCubit/AppCubit.dart';
import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Widgets/BuildUserItem.dart';

import 'package:chatapp/Widgets/CustomAppBar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class Userslist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppbar("قائمة المستخدمين"),
        preferredSize: Size.fromHeight(70),
      ),
      body:  BlocConsumer<AppCubit,AppCubitStates>(
          listener: (context, state) {

          },
          builder: (context, state) {
            AppCubit appCubit =AppCubit.get(context);
           print(appCubit.users.length);
            print(state);
            if(state is loaddatafromfirebase)
            {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => appCubit.getusers(),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return BuildUserItem(appCubit.users[index], appCubit, index);
                },
                itemCount: appCubit.users.length,
              ),
            );

          }
      ),
    );
  }
}
