import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wikitude_flutter_app/Models/tih_model.dart';
import 'package:wikitude_flutter_app/UI/CommonWidget.dart';

class EventDetailsSubpage extends StatefulWidget {
  final details;
  EventDetailsSubpage({required this.details});

  @override
  State<EventDetailsSubpage> createState() => _EventDetailsSubpageState();
}

class _EventDetailsSubpageState extends State<EventDetailsSubpage> {
  late TIHDetails event;

  @override
  void initState() {
    this.event = TIHDetails.fromEventJSON(this.widget.details);
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
              event.icon!.icon,
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

  Widget getDirectionArrow() {
    if (event.latitude != 0) {
      return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          child: Icon(Icons.near_me, size: 40, color: Colors.red[400]),
          onTap: () => print(
              event.latitude.toString() + "," + event.longitude.toString()),
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
    print(event.rawdata!["location"]);
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          //image
          UI.tihImageBanner(
              width: MediaQuery.of(context).size.width,
              height: 200,
              tihDetails: event),

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
                        child: Text(event.name!,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold))),
                  ),

                  //event and event type
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                text: "EVENT",
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
                                          child: Text(event.type!,
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

                  ///Info section
                  ///event organiser
                  event.organiser != null && event.organiser != ""
                      ? ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(event.organiser!))
                      : SizedBox(
                          height: 0,
                        ),

                  ///Startdate - EndDate
                  (event.startDate != null || event.endDate != null)
                      ? ListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(_dateformatter(event.startDate) +
                              " ~ " +
                              _dateformatter(event.endDate)))
                      : SizedBox(
                          height: 0,
                        ),

                  ///price
                  event.price != null && event.price != ""
                      ? ListTile(
                          leading: Icon(
                            Icons.attach_money_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(event.price!))
                      : SizedBox.shrink(),
                  //website
                  event.website != null && event.website != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.language_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(event.website!),
                          ),
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: event.website));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Website Url copied to clipboard.")));
                          },
                          onTap: () => launch("${event.website}"),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  //phone number
                  event.contactNumber != null && event.contactNumber != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(event.contactNumber!),
                          ),
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: event.contactNumber));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Phone number copied to clipboard.")));
                          },
                          onTap: () => launch("tel://${event.contactNumber}"),
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///email
                  event.email != null && event.email != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(event.email!),
                          ),
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(text: event.email));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Email address copied to clipboard.")));
                          },
                          onTap: () => launch("mailto:${event.email}"),
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///nearest mrt station
                  event.nearstMRTStation != null && event.nearstMRTStation != ""
                      ? InkWell(
                          child: ListTile(
                            leading: Icon(
                              Icons.train_sharp,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text("Nearest MRT Station: " +
                                event.nearstMRTStation!),
                          ),
                          //TODO: link to mrt page
                          onTap: null,
                        )
                      : SizedBox(
                          height: 0,
                        ),

                  ///description
                  ///Description Title
                  event.description != null && event.description != ""
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
                  event.description != null && event.description != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: event.description!.contains(">")
                              ? parseHTML(event.description)
                              : Text(
                                  event.description!,
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 20,
                  ),

                  ///body
                  ///body Title
                  event.body != null &&
                          event.body != event.description &&
                          event.body != ""
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
                  event.body != null &&
                          event.body != event.description &&
                          event.body != ""
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: event.body!.contains(">")
                              ? parseHTML(event.body)
                              : Text(
                                  event.body!,
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
