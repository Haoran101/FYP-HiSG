// ignore_for_file: unnecessary_import

import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_expansion.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:drag_and_drop_lists/drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/Plan/plan_model.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

class ExpansionTileExample extends StatefulWidget {
  ExpansionTileExample({Key? key}) : super(key: key);

  @override
  _ListTileExample createState() => _ListTileExample();
}

class _ListTileExample extends State<ExpansionTileExample> {
  final UserService _user = UserService();
  late Plan _plan;

  @override
  void initState() {
    super.initState();
    //TODO: get plan from user database
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: _user.getPlan(),
        builder: (context, AsyncSnapshot<Plan?> snapshot) {
          if (snapshot.hasError) {
            print("Error loading plan");
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Error loading plan"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            //TODO: not logged in page
            return Text("not logged in exception");
          } 

          this._plan = snapshot.data!;
          return Container(
          height: 900,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: DragAndDropLists(
                children:
                    List.generate(_plan.dayList.length, (index) => _buildList(index)),
                onItemReorder: _onItemReorder,
                onListReorder: _onListReorder,
                itemDragOnLongPress: true,
                listDragOnLongPress: true,
                listDecorationWhileDragging: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                listDivider: Divider(thickness: 2, height: 2, color: Colors.grey),
                itemDecorationWhileDragging: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 5)],
                ),
                listDragHandle: _buildDragHandle(isList: true),
                itemDragHandle: _buildDragHandle(),
                // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
                listGhost: Container(
                  height: 70,
                  color: Colors.grey,
                )),
          ),
        );

        },
      ),
    );
  }

  _buildList(int outerIndex) {
    Day day = _plan.dayList[outerIndex];
    return DragAndDropListExpansion(
      canDrag: false,
      initiallyExpanded: outerIndex == 0? true: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${day.name}',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      children: List.generate(day.activities.length,
          (index) => _buildItem(day.activities[index])),
      listKey: ObjectKey(day.activities),
    );
  }

  DragHandle _buildDragHandle({bool isList = false}) {
    if (isList) {
      return DragHandle(
        child: Container(
          height: 0,
        ),
      );
    }

    final color = isList ? Colors.blueGrey : Colors.black26;

    return DragHandle(
      verticalAlignment: DragHandleVerticalAlignment.center,
      child: Container(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.menu, color: color),
      ),
    );
  }

  _buildItem(SearchResult item) {
    return DragAndDropItem(
      child: Dismissible(
        key: Key(item.resultId),
        child: ListTile(
          leading: item.icon,
          title: Text(item.title),
          subtitle: Text(item.subtitle!),
        ),
        onDismissed: (direction) {
          //left to right
          if (direction == DismissDirection.startToEnd) {
            //TODO: add to archieve
          } else if (direction == DismissDirection.endToStart){
            //TODO: delete item  
          }
        },
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _plan.dayList[oldListIndex].activities.removeAt(oldItemIndex);
      _plan.dayList[newListIndex].activities.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _plan.dayList.removeAt(oldListIndex);
      _plan.dayList.insert(newListIndex, movedList);
    });
  }
}
