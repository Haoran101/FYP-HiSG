// ignore_for_file: unnecessary_import

import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_expansion.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/Plan/plan_model.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

class ExpansionTileExample extends StatefulWidget {
  @override
  _ListTileExample createState() => _ListTileExample();
}

class _ListTileExample extends State<ExpansionTileExample> {
  final UserService _user = UserService();
  late Plan _plan;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.white,
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            //Not logged in page
            return Container(
                child: Column(children: [
              SizedBox(
                height: 100,
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Login to ',
                      style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'start a plan',
                            style: TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 70,),
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Theme.of(context).primaryColor),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white)),
                        child: Text(
                          "Sign in",
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthScreenPlaceHolder()),
                            )),
                  ),
                ),
              ),
              Spacer(),
              Image.asset("assets/img/plan.jpg"),
            ]));
          }

          //Logged in plan page
          this._plan = snapshot.data!;
          return Container(
            height: 900,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: DragAndDropLists(
                  children: List.generate(
                      _plan.dayList.length, (index) => _buildList(index)),
                  onItemReorder: _onItemReorder,
                  onListReorder: _onListReorder,
                  itemDragOnLongPress: true,
                  listDragOnLongPress: true,
                  listDecorationWhileDragging: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                  ),
                  listDivider:
                      Divider(thickness: 2, height: 2, color: Colors.grey),
                  itemDecorationWhileDragging: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 5)
                    ],
                  ),
                  // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
                  listGhost: Container(
                    height: 70,
                    color: Colors.grey[800]
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
      initiallyExpanded: outerIndex == 0 ? true : false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${day.name}',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      children: List.generate(day.activities.length,
          (index) => _buildItem(day.activities[index], index, outerIndex)),
      listKey: ObjectKey(day.activities),
    );
  }

  _buildItem(SearchResult item, int innerIndex, int outerIndex) {
    return DragAndDropItem(
      child: Dismissible(
        key: Key(item.resultId),
        background: Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.archive_outlined, color: Colors.white),
                ),
                Text('Move to archieve', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                Text('Move to trash', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        child: ListTile(
          leading: item.icon,
          title: Text(item.title),
          subtitle: Text(item.subtitle!),
        ),
        confirmDismiss: (DismissDirection direction) async {
          final String alertText = (direction == DismissDirection.startToEnd)
              ? "Move item to archieve?"
              : "Delete this item from plan?";
          final String buttonText = (direction == DismissDirection.startToEnd)
              ? "Archieve"
              : "Delete";
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(alertText),
                contentPadding: EdgeInsets.all(30),
                actions: <Widget>[
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: (direction == DismissDirection.startToEnd)
                            ? Theme.of(context).primaryColor
                            : Colors.red,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(buttonText)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: (direction == DismissDirection.startToEnd)
                              ? Theme.of(context).primaryColor
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          //left to right
          if (direction == DismissDirection.startToEnd) {
            //add to archieve
            var totalDays = this._plan.dayList.length;
            this._plan.dayList[totalDays - 1].activities.add(item);
            this._plan.dayList[outerIndex].activities.removeAt(innerIndex);
            this._plan.updateMain();
            _user.updatePlanMainInDatabase(_plan.toMainJSON());
          } else if (direction == DismissDirection.endToStart) {
            //delete item
            this._plan.dayList[outerIndex].activities.removeAt(innerIndex);
            this._plan.updateMain();
            _user.updatePlanMainInDatabase(_plan.toMainJSON());
          }
        },
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem =
          _plan.dayList[oldListIndex].activities.removeAt(oldItemIndex);
      _plan.dayList[newListIndex].activities.insert(newItemIndex, movedItem);
    });
    _plan.updateMain();
    _user.updatePlanMainInDatabase(_plan.toMainJSON());
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    return;
  }
}
