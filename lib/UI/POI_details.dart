import 'package:flutter/material.dart';
import 'package:video_player_360/video_player_360.dart';

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
      child: ElevatedButton(
        child: Text("Play video"),
        onPressed: () async{
          var videoUrl = "https://singaporetourism.brightcovecdn.com/media/v1/pmp4/static/clear/6055873631001/a198af41-8a04-4a01-8396-7dce1abc5c4b/14bb8fa7-bf00-42da-a4a4-28f35ea24f8b/main.mp4?fastly_token=NjFlYTk1NDRfMjBmM2FiMmQxZTIwYmY2ZTdlZDc0OTQ2ZWNlYTc3MjZiNzNhNmU4N2E4MWY2ZDg4YzM4MDZhZGM2NzBkNTMxY18vL3NpbmdhcG9yZXRvdXJpc20uYnJpZ2h0Y292ZWNkbi5jb20vbWVkaWEvdjEvcG1wNC9zdGF0aWMvY2xlYXIvNjA1NTg3MzYzMTAwMS9hMTk4YWY0MS04YTA0LTRhMDEtODM5Ni03ZGNlMWFiYzVjNGIvMTRiYjhmYTctYmYwMC00MmRhLWE0YTQtMjhmMzVlYTI0ZjhiL21haW4ubXA0";
          await VideoPlayer360.playVideoURL(videoUrl);
        },
      ),
    );
  }
}