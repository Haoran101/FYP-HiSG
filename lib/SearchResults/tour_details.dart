import 'package:basic_utils/basic_utils.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';

class TourDetailsSubpage extends StatefulWidget {
  final details;
  TourDetailsSubpage({required this.details});

  @override
  State<TourDetailsSubpage> createState() => _TourDetailsSubpageState();
}

class _TourDetailsSubpageState extends State<TourDetailsSubpage> {
  late TIHDetails tour;

  @override
  void initState() {
    this.tour = TIHDetails.fromTourJSON(this.widget.details);
    super.initState();
  }

  Widget getBackgroundIcon() {
    return Align(
      alignment: Alignment.topRight,
      child: Opacity(
          opacity: 0.3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              tour.icon!.icon,
              size: 100,
              color: Colors.grey,
            ),
          )),
    );
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

  String _dateformatter(dt) {
    if (dt != null) {
      return formatDate(dt, [dd, " ", M, " ", yyyy]);
    } else {
      return "~";
    }
  }

  String _getFriendlyText(bool? friendly) {
    if (friendly == null) {
      return "No";
    } else {
      return friendly ? "Yes" : "No";
    }
  }

  Widget getDirectionArrow() {
    if (tour.latitude != 0) {
      return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          child: Icon(Icons.near_me, size: 40, color: Colors.red[400]),
          onTap: () =>
              print(tour.latitude.toString() + "," + tour.longitude.toString()),
          //TODO: navigate to directions page
        ),
      );
    } else
      return SizedBox(
        height: 0,
      );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(tour.rawdata);
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          //image
          UI.tihImageBanner(
              width: MediaQuery.of(context).size.width,
              height: 200,
              tihDetails: tour),

          Stack(
            children: [
              //background icon
              getBackgroundIcon(),
              Column(
                children: [
                  //Title
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 10),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(tour.name!,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold))),
                  ),

                  //tour and tour type
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                text: "TOUR",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).primaryColor),
                                children: [
                                  WidgetSpan(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        padding:
                                            EdgeInsets.fromLTRB(6, 2, 6, 2),
                                        margin: EdgeInsets.only(left: 10),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.0),
                                          child: Text(tour.type!,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                        )),
                                  )
                                ]),
                          )),
                      Spacer(),
                      //direction arrow
                      getDirectionArrow(),
                    ]),
                  ),

                  SizedBox(height: 20),
                  //Text(tour.rawdata.toString()),

                  ///Info section
                  ///startpoint
                  StringUtils.isNotNullOrEmpty(tour.tourStartPoint)
                      ? ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text("Starts from: " + tour.tourStartPoint!))
                      : SizedBox(
                          height: 0,
                        ),

                  //endpoint
                  StringUtils.isNotNullOrEmpty(tour.tourEndPoint)
                      ? ListTile(
                          leading: SizedBox(),
                          title: Text("Ends at: " + tour.tourEndPoint!))
                      : SizedBox(
                          height: 0,
                        ),

                  //duration
                  StringUtils.isNotNullOrEmpty(tour.duration)
                      ? ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text("Duration: " + tour.duration!))
                      : SizedBox(
                          height: 0,
                        ),

                  ///price
                  tour.price != null && tour.price != ""
                      ? ListTile(
                          leading: Icon(
                            Icons.attach_money_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(tour.price!))
                      : SizedBox.shrink(),
                  //website
                  tour.website != null && tour.website != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.language_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(tour.website!),
                          ),
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: tour.website));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Website Url copied to clipboard.")));
                          },
                          onTap: () => launch("${tour.website}"),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  //phone number
                  tour.contactNumber != null && tour.contactNumber != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(tour.contactNumber!),
                          ),
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: tour.contactNumber));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Phone number copied to clipboard.")));
                          },
                          onTap: () => launch("tel://${tour.contactNumber}"),
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///email
                  tour.email != null && tour.email != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(tour.email!),
                          ),
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: tour.email));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Email address copied to clipboard.")));
                          },
                          onTap: () => launch("mailto:${tour.email}"),
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///nearest mrt station
                  tour.nearstMRTStation != null && tour.nearstMRTStation != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.train_sharp,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text("Nearest MRT Station: " +
                                tour.nearstMRTStation!),
                          ),
                          //TODO: link to mrt page
                          onTap: null,
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///description
                  ///Description Title
                  tour.description != null && tour.description != ""
                      ? Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Description",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold))),
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///Description Content
                  tour.description != null && tour.description != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: tour.description!.contains(">")
                              ? parseHTML(tour.description)
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    tour.description!,
                                    style: TextStyle(fontSize: 16, height: 1.5),
                                  ),
                                ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20,
                  ),

                  //Notes
                  //notes title
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Notes",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold))),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        //Notes
                        (StringUtils.isNotNullOrEmpty(tour.notes))
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(tour.notes!,
                                    style:
                                        TextStyle(fontSize: 16.0, height: 2)))
                            : SizedBox.shrink(),

                        ///Startdate - EndDate
                        (tour.startDate != null || tour.endDate != null)
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Available period: " +
                                        _dateformatter(tour.startDate) +
                                        " ~ " +
                                        _dateformatter(tour.endDate),
                                    style:
                                        TextStyle(fontSize: 16.0, height: 2)))
                            : SizedBox.shrink(),

                        //Wheelchair Friendly
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Wheelchair Friendly: " +
                                    _getFriendlyText(tour.wheelChairFriendly),
                                style: TextStyle(fontSize: 16.0, height: 2))),

                        //children friendly
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Child Friendly: " +
                                    _getFriendlyText(tour.childFriendly),
                                style: TextStyle(fontSize: 16.0, height: 2))),

                        //Minimum Age
                        (StringUtils.isNotNullOrEmpty(tour.minimumAge))
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Minimum Age: " + tour.minimumAge!,
                                    style:
                                        TextStyle(fontSize: 16.0, height: 2)))
                            : SizedBox.shrink(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),

                  ///body
                  ///body Title
                  tour.body != null &&
                          tour.body != tour.description &&
                          tour.body != ""
                      ? Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Details",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold))),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  //html content
                  tour.body != null &&
                          tour.body != tour.description &&
                          tour.body != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: tour.body!.contains(">")
                              ? parseHTML(tour.body)
                              : Text(
                                  tour.body!,
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                ),
                        )
                      : SizedBox.shrink(),
                ],
              )
            ],
          )
        ]),
      ),
    );
  }
}
