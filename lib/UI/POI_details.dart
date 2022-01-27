import 'package:flutter/material.dart';
import 'package:video_player_360/video_player_360.dart';
import 'package:wikitude_flutter_app/DataSource/webview.dart';

import '../MicroServices/360-views.dart';

class POIDetailsPage extends StatefulWidget {
  final String placeId;
  const POIDetailsPage({required this.placeId});

  @override
  _POIDetailsPageState createState() => _POIDetailsPageState();
}

class _POIDetailsPageState extends State<POIDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: Text("Play video 1"),
            onPressed: () async {
              var videoUrl = "https://firebasestorage.googleapis.com/v0/b/hisg-327915.appspot.com/o/360_videos%2Ftest.html?alt=media&token=06a3534e-51fb-49f2-bd8e-0e2b517329ad";
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MyWebView(title: "test", selectedUrl: videoUrl)),
              );
            },
          ),
        ),
        ElevatedButton(
          child: Text("Play video 2"),
          onPressed: () async {
            var title = "title";
            var url = "https://firebasestorage.googleapis.com/v0/b/hisg-327915.appspot.com/o/360_videos%2FEsplanade%20Concert%20Hall.mp4?alt=media&token=eba323be-75fd-44ef-bf8b-950224fae46e";
            await Image360.playVideo360(url);
          },
        ),
        ElevatedButton(
          child: Text("Panorama Test 2"),
          onPressed: () async {
            var url = "https://www.360cities.net/image/360-panorama-view-of-raffles-place-singapore-the-central-business-district-downtown-area/vr";
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Image360(title: "test webview", url: url)),
              );
          },
        ),
      ]),
    );
  }
}
