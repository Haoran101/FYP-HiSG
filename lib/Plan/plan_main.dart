// ignore_for_file: unnecessary_import

import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_expansion.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wikitude_flutter_app/Authentication/accountScreen.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/Plan/plan_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';
import 'package:wikitude_flutter_app/SearchResults/search.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';
import 'package:wikitude_flutter_app/User/UserService.dart';

class ExpansionTileExample extends StatefulWidget {
  @override
  _ListTileExample createState() => _ListTileExample();
}

class _ListTileExample extends State<ExpansionTileExample> {
  final UserService _user = UserService();
  late Plan _plan;

  _showNewDayDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Create a new day: Day ${this._plan.dayList.length} ?"),
          contentPadding: EdgeInsets.all(30),
          actions: <Widget>[
            //Confirm button
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                onPressed: () {
                  _addNewDay();
                  Navigator.of(context).pop(true);
                  UI.showCustomSnackBarMessage(context, "New empty day added!");
                },
                child: Text("Confirm")),
            //Cancel button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _calculateHeight() {
      print(this._plan.dayList);
      double height = (this._plan.dayList.length) * 80;
      for (Day d in this._plan.dayList) {
        height += d.activities.length * 80;
      }
      print("Height: $height");
      return height;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Plan'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: InkWell(
                  child: Icon(Icons.emoji_objects_outlined),
                  onTap: () {
                    try {
                      int nextDay = this._plan.dayList.length;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecommendOptionsUI(
                                  nextday: nextDay,
                                  addRecommendDay: (recommended) {
                                    _addNewDay(recommendedList: recommended);
                                  },
                                )),
                      );
                    } catch (error, stackTrace) {
                      print(error);
                      print(stackTrace);
                      UI.showCustomSnackBarMessage(context, "Failed to load recommedation page.");
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: InkWell(
                  child: Icon(Icons.add),
                  onTap: () {
                    try {
                      print(this._plan);
                      _showNewDayDialog();
                    } catch (error) {
                      print(error);
                      UI.showCustomSnackBarMessage(context, "Failed to add new day to plan.");
                    }
                  } //Add a new day
                  ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _user.getPlan(),
          builder: (context, AsyncSnapshot<Plan?> snapshot) {
            if (snapshot.hasError) {
              print("Error loading plan");
              return UI.errorMessage();
              
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            //not Logged in
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
                SizedBox(
                  height: 70,
                ),
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
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white)),
                          child: Text(
                            "Sign in",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AuthScreenPlaceHolder()),
                              )),
                    ),
                  ),
                ),
                Spacer(),
                Image.asset("assets/img/plan.jpg"),
              ]));
            } else {
              //Logged in plan page
              this._plan = snapshot.data!;

              return
                  //Main Plan View
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 5, right: 5),
                    child: Container(
                      height: _calculateHeight(),
                      child: DragAndDropLists(
                          children: List.generate(
                              _plan.dayList.length, (index) => _buildList(index)),
                          onItemReorder: _onItemReorder,
                          onListReorder: (a, b) => null,
                          itemDragOnLongPress: true,
                          listDragOnLongPress: true,
                          itemDivider: Divider(
                              thickness: 2, height: 2, color: Colors.grey[100]),
                          listDecorationWhileDragging: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          listDivider: Divider(
                              thickness: 2, height: 2, color: Colors.grey[100]),
                          itemDecorationWhileDragging: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black45, blurRadius: 5)
                            ],
                          ),
                          // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
                          listGhost:
                              Container(height: 70, color: Colors.grey[800])),
                    ),
                  );
            }
          },
        ));
  }

  _buildList(int outerIndex) {
    Day day = _plan.dayList[outerIndex];
    return DragAndDropListExpansion(
      canDrag: false,
      initiallyExpanded: day.activities.length == 0 ? false : true,
      title: Container(
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [Text(
            '${day.name}',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Spacer(),
          outerIndex != _plan.dayList.length - 1?
          InkWell(child: Icon(Icons.delete_rounded, color: Colors.grey,),
          onTap: () => _showDeleteDayDialog(outerIndex)): SizedBox.shrink()
          ]
        ),
      ),
      children: List.generate(day.activities.length,
          (index) => _buildItem(day.activities[index], index, outerIndex)),
      listKey: ObjectKey(day.activities),
    );
  }

  _buildItem(SearchResult item, int innerIndex, int outerIndex) {
    bool _isInArchieve = outerIndex == this._plan.dayList.length - 1;
    Widget moveToTrashBanner = MoveToTrashBanner(MainAxisAlignment.end);
    Widget moveToTrashBannerLeft = MoveToTrashBanner(MainAxisAlignment.start);
    Widget archieveBanner = Container(
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
    );
    return DragAndDropItem(
      child: Dismissible(
        key: Key(item.resultId),
        background: _isInArchieve ? moveToTrashBannerLeft : archieveBanner,
        secondaryBackground: moveToTrashBanner,
        child: Container(
          height: 70,
          child: ListTile(
            leading: item.icon,
            title: Text(item.title),
            subtitle: Text(item.subtitle!),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPageContainer(
                        searchResult: item,
                      )),
            ),
          ),
        ),
        confirmDismiss: (DismissDirection direction) async {
          String alertText;
          String buttonText;
          if (_isInArchieve) {
            //Dismiss in activity in archieve => both delete
            alertText = "Delete this item from plan?";
            buttonText = "Delete";
          } else {
            //Dismiss activity not in archieve => move to archieve / delete
            alertText = (direction == DismissDirection.startToEnd)
                ? "Move item to archieve?"
                : "Delete this item from plan?";
            buttonText = (direction == DismissDirection.startToEnd)
                ? "Archieve"
                : "Delete";
          }

          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(alertText),
                contentPadding: EdgeInsets.all(30),
                actions: <Widget>[
                  //Confirm button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: (direction == DismissDirection.startToEnd)
                            ? Theme.of(context).primaryColor
                            : Colors.red,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(buttonText)),
                  //Cancel button
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
            if (_isInArchieve) {
              //delete item
              _deleteItem(item, outerIndex, innerIndex);
            } else {
              //add to archieve
              _addToArchieve(item, outerIndex, innerIndex);
            }
          } else if (direction == DismissDirection.endToStart) {
            //delete item
            _deleteItem(item, outerIndex, innerIndex);
          }
        },
      ),
    );
  }

  _addNewDay({recommendedList = const <SearchResult>[]}) {
    int nextDay = this._plan.dayList.length;
    Day newDay = Day(
      name: 'Day $nextDay',
      activities: recommendedList,
    );
    setState(() {
      this._plan.dayList.insert(nextDay - 1, newDay);
    });
    print("New Day Created: ${newDay.name}");
    this._plan.updateMain();
    _user.updatePlanMainInDatabase(this._plan);
    for (var item in recommendedList){
      _user.addRecommendedPlanItem(item);
    }
  }

  _deleteItem(item, outerIndex, innerIndex) {
    setState(() {
      this._plan.dayList[outerIndex].activities.removeAt(innerIndex);
    });
    this._plan.updateMain();
    _user.updatePlanMainInDatabase(this._plan);
  }

  _addToArchieve(item, outerIndex, innerIndex) {
    var totalDays = this._plan.dayList.length;
    setState(() {
      this._plan.dayList[totalDays - 1].activities.add(item);
      this._plan.dayList[outerIndex].activities.removeAt(innerIndex);
    });
    this._plan.updateMain();
    _user.updatePlanMainInDatabase(this._plan);
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem =
          _plan.dayList[oldListIndex].activities.removeAt(oldItemIndex);
      _plan.dayList[newListIndex].activities.insert(newItemIndex, movedItem);
    });
    _plan.updateMain();
    _user.updatePlanMainInDatabase(this._plan);
  }

  _showDeleteDayDialog(int outerIndex) {
    Day _day = this._plan.dayList[outerIndex];
    String _moveToArchieveString = _day.activities.length > 0?
    " and all ${_day.activities.length} activities will be moved to archieve": "";
    
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete ${_day.name}? '),
            content: Text("Days in the plan will be re-indexed" + _moveToArchieveString + "."),
            actions: [
              //Confirm button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  onPressed: () {
                    _deleteDay(outerIndex);
                    Navigator.of(context).pop(true);
                  },
                  child: Text("OK")),
              //Cancel Button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Cancel")),
            ],
          );}
        );
    

  }

  _deleteDay(int outerIndex) {
    setState(() {
      this._plan.dayList.removeAt(outerIndex);
      for (int i=0; i<_plan.dayList.length - 1; i++){
        _plan.dayList[i].name = "Day ${i+1}";
      }
    });
    _plan.updateMain();
    _user.updatePlanMainInDatabase(this._plan);
  }
}

