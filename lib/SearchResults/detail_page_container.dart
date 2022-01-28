import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/SearchResults/experiences360.dart';
import 'package:wikitude_flutter_app/SearchResults/poi_details.dart';
import '../Models/search_result_model.dart';

class DetailPageContainer extends StatelessWidget {
  final searchResult;
  const DetailPageContainer({required this.searchResult});

  String subPageTitle(item) {
    switch (item.source) {
      case DataSource.Photo360:
        return item.title;

      default:
        return "Details";
    }
  }

  subpageContent(item) {
    print(item.source);
    switch (item.source) {
      //TODO: uncomment this when need to form google page
      // case DataSource.Google:
      //   return POISubPage(
      //     placeId: item.details["place_id"],
      //     placeName: item.title,
      //   );
      case DataSource.Photo360:
        return Experiences360Pages.container360Photo(item.details);

      case DataSource.Video360:
        return Experiences360Pages.display360VideoStorage(item.details);

      case DataSource.Video360YouTube:
        return Experiences360Pages.display360VideoYouTube(item.details);

      default:
        Text("default page");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subPageTitle(this.searchResult)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: subpageContent(this.searchResult),
          //Text("test"),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  child: Icon(
                    Icons.insert_invitation_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
