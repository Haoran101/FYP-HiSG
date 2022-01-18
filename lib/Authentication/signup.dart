import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formkey = GlobalKey<FormState>();

  var email = " ";
  var password = " ";
  var confirmPassword = " ";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  registration() async {
    if (password == confirmPassword) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        print(userCredential);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.blueGrey,
            content: Text(' Registered suucessfully. Please sign in. ',
                style: TextStyle(fontSize: 20.0)),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => loginPage(),
          ),
        );
      } on FirebaseAuthException catch (error) {
        //password is too weak
        if (error.code == 'weak-password') {
          print(' Password is too weak (less than 6 characters)');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black26,
              content: Text(' Password is too weak. ',
                  style: TextStyle(fontSize: 15.0, color: Colors.amber)),
            ),
          );
        }

        //already in use
        else if (error.code == 'email-already-in-use') {
          print(' Email is already exists ');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black26,
              content: Text(' Email provided is already registered. ',
                  style: TextStyle(fontSize: 15.0, color: Colors.amber)),
            ),
          );
        }
      }
    }

    //password and confirm password does not match
    else {
      print(' password and confirm password does not match. ');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black26,
          content: Text(' Password and confirm password does not match. ',
              style: TextStyle(fontSize: 15.0, color: Colors.amber)),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
              //Confirm Password TextForm Field
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 52,
                    child: TextFormField(
                        autofocus: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: ' Confirm Password ',
                          labelStyle: TextStyle(fontSize: 14.0),
                          border: OutlineInputBorder(),
                          errorStyle: TextStyle(
                            color: Colors.black26,
                            fontSize: 15,
                          ),
                        ),
                        controller: confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ' Please confirm password ';
                          }
                          return null;
                        }),
                  )),

              //Sign up button
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
                            "Sign up",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                                password = passwordController.text;
                                confirmPassword = confirmPasswordController.text;
                              });
                              registration();
                            }
                          }))),
              //login in navigator
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Already have an account?  ',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                            child: new Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      PageRouteBuilder(
                                          pageBuilder: (context, animation1, animation2) =>
                                              loginPage(),
                                          transitionDuration:
                                              Duration(seconds: 0)),
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