class MoveToTrashBanner extends StatelessWidget {
  MoveToTrashBanner(this.mainAlignment);

  final mainAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: mainAlignment,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            Text('Move to trash', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class RecommendOptionsUI extends StatefulWidget {
  RecommendOptionsUI({required this.nextday, required this.addRecommendDay});
  final nextday;
  final Function(List<SearchResult>) addRecommendDay;

  @override
  State<RecommendOptionsUI> createState() => _RecommendOptionsUIState();
}

class _RecommendOptionsUIState extends State<RecommendOptionsUI> {
  late DateTime currentDate;
  bool isLoading = true;
  final Map<String, String> interestMap = {
    "Arts & Culture": "arts_culture",
    "Entertainment & Nightlife": "entertainment_nightlife",
    "Food": "food",
    "History & Heritage": "history_heritage",
    "Sport & Outdoors": "sport_outdoors",
    "Shopping": "shopping"
  };
  Map<String, bool> isCheckedMap = {
    "arts_culture": false,
    "entertainment_nightlife": false,
    "food": false,
    "history_heritage": false,
    "sport_outdoors": false,
    "shopping": false,
  };
  @override
  void initState() {
    currentDate = DateTime.now();
    super.initState();
  }

  _showLoadingDialog() {
    if (isLoading) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 100,
              width: 100,
              child: Center(
                child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor)),
              ),
            ),
          );
        },
      );
    }
  }

  String _dateFormatter(DateTime date) {
    String month =
        date.month < 10 ? "0" + date.month.toString() : date.month.toString();
    String day =
        date.day < 10 ? "0" + date.day.toString() : date.day.toString();
    return "${date.year}-$month-$day";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
      });
  }

  Widget _checkBoxTile(String text) {
    bool ischecked = isCheckedMap[interestMap[text]] ?? false;
    return CheckboxListTile(
      title: Text(text),
      value: ischecked,
      onChanged: (bool? value) {
        setState(() {
          isCheckedMap[interestMap[text]!] = !ischecked;
        });
        print(isCheckedMap);
      },
      secondary: const Icon(Icons.favorite_outline_rounded),
    );
  }

  getRecommendation() async {
    String date = _dateFormatter(currentDate);
    List<String> confirmedInterest =
        List.from(isCheckedMap.keys.where((x) => isCheckedMap[x] == true));

    var recResult = await RecommendationEngine()
        .getRecommendResult(confirmedInterest, date);
    return recResult;
  }

  _showConfirmationDialog(searchResultList) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
                "Day ${this.widget.nextday} has been generated! "),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            content: Container(
              height: searchResultList.length * 60.0 + 100.0,
              width: double.infinity - 50,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        searchResultList.length,
                        (index) =>
                            SearchResultCard(item: searchResultList[index]))),
              ),
            ),
            actions: [
              //Confirm button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  onPressed: () {
                    
                    this.widget.addRecommendDay(searchResultList);
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                    UI.showCustomSnackBarMessage(context, "Recommended day added!");
                  },
                  child: Text("Add")),
              //Cancel Button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Cancel")),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommend a day'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
            //Date
            children: [
              RecommendTitle("Date"),
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 15),
                      hintText: _dateFormatter(currentDate),
                    ),
                    enabled: false,
                  ),
                ),
                InkWell(
                    child: Icon(Icons.event_available_outlined),
                    onTap: () => _selectDate(context))
              ]),
              //interests
              SizedBox(
                height: 30,
              ),
              RecommendTitle("Interests"),
              Column(
                children: List.generate(
                    interestMap.length,
                    (index) =>
                        _checkBoxTile(List.from(interestMap.keys)[index])),
              ),
              SizedBox(
                height: 80,
              ),
              Container(
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).primaryColor),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white)),
                          child: Text(
                            "Get Recommendation",
                            style: TextStyle(fontSize: 17),
                          ),
                          onPressed: () {
                            _showLoadingDialog();
                            getRecommendation().then((recList) {
                              Navigator.of(context).pop(true);
                              _showConfirmationDialog(recList);
                            });
                          }))),
            ]),
      ),
    );
  }
}

class RecommendTitle extends StatelessWidget {
  RecommendTitle(this.text);
  final text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        this.text,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
