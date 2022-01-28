import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:panorama/panorama.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:video_player_360/video_player_360.dart';
import 'package:wikitude_flutter_app/MicroServices/webview.dart';

import 'package:flutter/material.dart';

var _pageElementPadding = EdgeInsets.all(20.0);

class Experiences360Pages {
  static container360Photo(jsonDetails) {
    var url = jsonDetails["view_url"];
    var title = jsonDetails["title"];
    return Image360(title: title, url: url);
  }

  static display360VideoStorage(jsonDetails) {
    return Video360Storage(data: jsonDetails);
  }

  static display360VideoYouTube(jsonDetails) {
    final title = jsonDetails["snippet"]["title"];
    final videoId = jsonDetails["contentDetails"]["videoId"];
    return _Video360Youtube(
      title: title,
      videoId: videoId,
    );
  }
}

class Image360 extends StatelessWidget {
  final title;
  final url;
  final bool useWebView = true;
  const Image360({this.title, this.url});

  @override
  Widget build(BuildContext context) {
    return this.useWebView
        ? MyWebView(title: this.title, selectedUrl: url)
        : Container(
            child: Panorama(
              child: Image.network(this.url),
            ),
          );
  }
}

class Video360Storage extends StatefulWidget {
  final data;
  const Video360Storage({required this.data});

  @override
  State<Video360Storage> createState() => _Video360StorageState();
}

class _Video360StorageState extends State<Video360Storage> {
  @override
  Widget build(BuildContext context) {
    print(this.widget.data);
    return Container(
        child: Column(
      children: [
        SizedBox(
          height: 30,
        ),
        //Title
        Padding(
          padding: _pageElementPadding,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(this.widget.data["name"],
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
        ),
        Padding(
          padding: _pageElementPadding,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(this.widget.data["description"],
                  style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      height: 1.5))),
        ),
        Padding(
          padding: _pageElementPadding,
          child: InkWell(
            child: Stack(
              children: [
                //image container
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: new DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.7), BlendMode.dstATop),
                    image: new NetworkImage(
                      this.widget.data["preview_url"],
                    ),
                  )),
                ),
                Center(
                  child: Container(
                    height: 400,
                    child: Icon(
                      Icons.play_circle_outline_outlined,
                      size: 100,
                      color: Colors.white60,
                    ),
                  ),
                )
              ],
            ),
            onTap: () async =>
                await VideoPlayer360.playVideoURL(this.widget.data["url"]),
          ),
        )
      ],
    ));
  }
}

class _Video360Youtube extends StatefulWidget {
  final title;
  final videoId;
  const _Video360Youtube({required this.title, required this.videoId});

  @override
  __Video360YoutubeState createState() => __Video360YoutubeState();
}

class __Video360YoutubeState extends State<_Video360Youtube> {
  var video;
  var url;
  bool landscape = false;
  var htmlString;
  var htmlStringLandscape;

  @override
  void initState() {
    super.initState();
    video = this.widget.videoId;
    htmlString =
        "<iframe width='950' height='534' src='https://www.youtube.com/embed/$video?rel=0&fs=0&loop=1' title='YouTube video player' frameborder='0' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope' allowfullscreen></iframe>";
    url = 'https://www.youtube.com/watch?v=$video';
  }

  launchYouTube() async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          //Title
          Padding(
            padding: _pageElementPadding,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(this.widget.title,
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          ),
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: _pageElementPadding,
            child: SizedBox(
              height: 250,
              child: MyWebView(
                title: "test webview",
                htmlString: htmlString,
              ),
            ),
          ),
          SizedBox(
            child: Row(
              children: [
                Spacer(),
                InkWell(
                  onTap: launchYouTube,
                  child: Row(children: [
                    Icon(
                      Icons.play_circle_outlined,
                      color: Colors.red,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Open in YouTube",
                      style: TextStyle(fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),),
                    ),
                  ]),
                ),
                Spacer(),
              ],
            ),
          )
        ]),
      );
    }
}
