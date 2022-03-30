import 'package:flutter/material.dart';
import 'package:hi_sg/Authentication/forget_password.dart';
import 'package:hi_sg/Authentication/login.dart';
import 'package:hi_sg/Authentication/signup.dart';
import 'package:hi_sg/User/UserService.dart';

import 'user_main.dart';

enum AuthPage { login, signup, forget, usermain }

// ignore: camel_case_types
class AuthScreenPlaceHolder extends StatefulWidget {
  AuthScreenPlaceHolder();
  
  @override
  State<AuthScreenPlaceHolder> createState() => _AuthScreenPlaceHolderState();
}

class _AuthScreenPlaceHolderState extends State<AuthScreenPlaceHolder> with AutomaticKeepAliveClientMixin{
  final UserService _user = UserService();
  var _currentPage;

  @override
  void initState() {
    defineCurrentPage();
    super.initState();
  }
  
  defineCurrentPage(){
    _currentPage = _user.getCurrentUser != null? 
      AuthPage.usermain: AuthPage.login;
  }
  // AuthPage _currentPage = FirebaseAuth.instance.currentUser!= null? 
  //     AuthPage.usermain: AuthPage.login;
  
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