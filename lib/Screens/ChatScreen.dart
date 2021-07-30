import '../MainCubit/AppCubit.dart';
import '../Widgets/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TestStream extends StatelessWidget {
  String receiver;
  String name;
  TestStream(this.receiver,this.name);
  TextEditingController controller=new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: CustomAppbar(name),
        preferredSize: Size.fromHeight(70),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: CombineLatestStream.list([
                    FirebaseFirestore.instance.collection("Messages").where("id",isEqualTo: AppCubit.get(context).currentuser.id).where("reciver",isEqualTo: receiver).snapshots(),
                    FirebaseFirestore.instance.collection("Messages").where("id",isEqualTo: receiver).where("reciver",isEqualTo: AppCubit.get(context).currentuser.id).snapshots(),
                  ]),
                  builder: (context, snapshot) {

                    if(snapshot.hasData){
                      List<QueryDocumentSnapshot>sender=snapshot.data[0].docs;
                      List<QueryDocumentSnapshot>receiver=snapshot.data[1].docs;
                      sender.addAll(receiver);
                      return  ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemBuilder: (context, index) {
                          List<QueryDocumentSnapshot> sortedMessages=sender.toList() ;
                          sortedMessages.sort((a, b) => a.data()['data'].compareTo(b.data()['data']));
                          return Container(
                            child: Card(child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(sortedMessages[index]['title']),
                              ],
                            ),),
                            alignment: (sortedMessages[index]['id']!=AppCubit.get(context).currentuser.id)?Alignment.centerLeft:Alignment.centerRight,
                          );
                        },
                        itemCount: sender.length,
                      );
                    }
                    else{
                      return Container(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  }
              ),
            ),
            Row(
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width-20)*0.8,
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                        labelText: "Enter Message"
                    ),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width-20)*0.2,
                  child: FloatingActionButton(onPressed: () async {
                    FirebaseFirestore.instance.collection("Messages").add(( {"title":controller.text,"id":AppCubit.get(context).currentuser.id,"reciver":receiver,"data":DateTime.now().millisecondsSinceEpoch}));
                  },child: Icon(Icons.send),),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}