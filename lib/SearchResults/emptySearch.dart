import 'package:flutter/material.dart';

class EmptySearchScreen extends StatelessWidget {
  const EmptySearchScreen({ Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
      padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 120,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            CategoryIndicator(),
            CategoryIndicator(),
            CategoryIndicator(),
            CategoryIndicator(),
          ],),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            CategoryIndicator(),
            CategoryIndicator(),
            CategoryIndicator(),
            CategoryIndicator(),
          ],),
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.only(left: 35, top:30),
            child: Text("Top Search", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),),
          ),
          TopSearchItem(),
          TopSearchItem(),
          TopSearchItem(),
          TopSearchItem(),
        ],
      ),
    ),
    );
  }
}

class CategoryIndicator extends StatelessWidget {
  const CategoryIndicator({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null,
      child: Column(
        children:[
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/img/placeholder.png"),
          ),
          SizedBox(height: 10,),
          Text("cat", style: TextStyle(fontSize: 15),)
        ]   
      ),
    );
  }
}

class TopSearchItem extends StatelessWidget {
  const TopSearchItem({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Stack(
    alignment: Alignment.center,
    children: <Widget>[
      Padding(padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Image.asset("assets/img/placeholder.png", width: double.infinity, height: 100,fit: BoxFit.cover,),),
        Text("someText", style: TextStyle(fontSize: 25),),
    ]
),
      )
    );
  }
}