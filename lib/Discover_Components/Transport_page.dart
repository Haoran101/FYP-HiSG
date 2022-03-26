import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';
import 'package:wikitude_flutter_app/UI/MRT_line_page.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({Key? key}) : super(key: key);

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mass Rapid Transit (MRT)"),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Line"),
              Tab(text: "Station"),
              Tab(text: "Map"),
              Tab(text: "About"),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            LineListPage(),
            StationListPage(),
            MRTMapPage(),
            AboutMRTPage()
          ],
        ),
      ),
    );
  }
}

class MRTMapPage extends StatelessWidget {
  const MRTMapPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          "https://www.lta.gov.sg/content/dam/ltagov/getting_around/public_transport/rail_network/image/tel2_sm-20-03-en-exp.png"
        ),
        loadingBuilder: (context, event) => CircularProgressIndicator(),
      )
    );
  }
}

class _StationAZItem extends ISuspensionBean {
  final String title;
  final dynamic details;
  final String tag;

  _StationAZItem(
      {required this.title, required this.details, required this.tag});

  @override
  String getSuspensionTag() => tag;
}

class StationListPage extends StatefulWidget {
  const StationListPage({Key? key}) : super(key: key);

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  List<_StationAZItem> _stationList = [];

  @override
  void initState() {
    super.initState();
  }

  List<_StationAZItem> initList(List<Map<String, dynamic>> stationList) {
    List<_StationAZItem> formatted = stationList
        .map((item) => _StationAZItem(
            title: item["Name Engish Malay"],
            details: item,
            tag: item["Name Engish Malay"][0].toString().toUpperCase()))
        .toList();

    SuspensionUtil.sortListBySuspensionTag(formatted);
    SuspensionUtil.setShowSuspensionStatus(formatted);
    _stationList = formatted;

    return formatted;
  }

  _buildItem(_StationAZItem item) {
    final tag = item.getSuspensionTag();
    final offStage = !item.isShowSuspension;

    return Column(
      children: [
        Offstage(offstage: offStage, child: _buildHeader(tag)),
        ListTile(
          title: Text(item.title),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailPageContainer(
                        searchResult: SearchResult.fromMRTdataset(item.details))),
              )),]
    );
  }

  _buildHeader(String tag) {
    return Container(
      color: Colors.grey[200],
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            tag,
            softWrap: false,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MRTProvider().listAllMRTStation(),
        builder:
            (context, AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return AzListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              indexBarHeight: MediaQuery.of(context).size.height,
              indexBarItemHeight: MediaQuery.of(context).size.height / 35,
              indexBarMargin: EdgeInsets.only(right: 20),
              indexBarOptions: IndexBarOptions(
                  needRebuild: true,
                  selectTextStyle: TextStyle(color: Colors.white),
                  selectItemDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor)),
              data: initList(snapshot.data!),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = _stationList[index];
                return _buildItem(item);
              });
        });
  }
}

class LineListPage extends StatelessWidget {
  final List<String> lineAbbvList = [
    "EWL",
    "NEL",
    "CCL",
    "DTL",
    "NSL",
    "TEL",
    "PG",
    "BP",
    "SK"
  ];
  final _mrt = MRTProvider();
  LineListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(lineAbbvList.length, (index) {
            String lineAbbv = lineAbbvList[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MRTGraphicsGenerator(lineAbbv: lineAbbv)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: 300,
                  height: 40,
                  child: Stack(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(_mrt.getLineNameFromAbbv(lineAbbv),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
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
                    color: _mrt.getColorFromLineAbbv(lineAbbv),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AboutMRTPage extends StatelessWidget {
  const AboutMRTPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: Image.asset(
          "assets/img/explore/Logo_MRT.png",
          height: 60,
        ),
      ),
      Container(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Text(
          """
        The Mass Rapid Transit system, known by the initialism MRT in common parlance, is a rapid transit system in Singapore and the island country's principal mode of railway transportation. The system commenced operations in November 1987 after two decades of planning with an initial 6 km (3.7 mi) stretch consisting of 5 stations. The network has since grown to span the length and breadth of the city-state's main island (with the exception of the forested core and the rural northwestern region) in accordance with Singapore's aim of developing a comprehensive rail network as the backbone of the country's public transportation system, averaging a daily ridership of 3.4 million in 2019.
        """,
          softWrap: true,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      )),
    ]);
  }
}
