import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

class Test extends StatefulWidget {
  const Test({ Key? key }) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  UserService _user = UserService();

  @override
  Widget build(BuildContext context) {
    var userInfo = _user.getCurrentUser.toString();
    return Container(
      child: Text(userInfo)
    );
  }
}