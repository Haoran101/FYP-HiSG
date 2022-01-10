import 'package:flutter/material.dart';

class discoverContent extends StatelessWidget {
  const discoverContent
({ Key? key }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text('Discover SG'),
        backgroundColor: Theme.of(context).primaryColor,),
      body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: 
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
        //
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const TitleText(title: "Popular",),
          Row(children: [
            const FeedCard(width: 340.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa.",)]
          ),
          Row(children: [
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            SizedBox(width: 20),
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
          Row(children: [
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            SizedBox(width: 20),
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
          Row(children: [
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            SizedBox(width: 20),
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
          Row(children: [
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
            SizedBox(width: 20),
            const FeedCard(width: 160.0, title: "Title", img: "Image", description: "Lorem ipsum dolor sit amet, consectetuer.",),
          ],),
        ]
      ),),
    )
    ); 
  }
}

class TitleText extends StatelessWidget {
  final title;
  const TitleText({Key? key, @required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold);
    return Text(this.title, style: titleStyle,);
  }
}

class FeedCardRow extends StatelessWidget {
  final children;
  const FeedCardRow({Key? key, @required this.children});
  
  @override
  Widget build(BuildContext context) {
    if (this.children.length == 1) {
      return Row(
      children: [
        FeedCard(width: 420.0, title: this.children[0].title, img: this.children[0].img, description: this.children[0].description,)
      ]
      );
    } else {
      return Row(
        children: [
          FeedCard(width: 200.0, title: this.children[0].title, img: this.children[0].img, description: this.children[0].description,),
          SizedBox(width: 20),
          FeedCard(width: 200.0, title: this.children[1].title, img: this.children[1].img, description: this.children[1].description,),
        ],
      );
    }
  }
}

class FeedCard extends StatelessWidget {
  final title;
  final img;
  final description;
  final width;
  const FeedCard({Key? key, @required this.title, @required this.img, @required this.description, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _picheight = (width>300) ? width/3 : width/1.8;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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