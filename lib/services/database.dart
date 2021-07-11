import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbox/helper_functions/sharedPreference.dart';

class DatabaseMethods{
  Future addUserInfoToDB(
      String userID, Map<String, dynamic> userInfoMap) async{
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserName(String userName) async{
    return FirebaseFirestore.instance
      .collection("users")
      .where("userName", isEqualTo: userName)
      .snapshots();
  }

  Future addMsg(String dmID, String msgID, Map msgInfo) async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(dmID)
        .collection("chats")
        .doc(msgID)
        .set(msgInfo);
  }

  updateLastMsg(String dmID, Map lastMessageMap){
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(dmID).update(lastMessageMap);
  }

  createDM(String dmID, Map dmInfoMap) async{
    final snapShot = await FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(dmID)
      .get();

    if(snapShot.exists){
      //dm already exists
      return true;
    }else{
      //dm does NOT exist
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(dmID)
          .set(dmInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getMessages(dmID) async{
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(dmID)
        .collection("chats")
        .orderBy("timestamp",descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async{
    String myUsername = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("timestamp", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }

  Future<QuerySnapshot> getDBUserInfo(String username) async{
    return await FirebaseFirestore.instance
        .collection("users")
        .where("userName", isEqualTo: username)
        .get();
  }
}