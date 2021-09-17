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
                      stream: FirebaseFirestore.instance.collection("Users").doc(appCubit.currentuser.id).snapshots(),
                      builder: (context, snapshot) {
                        DocumentSnapshot s =snapshot.data;

                        if(snapshot.hasData){
                          return StreamBuilder(
                            stream: CombineLatestStream.list(
                                [
                                  if(s.data()['conversationsIDs'].length>0)
                                    for (int i =0 ; i <s.data()['conversationsIDs'].length ; i++)
                                      FirebaseFirestore.instance.collection("Conversations").where("conversationsID",isEqualTo: s.data()['conversationsIDs'][i]).snapshots()
                                ]
                            ),
                            builder: (context, snapshot) {
                              if(snapshot.hasData){
                                if(snapshot.data.length>0){
                                  return ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          appCubit.setCurrentConversation(conversation.fromJson(snapshot.data[index].docs[0].data()));

                                          if(snapshot.data[index].docs[0]['secondPerson']['id']==appCubit.currentuser.id){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen( snapshot.data[index].docs[0]['firstPerson']['id'], snapshot.data[index].docs[0]['firstPerson']['name'],)));
                                          }
                                          else{
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen( snapshot.data[index].docs[0]['secondPerson']['id'], snapshot.data[index].docs[0]['secondPerson']['name'],)));
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
                                                        (snapshot.data[index].docs[0]['secondPerson']['id']==appCubit.currentuser.id)?
                                                        snapshot.data[index].docs[0]['firstPerson']['name'] : snapshot.data[index].docs[0]['secondPerson']['name'],
                                                        style: TextStyle(
                                                            color: Color(0xff505664), fontSize: 18),maxLines: 1,
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      (  snapshot.data[index].docs[0]['istyping']=="false")?Text(
                                                        snapshot.data[index].docs[0]['lastMassage'],
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
                                                      (snapshot.data[index].docs[0]['secondPerson']['id']==appCubit.currentuser.id)?
                                                      snapshot.data[index].docs[0]['firstPerson']['image'] : snapshot.data[index].docs[0]['secondPerson']['image'],
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
                          );
                        }
                        else{
                          return Container(child: Center(child: CircularProgressIndicator()));
                        }
                      },
                    ):
                    ListView.builder(
                      itemCount:  appCubit.searchlist.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            appCubit.setChosenUser(appCubit.searchlist[index]);
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
