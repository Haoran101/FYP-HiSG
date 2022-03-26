import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';

class UI {

  static Widget tihImageBanner({width, height, TIHDetails? tihDetails}) {
    return Container(
            width: double.parse(width.toString()),
            height: double.parse(height.toString()),
            alignment: Alignment.center,
            child: tihDetails!.getImage());
  }

}