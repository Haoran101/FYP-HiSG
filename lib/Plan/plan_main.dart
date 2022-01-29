import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';

class ExpansionTileExample extends StatefulWidget {
  ExpansionTileExample({Key? key}) : super(key: key);

  @override
  _ListTileExample createState() => _ListTileExample();
}

class InnerList {
  final String name;
  List<String> children;
  InnerList({required this.name, required this.children});
}

class _ListTileExample extends State<ExpansionTileExample> {
  late List<InnerList> _lists;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(3, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(5, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        height: 900,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: DragAndDropLists(
              children:
                  List.generate(_lists.length, (index) => _buildList(index)),
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
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropListExpansion(
      canDrag: false,
      initiallyExpanded: outerIndex == 0? true: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'List ${innerList.name}',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
      listKey: ObjectKey(innerList),
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

  _buildItem(String item) {
    return DragAndDropItem(
      child: ListTile(
        title: Text(item),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}
