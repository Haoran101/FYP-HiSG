import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';

// ignore: must_be_immutable
class UserMain extends StatefulWidget {

  Function setPage;
  UserMain({required this.setPage});

  @override
  _UserMainState createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {

  signout() async {
    await FirebaseAuth.instance.signOut();

    widget.setPage(AuthPage.login);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 30.0),
          child: CircleAvatar(
            radius: 50.0,
            backgroundImage: NetworkImage("https://www.w3schools.com/howto/img_avatar2.png"),
          ),
        )
      ),
      Container(child: Text(FirebaseAuth.instance.currentUser!.uid),
      ),
      ElevatedButton(child: Text("Sign out"),
        onPressed: signout)
    ]);
  }
}