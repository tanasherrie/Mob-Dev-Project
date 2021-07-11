import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatbox/helper_functions/sharedPreference.dart';
import 'package:chatbox/services/auth.dart';
import 'package:chatbox/services/database.dart';
import 'package:chatbox/views/signIn.dart';
import 'package:chatbox/views/dmScreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  String myName, myProfilePic, myUserName, myEmail;
  Stream userStream, chatRooms;

  TextEditingController searchController = TextEditingController();

  getMyInfo() async{
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getProfilePic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getEmail();
    setState(() {});
  }

  getdmIDByUsernames(String user1, String user2){
    if(user1.substring(0,1).codeUnitAt(0) > user2.substring(0,1).codeUnitAt(0)){
      return "$user2\_$user1";
    }else{
      return "$user1\_$user2";
    }
  }

  onSearchClick() async{
    isSearching = true;
    setState((){});
    userStream = await DatabaseMethods().getUserName(searchController.text);
    setState((){});
  }

  Widget chatRoomList(){
      return StreamBuilder(
        stream: chatRooms,
          builder: (context, snapshot){
              return snapshot.hasData ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return
                    chatRoomTile(ds["lastMessage"], ds.id, myUserName);
                },
              ) :
              Center(
                child: CircularProgressIndicator(),
              );
          }
      );
  }

  Widget searchUser({String profile,name, userName, email}){
      return GestureDetector(
        onTap: (){
          var dmID = getdmIDByUsernames(myUserName, userName);
          Map<String, dynamic> dmInfoMap = {
            "users": [myUserName, userName]
          };

          DatabaseMethods().createDM(dmID, dmInfoMap);

          Navigator.push(context, MaterialPageRoute(
              builder: (context) => DMScreen(userName, name)
          ));
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children:[
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  profile,
                  height: 40,
                  width: 40,
                ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[Text(name), Text(email)]
            )
            ],
        ),
        ),
      );
  }

  Widget searchUserList(){
    return StreamBuilder(
      stream: userStream,
      builder: (context, snapshot){
        return snapshot.hasData ?
        ListView.builder(
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return searchUser(
                profile:ds["profilePic"],
                name:ds["name"],
                email:ds["email"],
                userName: ds["userName"]
            );
          }
        ): Center(child: CircularProgressIndicator(),);
      }
    );
  }

  getChatRooms() async{
    chatRooms = await DatabaseMethods().getChatRooms();
    setState(() {

    });
  }

  loadScreen() async{
      await getMyInfo();
      getChatRooms();
  }

  @override
  void initState() {
    loadScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ChatBox"),
          actions: [
            InkWell(
              onTap:(){
                AuthMethods().signOut().then((s){
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => SignIn()
                  ));
                });
              },
            child:
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app))
            )
          ],
        ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching ? GestureDetector(
                  onTap:(){
                     isSearching = false;
                     searchController.text = "";
                     setState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.arrow_back)
                  ),
                ) : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                    border: InputBorder.none, hintText: "username"),
                            )),
                            GestureDetector(
                              onTap: (){
                                if(searchController.text != ""){
                                    onSearchClick();
                                }
                              },
                              child: Icon(Icons.search))
                        ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUserList() : chatRoomList()
          ]
        ),
      )
    );
  }
}

class chatRoomTile extends StatefulWidget {
  final String  lastMessage, dmID, myUsername;
  chatRoomTile(this.lastMessage, this.dmID, this.myUsername);

  @override
  _chatRoomTileState createState() => _chatRoomTileState();
}

// ignore: camel_case_types
class _chatRoomTileState extends State<chatRoomTile> {
  String profilePic="" , name="", username="";
  getOtherUserInfo() async{
     username = widget.dmID.replaceAll(widget.myUsername, "").replaceAll("_", "");
     QuerySnapshot querySnapshot = await DatabaseMethods().getDBUserInfo(username);
     name = "${querySnapshot.docs[0]["name"]}";
     profilePic = "${querySnapshot.docs[0]["profilePic"]}";
     setState(() {});
  }

  @override
  void initState() {
    getOtherUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => DMScreen(username, name)
        ));
      },

      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children:[
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(profilePic, height: 40, width: 40),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    name,
                    style: TextStyle(fontSize: 16)
                ),
                SizedBox(height: 3),
                Text(widget.lastMessage)
              ],
            )
          ],
        ),
      ),
    );
  }
}

