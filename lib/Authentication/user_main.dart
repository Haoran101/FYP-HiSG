import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';
import 'package:wikitude_flutter_app/Plan/favorites.dart';
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

class _UserMainState extends State<UserMain> {
  final UserService _user = UserService();
  UserDetails? user;
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    user = _user.getCurrentUser;
    controller = TextEditingController(text: user!.displayName);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final defaultProfilePhotoURL =
      "https://thumbs.dreamstime.com/b/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg";

  signout() async {
    await FirebaseAuth.instance.signOut();
    _user.logout();
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

  showNameEditDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Edit Display Name"),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    changeUserDisplayName(value);
                  },
                  onSaved: (value) {
                    changeUserDisplayName(value!);
                  },
                ),
              ),
              actions: [
                //Confirm button
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        print(controller.value);
                        print(controller.text);
                        changeUserDisplayName(controller.text);
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text("Confirm")),
                //Cancel button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ]);
        });
  }

  changeUserDisplayName(String name) {
    setState(() {
      user!.displayName = name;
    });
    UserDatabase().updateUserProperty(user!);
  }

  getUIBody() {
    if (user != null) {
      return Scaffold(
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(children: [
            InkWell(
              child: Center(
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
            ),
            //displayName
            Row(children: [
              Spacer(),
              Container(
                child: Text(
                  user!.displayName!,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                //TODO: update user name
                onTap: () => showNameEditDialog(),
                child: Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.only(left: 20),
                  color: Colors.blueGrey,
                  child: Icon(Icons.edit, color: Colors.white),
                ),
              ),
              Spacer(),
            ]),
            Container(
                margin: EdgeInsets.only(
                    top: 50.0, bottom: 20.0, left: 30, right: 30),
                child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.white),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black)),
                      child: Row(children: [
                        Text(
                          "Favorites",
                          style: TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Icon(Icons.chevron_right_outlined)
                      ]),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Favorites()),
                      ),
                    ))),
            Container(
                margin: EdgeInsets.only(
                    top: 0.0, bottom: 20.0, left: 30, right: 30),
                child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.white),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.black)),
                        child: Row(children: [
                          Text(
                            "About",
                            style: TextStyle(fontSize: 18),
                          ),
                          Spacer(),
                        ]),
                        onPressed: () => showAboutDialog(
                            context: context,
                            applicationName: "HiSG",
                            applicationVersion: "1.0.0",
                            applicationIcon: Image.asset(
                              "assets/img/app_logo.png",
                              width: 50,
                              height: 50,
                            ))))),
            //Container(child: Text(user!.uid!)),
            Container(
                margin: EdgeInsets.only(
                    top: 260.0, bottom: 20.0, left: 30, right: 30),
                child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColor),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white)),
                        child: Text(
                          "Sign Out",
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: signout))),
          ]),
        ),
      );
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
