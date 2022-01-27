// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:video_player_360/video_player_360.dart';
import 'package:wikitude_flutter_app/DataSource/webview.dart';

class Image360 extends StatelessWidget {
  final title;
  final url;
  final bool useWebView = true;
  const Image360({this.title, this.url});

  static playVideo360(url) async {
  await VideoPlayer360.playVideoURL(url);
}

  @override
  Widget build(BuildContext context) {
    return 
    this.useWebView
    ? MyWebView(title: this.title, selectedUrl: url)
    : Scaffold(
      appBar: (AppBar(
        title: Text(this.title),
        backgroundColor: Color.fromRGBO(255, 0, 117, 1),
      )),
      body: Container(child: Panorama(
          child: Image.network(this.url),
        ),
      ),
    );
  }

}
