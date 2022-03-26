import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/poi_model.dart';
import 'package:wikitude_flutter_app/SearchResults/poi_details.dart';
import 'package:wikitude_flutter_app/UI/MRT_line_page.dart';

import '../DataSource/google_maps_platform.dart';

class MRTStationPage extends StatefulWidget {
  late Map<String, dynamic> mrtData;
  MRTStationPage({required this.mrtData});

  @override
  State<MRTStationPage> createState() => _MRTStationPageState();
}

class _MRTStationPageState extends State<MRTStationPage> {
  MRTProvider _mrt = MRTProvider();
  var mrtData;
  POI? place;

  @override
  void initState() {
    this.mrtData = this.widget.mrtData;
    super.initState();
  }

  getPhotoView() {
    //print(this.place.toString());
    if (this.place!.photoReferences!.length < 3) {
      return GoogleImage(photoRef: place!.photoReferences![0], cover: true);
    } else {
      return Container(
        height: 200,
        child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: List.generate(
                place!.photoReferences!.length,
                (index) => GoogleImage(
                    photoRef: place!.photoReferences![index], cover: false))),
      );
    }
  }

  String getCodePrefix(String stationCode) {
    return stationCode.replaceAll(RegExp(r'[0-9]'), "");
  }

  Widget exitSection() {
    String _exit = "Exit";
    String _poi = "Place of Interest/Road";
    TextStyle normal = TextStyle(fontSize: 14);
    List<Widget> rows = [];
    for (final row in this.mrtData["exit_info"]) {
      String joinedPOI = row[_poi].join("\n");
      Widget infoRow = 
      Padding(
        padding: EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(right: 30),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Theme.of(context).primaryColor),
            child: Center(child: Text(row[_exit], style: TextStyle(color: Colors.white, fontSize: 25,),
            )),
          ),
          Flexible(child: Text(joinedPOI, style: TextStyle(fontSize: 14,  height: 1.5,),))
        ],
      ));
      rows.add(infoRow);
    }
    return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Column(children: rows,));
  }

  Future fetchPOIDetails() async {
    if (this.mrtData.containsKey("docRef")) {
      //accessed from line, need doc info
      Map<String, dynamic>? mrtDoc =
          await MRTProvider().fetchMRTDetailsByDocRef(this.mrtData["docRef"]);
      this.mrtData.addAll(mrtDoc);
    }
    String placeId = this.mrtData["place_id"];
    //print("place_id: " + placeId);
    this.place = (await PlaceApiProvider().getPlaceDetailFromId(placeId))!;
  }

  Widget stationCodeBlock(List stationCodeList) {
    List<Widget> blocks = [Spacer()];
    final _codeBlockWidth = 60.0;
    final _codeBlockHeight = 30.0;
    final _borderRadius = 10.0;

    int _counter = 0;
    for (var station in stationCodeList) {
      String code = station.toString();
      String codePrefix = getCodePrefix(code);
      String lineAbbv = _mrt.getLineAbbvFromLineCode(codePrefix);
      Color backgroundColor = _mrt.getColorFromLineAbbv(lineAbbv);

      blocks.add(
        Container(
            height: _codeBlockHeight,
            width: _codeBlockWidth,
            child: Center(
                child: Text(
              code,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: _counter == 0
                      ? Radius.circular(_borderRadius)
                      : Radius.zero,
                  bottomLeft: _counter == 0
                      ? Radius.circular(_borderRadius)
                      : Radius.zero,
                  topRight: _counter == stationCodeList.length - 1
                      ? Radius.circular(_borderRadius)
                      : Radius.zero,
                  bottomRight: _counter == stationCodeList.length - 1
                      ? Radius.circular(_borderRadius)
                      : Radius.zero,
                ))),
      );

      _counter++;
    }
    blocks.add(Spacer());

    return Center(
      child: Container(
        child: Row(
          children: blocks,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
        future: fetchPOIDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            print(snapshot.stackTrace);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            //Show circular progress indicator if loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          print("Loaded");
          bool NotShowExitInfo = !this.mrtData.containsKey("exit_info") || this.mrtData["exit_info"][0]["Exit"] == "" || this.mrtData["exit_info"][0]["Exit"].toString().toLowerCase().contains("mon");
          return Container(
              color: Colors.white,
              child: SingleChildScrollView(
                  child: Column(children: [
                //Image Section
                this.place!.photoReferences != null?
                getPhotoView():
                Image.asset("assets/img/placeholder.png", height: 200, 
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,),

                //Title
                Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(this.mrtData["Name Engish Malay"],
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold))),
                ),

                //Type
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("MRT/LRT Station",
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor))),
                ),

                //direction Button
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      //direction button
                      InkWell(
                        child: Icon(Icons.near_me,
                            size: 40, color: Colors.red[400]),
                        onTap: () => print("Tapped direction arrow"),
                        //TODO: navigate to directions page
                      )
                    ],
                  ),
                ),

                //Station Names
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Station",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold))),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Column(
                      children: [
                        //Station Names
                        Center(
                          //English
                          child: Text(this.mrtData["Name Engish Malay"],
                              style: TextStyle(
                                  fontSize: 20,
                                  height: 1.5,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Center(
                          //Chinese
                          child: Text(this.mrtData["Name Chinese"],
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.5,
                              )),
                        ),
                        Center(
                          child: Text(this.mrtData["Name Tamil"],
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.5,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                //station code block
                stationCodeBlock(this.mrtData["name codes"]),
                //Lines
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Lines",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold))),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                      List.generate(this.mrtData["name codes"].length, (index) {
                    String codePrefix =
                        getCodePrefix(this.mrtData["name codes"][index]);
                    //print(_mrt.getLineAbbvFromLineCode(codePrefix));
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MRTGraphicsGenerator(
                                lineAbbv:
                                    _mrt.getLineAbbvFromLineCode(codePrefix))),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 300,
                          height: 40,
                          child: Stack(children: [
                            Center(
                                child: Text(
                                    _mrt.getLineNameFromLineCode(codePrefix),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                            Container(
                                child: Row(children: [
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ]))
                          ]),
                          decoration: BoxDecoration(
                            color: _mrt.getColorFromLineAbbv(
                                _mrt.getLineAbbvFromLineCode(codePrefix)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                //Exits
                if (!NotShowExitInfo)
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Exit Information",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold))),
                  ),
                if (!NotShowExitInfo) exitSection(),
              ])));
        });
  }
}
