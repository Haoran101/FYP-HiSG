import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/user_model.dart';

// ignore: must_be_immutable
class UserMain extends StatefulWidget {
  
  Function setPage;
  UserMain({required this.setPage});

  @override
  _UserMainState createState() => _UserMainState();
}

class _UserMainState extends State<UserMain>{

  UserDetails? user;
  
  final defaultProfilePhotoURL =
      "https://thumbs.dreamstime.com/b/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg";
  bool _displayNameEnableEdit = false;
  
  signout() async {
    await FirebaseAuth.instance.signOut();

    widget.setPage(AuthPage.login);
  }

  getUser() async {
    if (user == null) {
      UserDetails? fetchedUser =
          await UserDatabase().getUser(FirebaseAuth.instance.currentUser!.uid);

      setState(() {
        user = fetchedUser;
      });
    }
  }

  toggleDisplayNameView() {
    setState(() {
      _displayNameEnableEdit = !_displayNameEnableEdit;
    });
  }

  changeUserDisplayName(String name) async {
    user!.displayName = name;
    UserDatabase().updateUserProperty(user!);
  }

  getUIBody() {
    if (user != null) {
      return Column(children: [
        Center(
            child: Container(
          margin: EdgeInsets.symmetric(vertical: 30.0),
          child: CircleAvatar(
            radius: 50.0,
            backgroundImage: NetworkImage(
                (user != null && user!.photoURL != null)
                    ? (user!.photoURL!)
                    : defaultProfilePhotoURL),
          ),
        )),
        //displayName
        Container(
          child: 
            Text(user!.displayName!),
        ),
        Container(child: Text(user!.uid!)),
        ElevatedButton(child: Text("Sign out"), onPressed: signout)
      ]);
    } else {
      return Text("user is null!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return getUIBody();
    } else {
      print("implemented future");
      return FutureBuilder(
          future: getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return getUIBody();
          });
    }
  }

}
