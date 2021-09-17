

class user{
  String name;
  String password;
  String usertype;
  String id;
  String isfirsttime;
  String isonline;
  String location;
  String date;
  List<dynamic>conversationsIDs=[];
  String imagepath="https://www.leisureopportunities.co.uk/images/imagesX/HIGH799405_746782.jpg";




  user(this.name, this.password, this.usertype,this.id,[this.isfirsttime="true",this.isonline="false"]);

  user.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
    usertype =json['usertype'];
    id=json['id'];
    isfirsttime=json['isfirsttime'];
    imagepath =json['image'];
    conversationsIDs=json['conversationsIDs'];
    isonline=json['isonline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['date']=this.date;
    List<dynamic>map=[];
    conversationsIDs.forEach((element) {
      map.add(element);
    });
    data['conversationsIDs']=map;
   // data['conversationsIDs']=this.conversationsIDs;
    data['password'] = this.password;
    data['usertype']=this.usertype;
    data['id']=this.id;
    data['image']=this.imagepath;
    data['isfirsttime']=this.isfirsttime;
    data['isonline']=this.isonline;
    return data;
  }

}