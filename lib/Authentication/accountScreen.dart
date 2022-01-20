import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/forget_password.dart';
import 'package:wikitude_flutter_app/Authentication/login.dart';
import 'package:wikitude_flutter_app/Authentication/signup.dart';

import 'user_main.dart';

enum AuthPage { login, signup, forget, usermain }

// ignore: camel_case_types
class AuthScreenPlaceHolder extends StatefulWidget {
  
  @override
  State<AuthScreenPlaceHolder> createState() => _AuthScreenPlaceHolderState();
}

class _AuthScreenPlaceHolderState extends State<AuthScreenPlaceHolder> with AutomaticKeepAliveClientMixin{
  AuthPage _currentPage = FirebaseAuth.instance.currentUser!= null? 
      AuthPage.usermain: AuthPage.login;
  
  Map<AuthPage, String> title = {
    AuthPage.login: 'Login', 
    AuthPage.signup:'Sign up', 
    AuthPage.usermain: 'My Account', 
    AuthPage.forget: 'Reset Password'};

  setPage(AuthPage page){
    setState(() {
      _currentPage = page;
    });
  }

  getBody(){
    switch(_currentPage){
      case AuthPage.login:
        return LoginPage(setPage: this.setPage);
      case AuthPage.signup: 
        return SignUp(setPage: this.setPage);
      case AuthPage.usermain:
        return UserMain(setPage: this.setPage);
      case AuthPage.forget:
        return ForgotPassword(setPage: this.setPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title[_currentPage]!),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: getBody()
    );
  }

  @override
  bool get wantKeepAlive => true;
}