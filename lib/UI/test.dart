import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/UI/paintLine.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

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
      child: Column(children: [
        Row(children: [
          Container(height: 50,
            width: 80,
            child: Center(child: Text("CC23")),),
          Container(
            height: 50,
            width: 50,
            child: Stack(children: [
              renderLine([-1, -1], [-1, 1], Size(50, 50)),
              renderLine([1, 0], [0, 0], Size(50, 50)),
              renderLine([0, -1], [0, 1], Size(50, 50)),
              Center(
                  child: Icon(
                Icons.circle,
                color: Colors.white,
              )),
              Center(child: Icon(Icons.circle_outlined))
            ]),
          ),
          Container(
              height: 50,
              width: 50,
              child: Stack(
                children: [
                  renderLine([-1, 0], [0, 0], Size(50, 50)),
                  Center(
                      child: Icon(
                    Icons.circle,
                    color: Colors.white,
                  )),
                  Center(child: Icon(Icons.circle_outlined))
                ],
              ))
        ]),
        
        Row(children: [
          Container(height: 50,
            width: 80,
            child: Center(child: Text("CC23")),),
          Container(
            height: 50,
            width: 50,
            child: Stack(children: [
              renderLine([-1, -1], [0, 0], Size(50, 50)),
              renderLine([1, 0], [0, 0], Size(50, 50)),
              renderLine([1, 0], [1, 2], Size(50, 50)),
              Center(
                  child: Icon(
                Icons.circle,
                color: Colors.white,
              )),
              Center(child: Icon(Icons.circle_outlined))
            ]),
          ),
          Container(
              height: 50,
              width: 30,
              child: Stack(
                children: [
                  renderLine([0, 1], [1, 1], Size(50, 50)),
                  Center(
                      child: Icon(
                    Icons.circle,
                    color: Colors.white,
                  )),
                  Center(child: Icon(Icons.circle_outlined))
                ],
              ))
        ]),
        Row(children: [
          Container(height: 50,
            width: 80,
            child: Center(child: Text("CC23")),),
          Container(
            height: 50,
            width: 50,
            child: Stack(children: [
              renderLine([1, 0], [1, 2], Size(50, 50)),
              renderLine([2, 1], [1, 1], Size(50, 50)),
              Center(
                  child: Icon(
                Icons.circle,
                color: Colors.white,
              )),
              Center(child: Icon(Icons.circle_outlined))
            ]),
          ),
          Container(
              height: 50,
              width: 50,
              child: Stack(
                children: [
                  renderLine([0, 1], [1, 1], Size(50, 50)),
                  Center(
                      child: Icon(
                    Icons.circle,
                    color: Colors.white,
                  )),
                  Center(child: Icon(Icons.circle_outlined))
                ],
              ))
        ]),
      ]),
    );
  }
}
