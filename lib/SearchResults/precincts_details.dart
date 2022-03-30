import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hi_sg/DataSource/tih_data_provider.dart';
import 'package:hi_sg/Models/tih_model.dart';
import 'package:hi_sg/SearchResults/search.dart';
import 'package:hi_sg/UI/CommonWidget.dart';
import 'package:hi_sg/UI/activity_icon_provider.dart';

class PrecinctDetailsSubpage extends StatefulWidget {
  final details;
  PrecinctDetailsSubpage({required this.details});

  @override
  State<PrecinctDetailsSubpage> createState() => _PrecinctDetailsSubpageState();
}

class _PrecinctDetailsSubpageState extends State<PrecinctDetailsSubpage> {
  late TIHDetails precinct;
  Map<String, Map<String, dynamic>> precinctList = Map();
  int maximumPages = 10;
  int loadedPages = 0;
  bool _isFetchingResult = true;

  @override
  void initState() {
    this.precinct = TIHDetails.fromPrecinctsJSON(this.widget.details);
    super.initState();
  }

  Future fetchPrecinctList(int pageNumber) async {
    print("fetching precinct list items..., page $pageNumber");
    if (pageNumber > this.loadedPages) {
      var listFetched = (await TIHDataProvider()
          .getPrecinctItemsByUUID(this.precinct.uuid!, pageNumber))!;

      setState(() {
        for (final mapItem in listFetched) {
          var key = mapItem["searchResult"].resultId;
          if (!this.precinctList.containsKey(key)) {
            this.precinctList[key] = mapItem;
          }
        }
        this.maximumPages = listFetched[0]["maximumPages"];
        this.loadedPages += 1;
        this._isFetchingResult = false;
      });
    }
    return;
  }

  Widget parseHTML(String? data) {
    return Html(
      data: "<body>" +
          data!.replaceAll("<br>", "<br><br>").replaceAll("</br>", "<br><br>") +
          "</body>",
      onLinkTap: (url, context, attributes, element) {
        launch(url!);
      },
      style: {
        "body": Style(
          fontSize: FontSize(16),
          lineHeight: LineHeight(1.5),
          whiteSpace: WhiteSpace.NORMAL,
        ),
      },
    );
  }

  formatPrecinctListTiles() {
    return ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: 
            List.generate(this.precinctList.length, (index) {
                var resultItem =
                    List.from(this.precinctList.values)[index]["searchResult"];
                resultItem.icon = IconProvider()
                    .mapTIHIcon(resultItem.subtitle.toString().toLowerCase());
                return SearchResultCard(
                  item: resultItem,
                  preloadedPage: List.from(this.precinctList.values)[index]
                      ["resultModel"],
                );
              })
            );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          Column(children: [
            //image
            UI.tihImageBanner(
                width: MediaQuery.of(context).size.width,
                height: 200,
                tihDetails: precinct),

            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(precinct.name!,
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold))),
            ),

            ///Description Content
            precinct.description != null && precinct.description != ""
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: precinct.description!.contains(">")
                        ? parseHTML(precinct.description)
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              precinct.description!,
                              style: TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                  )
                : SizedBox.shrink(),

            SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future: fetchPrecinctList(1),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("Error occurs fetching precinct data");
                    return UI.errorMessage();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return formatPrecinctListTiles();
                }),

            loadedPages < this.maximumPages && loadedPages > 0
                ? TextButton(
                    onPressed: () async {
                      setState(() {
                        this._isFetchingResult = true;
                      });
                      await fetchPrecinctList(this.loadedPages + 1);
                    },
                    child: this._isFetchingResult
                        ? CircularProgressIndicator()
                        : Text("Load More"))
                : SizedBox.shrink(),
          ]),
        ]),
      ),
    );
  }
}
