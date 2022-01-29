import 'package:flutter/material.dart';

import '../model/draggable_list.dart';

List<DraggableList> allLists = [
  DraggableList(
    day: 'Best Fruits',
    activities: [
      DraggableListItem(
        title: 'Orange',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
      DraggableListItem(
        title: 'Apple',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
      DraggableListItem(
        title: 'Blueberries',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
    ],
  ),
  DraggableList(
    day: 'Good Fruits',
    activities: [
      DraggableListItem(
        title: 'Lemon',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
      DraggableListItem(
        title: 'Melon',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
      DraggableListItem(
        title: 'Papaya',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
    ],
  ),
  DraggableList(
    day: 'Disliked Fruits',
    activities: [
      DraggableListItem(
        title: 'Banana',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
      DraggableListItem(
        title: 'Strawberries',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
      DraggableListItem(
        title: 'Grapefruit',
        icon: Icon(Icons.insert_emoticon_rounded)
      ),
    ],
  ),
];
