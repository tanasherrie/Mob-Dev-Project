import 'package:chatbox/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbox/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child:Container(
              margin: EdgeInsets.fromLTRB(0,100,0,0),
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   SizedBox(
                    height: 16,
                  ),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage("assets/images/logo.png"),
                ),
                   SizedBox(
                    height: 16,
                  ),
                Text("ChatBox",
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  )
              ),
                   SizedBox(
                    height: 16,
                  ),

           GestureDetector(
              onTap: (){
                 AuthMethods().signInWithGoogle(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.blue
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Sign In with Google",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            ])
        )
      )
    );
  }
}
