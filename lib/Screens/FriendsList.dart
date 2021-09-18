import 'package:auto_size_text/auto_size_text.dart';
import 'package:chatapp/MainCubit/AppCubit.dart';
import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class FriendsList extends StatelessWidget {

   TextEditingController controller =new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocConsumer<AppCubit,AppCubitStates>(
        listener: (context, state) {

        },
        builder: (context, state) {
          AppCubit appCubit =AppCubit.get(context);
          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffE5F7FF), Color(0xffFFFFFF)])),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 80,
                    width: double.infinity,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(

                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon((!appCubit.issearch)?Icons.search:Icons.close, color: Color(0xffD1DFFD),
                              )
                          ),
                          onTap: () {
                            appCubit.changesearchbarState();
                          },
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: (!appCubit.issearch)?Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello",
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0xff8FAEF1)),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  AppCubit.get(context).currentuser.name,
                                  style: TextStyle(
                                      color: Color(0xff3570EC), fontSize: 28),
                                )
                              ],
                            ),
                          ):Container(
                            height: 45,
                            child: TextFormField(
                              onChanged: (value) async{
                                if(value==""){
                                  appCubit.emptythesearchlist();
                                }
                                else{
                                  await appCubit.getsearchedlist(value);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "Enter User Name",
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blue, width: 1),borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: (!appCubit.issearch)?

                    StreamBuilder(
                      stream: CombineLatestStream.list(
                          [
                            FirebaseFirestore.instance.collection("Users").doc(appCubit.currentuser.id).collection("chats").snapshots()
                          ]
                      ),
                      builder: (context, snapshot) {


                        if(snapshot.hasData){
                          if(snapshot.data[0].docs.length>0){
                            return ListView.builder(
                              itemCount: snapshot.data[0].docs.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    appCubit.setChosenUser(conversation.fromJson(snapshot.data[0].docs[index].data()).secondPerson);
                                    appCubit.setCurrentConversation(conversation.fromJson(snapshot.data[0].docs[index].data()));
                                    if(conversation.fromJson(snapshot.data[0].docs[index].data()).secondPerson.id==appCubit.currentuser.id){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen( snapshot.data[0].docs[index]['firstPerson']['id'],snapshot.data[0].docs[index]['firstPerson']['name'],)));
                                    }
                                    else{
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen( snapshot.data[0].docs[index]['secondPerson']['id'], snapshot.data[0].docs[index]['secondPerson']['name'],)));
                                    }
                                  },
                                  child: Container(
                                    height: 80,
                                    width: double.infinity,
                                    child: Row(
                                      textDirection: TextDirection.rtl,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                AutoSizeText(
                                                  (conversation.fromJson(snapshot.data[0].docs[index].data()).secondPerson.id==appCubit.currentuser.id)?
                                                  conversation.fromJson(snapshot.data[0].docs[index].data()).firstPerson.name : conversation.fromJson(snapshot.data[0].docs[index].data()).secondPerson.name,
                                                  style: TextStyle(
                                                      color: Color(0xff505664), fontSize: 18),maxLines: 1,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                (  conversation.fromJson(snapshot.data[0].docs[index].data()).istyping=="false")?Text(
                                                  conversation.fromJson(snapshot.data[0].docs[index].data()).lastMassage,
                                                  style: TextStyle(
                                                      fontSize: 18, color: Color(0xff505664)),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                ):Text(
                                                  "typing...",
                                                  style: TextStyle(
                                                      fontSize: 18, color: Colors.green),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20,),
                                        Container(
                                          height: 60,
                                          width:60,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(40),
                                              border: Border.all(
                                                color: Color(0xff3570EC),
                                                width: 1.5,
                                              )),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(40),
                                              child: Image.network(
                                                (conversation.fromJson(snapshot.data[0].docs[index].data()).secondPerson.id==appCubit.currentuser.id)?
                                                conversation.fromJson(snapshot.data[0].docs[index].data()).firstPerson.imagepath: conversation.fromJson(snapshot.data[0].docs[index].data()).secondPerson.imagepath,
                                                fit: BoxFit.fill,)),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          else{
                            return Container(child: Center(child: Text("NO CONVERSATIONS FOUND")));
                          }
                        }
                        else{
                          return Container(child: Center(child: Text("NO CONVERSATIONS FOUND")));
                        }

                      },
                    ):
                    ListView.builder(
                      itemCount:  appCubit.searchlist.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            appCubit.setChosenUser(appCubit.searchlist[index]);
                            appCubit.resetCurrentConversation();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(appCubit.chosenUser.id,appCubit.chosenUser.name),));
                            appCubit.changesearchbarState();
                          },
                          child: AutoSizeText(
                            appCubit.searchlist[index].name,
                            style: TextStyle(
                                color: Color(0xff505664), fontSize: 18),maxLines: 1,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
