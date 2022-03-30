import 'package:flutter/material.dart';
import 'package:hi_sg/DataSource/tih_data_provider.dart';
import 'package:hi_sg/Models/search_result_model.dart';
import 'package:hi_sg/Models/tih_model.dart';
import 'package:hi_sg/SearchResults/detail_page_container.dart';
import 'package:hi_sg/UI/CommonWidget.dart';

class WalkingTrailsList extends StatefulWidget {
  const WalkingTrailsList({Key? key}) : super(key: key);

  @override
  State<WalkingTrailsList> createState() => _WalkingTrailsListState();
}

class _WalkingTrailsListState extends State<WalkingTrailsList> {
  List<TIHDetails> walkingTrailList = [];
  String nextToken = "";
  bool _isFetchingResult = true;
  bool _isLastPageLoaded = false;

  Future<List<TIHDetails>> fetchWalkingTrailList() async {
    List<Map<String, dynamic>>? result =
        await TIHDataProvider().getWalkingTrailList(nextToken: this.nextToken);
    List<TIHDetails> resultTIH = [];
    for (var item in result!) {
      if (item.containsKey("nextToken")) {
        if (item["nextToken"] == ""){
          _isLastPageLoaded = true;
        }
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
        future: fetchWalkingTrailList(),
        builder:
            (context, AsyncSnapshot<List<TIHDetails>> snapshot) {
          if (snapshot.hasError) {
            return UI.errorMessage();
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
                  WalkingTrailCard(walkingTrailDetails: snapshot.data![index]));

          if (this.nextToken.length > 0 && !_isLastPageLoaded) {
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
  
  WalkingTrailCard({Key? key, required this.walkingTrailDetails}) : super(key: key);
  final TIHDetails walkingTrailDetails;

  @override
  State<WalkingTrailCard> createState() => _WalkingTrailCardState();
}

class _WalkingTrailCardState extends State<WalkingTrailCard> {
  SearchResult? walkingTrailSearchResult;

  @override
  void initState() {
    walkingTrailSearchResult = SearchResult.fromTIH(widget.walkingTrailDetails.rawdata!);
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
                      tihDetails: widget.walkingTrailDetails),
                ),
                //Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      walkingTrailSearchResult!.title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
