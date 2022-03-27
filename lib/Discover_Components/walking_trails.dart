import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';

class WalkingTrailsList extends StatefulWidget {
  const WalkingTrailsList({Key? key}) : super(key: key);

  @override
  State<WalkingTrailsList> createState() => _WalkingTrailsListState();
}

class _WalkingTrailsListState extends State<WalkingTrailsList> {
  List<TIHDetails> walkingTrailList = [];
  String nextToken = "";
  bool _isFetchingResult = true;

  fetchWalkingTrailList() async {
    List<Map<String, dynamic>>? result =
        await TIHDataProvider().getWalkingTrailList(nextToken: this.nextToken);
    List<TIHDetails> resultTIH = [];
    for (var item in result!) {
      if (item.containsKey("nextToken")) {
        this.nextToken = item["nextToken"];
      } else {
        resultTIH.add(TIHDetails.fromWalkingTrailJSON(item));
      }
    }
    this.walkingTrailList.addAll(resultTIH);
    this._isFetchingResult = false;
    return this.walkingTrailList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Walking Trails"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: TIHDataProvider().getWalkingTrailList(),
        builder:
            (context, AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
          if (snapshot.hasError) {
            return Text("Has error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          List<Widget> bodyList = List.generate(
              snapshot.data!.length,
              (index) =>
                  WalkingTrailCard(walkingTrailJSON: snapshot.data![index]));

          if (this.nextToken.length > 0) {
            bodyList.add(TextButton(
                onPressed: () async {
                  setState(() {
                    this._isFetchingResult = true;
                  });
                  await fetchWalkingTrailList();
                },
                child: this._isFetchingResult
                    ? CircularProgressIndicator()
                    : Text("Load More")));
          }

          return SingleChildScrollView(
            child: Column(children: bodyList),
          );
        },
      ),
    );
  }
}

class WalkingTrailCard extends StatefulWidget {
  final walkingTrailJSON;
  const WalkingTrailCard({Key? key, this.walkingTrailJSON}) : super(key: key);

  @override
  State<WalkingTrailCard> createState() => _WalkingTrailCardState();
}

class _WalkingTrailCardState extends State<WalkingTrailCard> {
  SearchResult? walkingTrailSearchResult;
  TIHDetails? walkingTrailTIHDetails;

  @override
  void initState() {
    walkingTrailSearchResult =
        SearchResult.fromTIH(this.widget.walkingTrailJSON);
    walkingTrailTIHDetails =
        TIHDetails.fromWalkingTrailJSON(walkingTrailSearchResult!.details!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPageContainer(
                    searchResult: walkingTrailSearchResult,
                  )),
        ),
        child: Container(
            width: 380,
            decoration: BoxDecoration(
                border: Border.all(width: 1.5, color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Column(
              children: [
                //image
                Center(
                  child: UI.tihImageBanner(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      tihDetails: walkingTrailTIHDetails),
                ),
                //Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      walkingTrailSearchResult!.title,
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
