import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

class Test extends StatefulWidget {
  const Test({ Key? key }) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final UserService _user = UserService();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Container(
        child: 
        FutureBuilder
        (
          future: _user.getPlan(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("has error loading plan");
            }
            return Text("plan loaded");
          })
      ),
    );
  }
}