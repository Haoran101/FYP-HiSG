import 'package:flutter/material.dart';

var _floatStyle = TextStyle(
    letterSpacing: 2.2,
    color: Colors.white,
    fontFamily: "Montserrat",
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ]);

var _imageFilterOpacity = 0.7;

class EmptySearchScreen extends StatelessWidget {
  const EmptySearchScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 80,
          ),
          Banner(
              text: "360 GALLERY",
              image: "assets/img/explore/singapore.jpg",
              call: () => null),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              HalfBanner(
                  text: "PRECINCT",
                  image: "assets/img/explore/chinatown.jpg",
                  color: Colors.red[900]!,
                  call: () => null),
              Spacer(),
              HalfBanner(
                  text: "WALKING\n  TRAIL",
                  image: "assets/img/explore/walking.jpg",
                  color: Colors.green,
                  call: () => null),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              HalfBanner(
                  text: "TRANSPORT",
                  image: "assets/img/explore/mrt.jpg",
                  color: Colors.blueAccent,
                  call: () => null),
              Spacer(),
              HalfBanner(
                  text: "CURRENCY",
                  image: "assets/img/explore/money.jpg",
                  color: Colors.deepOrangeAccent,
                  call: () => null),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Nearby Spots",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              height: 150,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 120,
                        color: Colors.amber,
                      ),
                    );
                  })),
            ),
          ),
        ],
      ),
    );
  }
}

class Banner extends StatelessWidget {
  Banner({required this.text, required this.image, required this.call});
  final String text;
  final String image;
  final Function call;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => this.call,
        child: Container(
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(_imageFilterOpacity), BlendMode.dstATop),
                      image: new AssetImage(
                        this.image,
                      )),
                ),
              ),
            ),
            Text(
              this.text,
              style: _floatStyle.copyWith(fontSize: 25),
            ),
          ]),
        ));
  }
}

class HalfBanner extends StatelessWidget {
  HalfBanner({required this.text, required this.image, required this.color, required this.call});
  final String text;
  final String image;
  final Color color;
  final Function call;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => this.call,
        child: Container(
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                width: 170,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  image: new DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(_imageFilterOpacity), BlendMode.dstATop),
                      image: new AssetImage(
                        this.image,
                      )),
                ),
              ),
            ),
            Text(
              this.text,
              style: _floatStyle.copyWith(fontSize: 15),
            ),
          ]),
        ));
  }
}
