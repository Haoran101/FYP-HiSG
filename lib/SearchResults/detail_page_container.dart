import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:hi_sg/SearchResults/event_details.dart';
import 'package:hi_sg/SearchResults/experiences360.dart';
import 'package:hi_sg/SearchResults/mrt_details.dart';
import 'package:hi_sg/SearchResults/poi_details.dart';
import 'package:hi_sg/SearchResults/precincts_details.dart';
import 'package:hi_sg/SearchResults/tour_details.dart';
import 'package:hi_sg/SearchResults/walking_trail_details.dart';
import 'package:hi_sg/UI/CommonWidget.dart';
import 'package:hi_sg/UI/activity_icon_provider.dart';
import 'package:hi_sg/User/UserService.dart';
import '../Models/search_result_model.dart';

// ignore: must_be_immutable
class DetailPageContainer extends StatefulWidget {
  final searchResult;
  var modelPreloaded;
  DetailPageContainer({required this.searchResult, this.modelPreloaded});

  @override
  State<DetailPageContainer> createState() => _DetailPageContainerState();
}

class _DetailPageContainerState extends State<DetailPageContainer> {
  final UserService _user = UserService();
  bool isFavorated = false;
  bool isInPlan = false;
  final List notBeAbleToPlan = [DataSource.Photo360, DataSource.Video360, DataSource.Video360YouTube];

  initState() {
    super.initState();
    //is favorite?
    _user
        .checkItemFavorited(this.widget.searchResult)
        .then((value) {
          setState(() {
            this.isFavorated = value;
          });
        });
    //is in plan?
    _user
        .checkItemInPlan(this.widget.searchResult)
        .then((value) {
          setState(() {
            this.isInPlan = value;
          });
        });
  }

  _toggleFavorite() {
    if (_user.getCurrentUser == null) {
      //cannot do without login
      UI.showCustomSnackBarMessage(context, "Not logged in. Cannot add to favorite.");
      return;
    }

    //interact with database
    if (isFavorated) {
      //delete from favorite
      try {
        _user.deleteFromFavorite(this.widget.searchResult);
        UI.showCustomSnackBarMessage(context, "Deleted from Favourites.");
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
        UI.showCustomSnackBarMessage(context, "Failed to delete from Faviorite.");
      }
    } else {
      //add to favorite
      try {
        _user.addToFavorite(this.widget.searchResult);
        UI.showCustomSnackBarMessage(context, "Added to Favourites.");
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
        UI.showCustomSnackBarMessage(context, "Failed to add to Favourite.");
      }
    }
    setState(() {
      //change current page state
      isFavorated = !isFavorated;
    });
  }

  _toggleInPlan() {
    print(isInPlan);

    if (_user.getCurrentUser == null) {
      //cannot do without login
      UI.showCustomSnackBarMessage(context, "Not logged in. Cannot add to plan.");
      return;
    }

    if (isInPlan) {
      //Notify item is already in plan
      UI.showCustomSnackBarMessage(context, "Already in plan. Please edit in 'Plan' menu.");
    } else {
      //Add to plan list archieve
      try{
        _user.addToPlanArchieve(this.widget.searchResult);
        UI.showCustomSnackBarMessage(context, "Added to plan archieve.");
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
        UI.showCustomSnackBarMessage(context, "Failed to add to plan.");
      }
    }

    setState(() {
      isInPlan = true;
    });
  }

  String subPageTitle(item) {
    switch (item.source) {
      case DataSource.Photo360:
        return item.title;

      default:
        return "Details";
    }
  }

  subpageContent(SearchResult item) {

    List<String> selectedDatasetTIH =  ["event", "tour", "walking_trail", "precincts"];
    
    if (item.source == DataSource.TIH && StringUtils.isNotNullOrEmpty(this.widget.modelPreloaded) && !selectedDatasetTIH.contains(item.details!["dataset"])){
      print(this.widget.modelPreloaded);
      return POISubPage(placeId: this.widget.modelPreloaded, category: item.subtitle, isCid: true,);
    }

    print(item.source);
    switch (item.source) {
      case DataSource.Google:
        return POISubPage(
          placeId: item.details?["place_id"],
          category: item.subtitle,
      );
      case DataSource.Photo360:
        return Experiences360Pages.container360Photo(item.details);

      case DataSource.Video360:
        return Experiences360Pages.display360VideoStorage(item.details);

      case DataSource.Video360YouTube:
        return Experiences360Pages.display360VideoYouTube(item.details);

      case DataSource.TIH:

        switch(item.subtitle){
          case "EVENT":
            return EventDetailsSubpage(details: item.details);
          case "TOUR":
            return TourDetailsSubpage(details: item.details);
          case "PRECINCTS":
            return PrecinctDetailsSubpage(details: item.details);
          case "WALKING TRAIL":
            return WalkingTrailDetailsSubpage(details: item.details);
          default:
            return Container(child: Text(item.toJSON().toString()));
        }

        case DataSource.MRT:
          return MRTStationPage(mrtData: item.details!);

      default:
        return Container(child: Text(item.toJSON().toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("IsFavorited: " + isFavorated.toString());
    print("IsInPlan: " + isInPlan.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(subPageTitle(this.widget.searchResult)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: subpageContent(this.widget.searchResult),
      //Text("test"),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Spacer(),
              //Favorite icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                    onTap: _toggleFavorite,
                    child: isFavorated
                        ? IconProvider().FAVORITED_ICON
                        : IconProvider().NOT_FAVORITED_ICON),
              ),
              notBeAbleToPlan.contains(this.widget.searchResult.source) ?
              SizedBox.shrink():
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: _toggleInPlan,
                  child: isInPlan
                      ? Icon(Icons.event_available_outlined,
                          color: Colors.amber, size: 30)
                      : Icon(
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
