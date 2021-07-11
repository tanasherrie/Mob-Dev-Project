import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatbox/helper_functions/sharedPreference.dart';
import 'package:chatbox/services/database.dart';
import 'package:random_string/random_string.dart';

class DMScreen extends StatefulWidget {
  final String userName, name;
  DMScreen(this.userName, this.name);

  @override
  _DMScreenState createState() => _DMScreenState();
}

class _DMScreenState extends State<DMScreen> {
  String dmID,  messageID = "";
  Stream messages;
  String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageController = TextEditingController();

  getMyInfo() async{
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getProfilePic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getEmail();

    dmID = getdmIDByUsernames(widget.userName, myUserName);
  }

  getdmIDByUsernames(String user1, String user2){
    if(user1.substring(0,1).codeUnitAt(0) > user2.substring(0,1).codeUnitAt(0)){
      return "$user2\_$user1";
    }else{
      return "$user1\_$user2";
    }
  }

  addMessage(bool sentMsg){
      if(messageController.text != ""){
        String message = messageController.text;
        var msgTimestamp = DateTime.now();
        Map<String, dynamic> messageInfo = {
          "message": message,
          "sender": myUserName,
          "timestamp": msgTimestamp,
          "profilePic": myProfilePic
        };

        //generate message ID
        if(messageID == ""){
          messageID = randomAlphaNumeric(12);
        }

        DatabaseMethods().addMsg(dmID, messageID, messageInfo)
        .then((value){
          Map <String,dynamic> lastMessageMap = {
            "lastMessage": message,
            "timestamp": msgTimestamp,
            "lastSender": myUserName
          };

          DatabaseMethods().updateLastMsg(dmID, lastMessageMap);

          if(sentMsg){
            //remove text in the input field
            messageController.text = "";

            //make message id  or dmID blank
            dmID = "";
          }
        });
      }
  }
  Widget messageTile(String message, bool sentByMe){
    return Row(
      mainAxisAlignment:
          sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight:
                  sentByMe ? Radius.circular(0) : Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft:
                  sentByMe ? Radius.circular(24) : Radius.circular(0),
            ),
            color: Colors.blue,
          ),
          padding: EdgeInsets.all(16),
          child: Text(
              message,
              style: TextStyle(color: Colors.white)
          )
        ),
      ],
    );
  }

  Widget messageList(){
    return StreamBuilder(
      stream: messages,
      builder: (context, snapshot){
        return snapshot.hasData ?
        ListView.builder(
          padding: EdgeInsets.only(bottom:70, top:16),
          itemCount: snapshot.data.docs.length,
          reverse: true,
          itemBuilder: (context, index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return messageTile(ds["message"], myUserName == ds["sender"]);
          }) :
        Center(
            child: CircularProgressIndicator()
        );
      },
    );
  }


  getAndSetMessages() async{
     messages = await DatabaseMethods().getMessages(dmID);
     setState(() {

     });
  }

  launch() async{
    await getMyInfo();
    getAndSetMessages();
  }

  @override
  void initState() {
    // TODO: implement initState
    launch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Container(
            child: Stack(
              children: [
                messageList(),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                          children:[
                            Expanded(
                              child:TextField(
                                controller: messageController,
                                onChanged: (value){
                                  addMessage(false);
                                },
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Type your message",
                                    hintStyle:
                                      TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontWeight: FontWeight.w500
                                      )
                                )
                              )),
                              GestureDetector(
                                onTap: (){
                                  addMessage(true);
                                },
                                child: Icon(
                                    Icons.send,
                                    color: Colors.white
                                ),
                              )
                          ],
                      ),
                    ),
                  )
              ],
            ),
        )
    );
  }
}
