import 'package:flutter/material.dart';

class DraggableList {
  final String day; //day
  final List<DraggableListItem> activities; //activities

  const DraggableList({
    required this.day,
    required this.activities,
  });
}

class DraggableListItem {
  final String title; //title of activity
  final Icon icon; //icon

  const DraggableListItem({
    required this.title,
    required this.icon,
  });
}
