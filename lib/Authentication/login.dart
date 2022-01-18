import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/forget_password.dart';
import 'package:wikitude_flutter_app/Authentication/signup.dart';
import 'package:wikitude_flutter_app/Authentication/user_main.dart';

class loginPage extends StatefulWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final _formkey = GlobalKey<FormState>();

  var email = " ";
  var password = " ";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  userLogin() async {
    try {
      //if email & password correct -> navigate to user main page
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => UserMain()));
    } on FirebaseAuthException catch (error) {
      //if user email is not registered
      if (error.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blueGrey,
          content: Text('No user found for that email.',
              style: TextStyle(fontSize: 15.0, color: Colors.amber)),
        ));
      }
      //if user email is registered but password is wrong
      else if (error.code == 'wrong-password') {
        print('Wrong password provided by the user.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blueGrey,
          content: Text('Wrong password provided by the user.',
              style: TextStyle(fontSize: 15.0, color: Colors.amber)),
        ));
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 30.0),
          child: ListView(
            children: [
              //Title: Welcome to HiSG
              Container(
                margin: EdgeInsets.only(top: 120.0, bottom: 20),
                child: RichText(
                  text: TextSpan(
                    text: 'Welcome to ',
                    style: TextStyle(
                        fontSize: 33.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'HiSG',
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
              ),
              //Email TextForm Field
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 52,
                    child: TextFormField(
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: ' Email ',
                          labelStyle: TextStyle(fontSize: 14.0),
                          border: OutlineInputBorder(),
                          errorStyle: TextStyle(
                            color: Colors.black26,
                            fontSize: 13,
                          ),
                        ),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ' Please enter email ';
                          } else if (!value.contains('@')) {
                            return ' Please enter valid email ';
                          }
                          return null;
                        }),
                  )),
              //Password TextForm Field
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 52,
                    child: TextFormField(
                        autofocus: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: ' Password ',
                          labelStyle: TextStyle(fontSize: 14.0),
                          border: OutlineInputBorder(),
                          errorStyle: TextStyle(
                            color: Colors.black26,
                            fontSize: 15,
                          ),
                        ),
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ' Please enter password ';
                          }
                          return null;
                        }),
                  )),
              //Forget password
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child:
                    //forget password
                    Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      child: new Text(
                        ' Forgot password?',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword(),))
                      }),
                ),
              ),

              //Login button
              Container(
                  margin: EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).primaryColor),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white)),
                          child: Text(
                            "Sign in",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                                password = passwordController.text;
                              });
                              userLogin();
                            }
                          }))),
              //sign up navigator
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Not have an account yet?  ',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                            child: new Text(
                              'Create an account',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => {
                              Navigator.pushAndRemoveUntil(context, PageRouteBuilder(
                                pageBuilder: (context, a, b) => SignUp(), transitionDuration: Duration(seconds: 0)),
                                 (route) => false)
                            }),
                      ],
                    )),
              ),
              //or
              Container(
                margin: EdgeInsets.only(top: 60, bottom: 0),
                child: Center(
                  child: Text(
                    "or",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              //google log in
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(Colors.blue[900]),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white)),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Login with Google ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Image.asset(
                                "assets/icons/google.png",
                                width: 30,
                              )),
                        ),
                      ]),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
