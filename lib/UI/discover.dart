import 'package:flutter/material.dart';

class discoverContent extends StatelessWidget {
  const discoverContent
({ Key? key }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: 
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
        //
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const titleText(title: "Popular",),
          const feedCard(width: 400.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa.",),
          Row(children: [
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
          Row(children: [
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
          Row(children: [
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
          Row(children: [
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            const feedCard(width: 150.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
        ]
      ),),
    );
  }
}

class titleText extends StatelessWidget {
  final title;
  const titleText({Key? key, @required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold);
    return Text(this.title, style: titleStyle,);
  }
}

class feedCard extends StatelessWidget {
  final title;
  final img;
  final description;
  final width;
  const feedCard({Key? key, @required this.title, @required this.img, @required this.description, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _picheight = (width>300) ? width/3 : width/1.8;
    return Container(
      margin: const EdgeInsets.all(10),
      width: width,
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: null,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset("assets/img/placeholder.png", height:_picheight, fit:BoxFit.fill),
            ListTile(
                    minVerticalPadding: 10,
                    title: Text(this.title, textScaleFactor: 1.1, style: TextStyle(height: 1.5),),
                    subtitle: Padding(padding: EdgeInsets.only(top: 5), child: Text(this.description)),
            ),
        ]),))
        );
  }
}