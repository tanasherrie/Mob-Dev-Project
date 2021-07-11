import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatbox/helper_functions/sharedPreference.dart';
import 'package:chatbox/services/database.dart';
import 'package:chatbox/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthMethods{
  final FirebaseAuth auth = FirebaseAuth.instance;

  getUser() async{
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context)async{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuthentication = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken
    );

   UserCredential  result =  await _firebaseAuth.signInWithCredential(credential);
   User userInfo = result.user;

   if(result != null){
      SharedPreferenceHelper().saveEmail(userInfo.email);
      SharedPreferenceHelper().saveUserID(userInfo.uid);
      SharedPreferenceHelper().saveUserName(userInfo.email.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveDisplayName(userInfo.displayName);
      SharedPreferenceHelper().saveProfilePic(userInfo.photoURL);

      Map<String, dynamic> userInfoMap = {
        "email": userInfo.email,
        "username": userInfo.email.replaceAll("@gmail.com", ""),
        "name": userInfo.displayName,
        "imgUrl": userInfo.photoURL
      };

      DatabaseMethods()
          .addUserInfoToDB(userInfo.uid, userInfoMap)
          .then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder:
            (context) => Home()));
          });
   }
  }

  Future signOut() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    await auth.signOut();
  }
}