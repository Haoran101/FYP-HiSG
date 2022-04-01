import 'package:flutter/material.dart';
import 'package:hi_sg/Models/tih_model.dart';

class UI {

  static Widget tihImageBanner({width, height, TIHDetails? tihDetails}) {
    return Container(
            width: double.parse(width.toString()),
            height: double.parse(height.toString()),
            alignment: Alignment.center,
            child: tihDetails!.getImage());
  }

  static Widget errorMessage() {
    return Container(
      child: Column(
        children: [
          Center(child: Container(
            height: 100,
            child: Image.asset("assets/img/error.jpg"))),
          Center(child: Text("Oops, Something went wrong. \nPlease try again later.",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          )

          )
        ],
      )
      ,
    );
  }

  static void showCustomSnackBarMessage(BuildContext context, String message){
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 1),
          content: Text(message,
              style: TextStyle(fontSize: 15.0, color: Colors.white)),
        ));
  }

}