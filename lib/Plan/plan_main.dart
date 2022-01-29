import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'data/draggable_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'model/draggable_list.dart';

class PlanPage extends StatefulWidget {
  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late List<DragAndDropList> lists;

  @override
  void initState() {
    super.initState();
    lists = allLists.map(buildList).toList();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.fromARGB(255, 243, 242, 248);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("test plan page"),
        centerTitle: true,
      ),
      body: DragAndDropLists(
        // lastItemTargetHeight: 50,
        // addLastItemTargetHeightToTop: true,
        // lastListTargetSize: 30,
        listPadding: EdgeInsets.all(16),
        listInnerDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
        ),
        children: lists,
        itemDivider: Divider(thickness: 2, height: 2, color: backgroundColor),
        itemDecorationWhileDragging: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        listDragHandle: buildDragHandle(isList: true),
        itemDragHandle: buildDragHandle(),
        onItemReorder: onReorderListItem,
        onListReorder: onReorderList,
      ),
    );
  }

  DragHandle buildDragHandle({bool isList = false}) {
    final verticalAlignment = isList
        ? DragHandleVerticalAlignment.top
        : DragHandleVerticalAlignment.center;
    final color = isList ? Colors.blueGrey : Colors.black26;

    return DragHandle(
      verticalAlignment: verticalAlignment,
      child: Container(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.menu, color: color),
      ),
    );
  }

  DragAndDropList buildList(DraggableList list) => DragAndDropList(
        header: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            list.day,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        children: list.activities
            .map((item) => DragAndDropItem(
                  child: ListTile(
                    //TODO: change to ICON
                    leading: item.icon,
                    title: Text(item.title),
                  ),
                ))
            .toList(),
      );

  void onReorderListItem(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) {
    setState(() {
      final oldListItems = lists[oldListIndex].children;
      final newListItems = lists[newListIndex].children;

      final movedItem = oldListItems.removeAt(oldItemIndex);
      newListItems.insert(newItemIndex, movedItem);
    });
  }

  void onReorderList(
    int oldListIndex,
    int newListIndex,
  ) {
    setState(() {
      final movedList = lists.removeAt(oldListIndex);
      lists.insert(newListIndex, movedList);
    });
  }
}
