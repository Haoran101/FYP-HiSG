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
import 'package:wikitude_flutter_app/SearchResults/search.dart';
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
                  } catch (error) {
                    print(error);
                    //TODO: snackbar notification
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
                    //TODO: snackbar notification
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
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Error loading plan"),
            );
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
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white)),
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
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child:
                  //Main Plan View
                  Column(children: [
                Container(
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
                ),
              ]),
            );
          }
        },
      ),
    );
  }

  _buildList(int outerIndex) {
    Day day = _plan.dayList[outerIndex];
    return DragAndDropListExpansion(
      canDrag: false,
      initiallyExpanded: day.activities.length == 0 ? false : true,
      title: Text(
        '${day.name}',
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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
        child: ListTile(
          leading: item.icon,
          title: Text(item.title),
          subtitle: Text(item.subtitle!),
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
    _user.updatePlanMainInDatabase(_plan.toMainJSON());
  }

  _deleteItem(item, outerIndex, innerIndex) {
    setState(() {
      this._plan.dayList[outerIndex].activities.removeAt(innerIndex);
    });
    this._plan.updateMain();
    _user.updatePlanMainInDatabase(_plan.toMainJSON());
  }

  _addToArchieve(item, outerIndex, innerIndex) {
    var totalDays = this._plan.dayList.length;
    setState(() {
      this._plan.dayList[totalDays - 1].activities.add(item);
      this._plan.dayList[outerIndex].activities.removeAt(innerIndex);
    });
    this._plan.updateMain();
    _user.updatePlanMainInDatabase(_plan.toMainJSON());
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

  _showLoadingDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 100,
            width: double.infinity - 100,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Loading"),
              ),
              SizedBox(
                  height: 40, width: 40, child: CircularProgressIndicator()),
            ]),
          ),
          contentPadding: EdgeInsets.all(30),
        );
      },
    );
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
      //TODO: customize icons
      secondary: const Icon(Icons.favorite_outline_rounded),
    );
  }

  getRecommendation() async {
    setState(() {
      isLoading = true;
    });
    String date = _dateFormatter(currentDate);
    List<String> confirmedInterest =
        List.from(isCheckedMap.keys.where((x) => isCheckedMap[x] == true));

    var recResult = await RecommendationEngine()
        .getRecommendResult(confirmedInterest, date);
    setState(() {
      isLoading = false;
      Navigator.of(context).pop();
    });

    if (recResult.length == 0)
    _showConfirmationDialog(recResult);
    return recResult;
  }

  _showConfirmationDialog(searchResultList) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
              height: 100,
              width: double.infinity - 100,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:
                          Text("A new day: Day ${this.widget.nextday} has been generated! "),
                    ),
                    Column(
                        children: List.generate(
                            searchResultList.length,
                            (index) => SearchResultCard(
                                item: searchResultList[index])))
                  ]),
            ),
            contentPadding: EdgeInsets.all(30),
            actions: [
              //Confirm button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  onPressed: () {
                    this.widget.addRecommendDay(searchResultList);
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(true);
                  },
                  child: Text("OK")),
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
              //TODO: get recommendation
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
                            getRecommendation();
                            if (isLoading) {
                              _showLoadingDialog();
                            }
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
