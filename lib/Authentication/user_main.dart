import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';
import 'package:wikitude_flutter_app/User/user_database.dart';
import 'package:wikitude_flutter_app/User/user_model.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

// ignore: must_be_immutable
class UserMain extends StatefulWidget {
  
  Function setPage;
  UserMain({required this.setPage});

  @override
  _UserMainState createState() => _UserMainState();
}

class _UserMainState extends State<UserMain>{
  final UserService _user = UserService();
  UserDetails? user;

  @override
  void initState() {
    user = _user.getCurrentUser;
    super.initState();
  }
  
  final defaultProfilePhotoURL =
      "https://thumbs.dreamstime.com/b/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg";
  bool _displayNameEnableEdit = false;
  
  signout() async {
    await FirebaseAuth.instance.signOut();
    _user.setCurrentUser = null;
    widget.setPage(AuthPage.login);
  }

  getUser() async {
    if (user == null) {
      UserDetails? fetchedUser =
          await UserDatabase().getUser(FirebaseAuth.instance.currentUser!.uid);
      _user.setCurrentUser = fetchedUser;
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
