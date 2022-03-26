import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/tih_data_provider.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';

class PrecinctPage extends StatelessWidget {
  const PrecinctPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discover Precincts"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: TIHDataProvider().getPrecinctList(),
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

          return SingleChildScrollView(
            child: Column(
              children: List.generate(snapshot.data!.length,
                  (index) => PrecinctCard(precinctJSON: snapshot.data![index])),
            ),
          );
        },
      ),
    );
  }
}

class PrecinctCard extends StatefulWidget {
  final precinctJSON;
  const PrecinctCard({Key? key, this.precinctJSON}) : super(key: key);

  @override
  State<PrecinctCard> createState() => _PrecinctCardState();
}

class _PrecinctCardState extends State<PrecinctCard> {
  SearchResult? precinctSearchResult;
  TIHDetails? precinctTIHDetails;

  @override
  void initState() {
    precinctSearchResult = SearchResult.fromTIH(this.widget.precinctJSON);
    precinctTIHDetails =
        TIHDetails.fromPrecinctsJSON(precinctSearchResult!.details!);
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
                                    builder: (context) =>
                                        DetailPageContainer(searchResult: precinctSearchResult,)),
                              ),
        child: Container(
            width: 380,
            decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            child: Column(
              children: [
                //image
                Center(
                  child: UI.tihImageBanner(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      tihDetails: precinctTIHDetails),
                ),
                //Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(precinctSearchResult!.title, style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
