import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';

// ignore: must_be_immutable
class ForgotPassword extends StatefulWidget {

  Function setPage;

  ForgotPassword({required this.setPage});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formkey = GlobalKey<FormState>();

  var email = " ";

  final emailController = TextEditingController();

  resetPassword() async {
    try {
      //Send reset password email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blueGrey,
        content: Text('An email has been sent to reset your password.',
            style: TextStyle(fontSize: 15.0, color: Colors.amber)),
      ));

      widget.setPage();

    } on FirebaseAuthException catch (error) {
      //no user found for the email
      if (error.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black26,
            content: Text('No user found for that email.',
                style: TextStyle(fontSize: 15.0, color: Colors.amber)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              children: [
                Image.asset('assets/img/login/forget.jpg'),
                //send email text
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        ' Email will be sent to you to reset your password. ',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                
                //Email TextForm Field
                Form(
                  key: _formkey,
                  child: Container(
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
                ),
                //send email button
                Container(
                    margin: EdgeInsets.only(top: 40.0, bottom: 20.0),
                    child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white)),
                            child: Text(
                              " Send Email ",
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailController.text;
                                });
                                resetPassword();
                              }
                            }))),
                
                //Sign in with email
                Container(
                  margin: EdgeInsets.only(top: 30.0, bottom: 10.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                        child: new Text(
                          ' Sign in with email',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => {
                              widget.setPage(AuthPage.login)
                            }),
                  ),
                ),
                //Sign up
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
                                    widget.setPage(AuthPage.signup)
                                  }),
                        ],
                      )),
                ),
              ],
            ),
          ),
        );
  }
}
