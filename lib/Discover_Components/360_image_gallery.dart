import 'package:flutter/material.dart';
import 'package:wikitude_flutter_app/DataSource/cloud_firestore.dart';
import 'package:wikitude_flutter_app/Models/search_result_model.dart';
import 'package:wikitude_flutter_app/SearchResults/detail_page_container.dart';

// ignore: must_be_immutable
class ImageGallery extends StatefulWidget {
  const ImageGallery({Key? key}) : super(key: key);

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("360 Experiences"),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Images"),
              Tab(text: "Videos"),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Image360GridView(type: "image"),
            Image360GridView(type: "video")
          ],
        ),
      ),
    );
  }
}

class Image360GridView extends StatefulWidget {
  String? type;
  Image360GridView({
    Key? key,
    required String this.type,
  }) : super(key: key);

  @override
  State<Image360GridView> createState() => _Image360GridViewState();
}

class _Image360GridViewState extends State<Image360GridView> {
  List<SearchResult> viewList = [];

  Future<List<SearchResult>> _fetchResult(type) async {
    if (type == "image") {
      List<Map<String, dynamic>>? imageData =
          await Image360Provider().ListAllImage360();
      if (imageData != null) {
        this.viewList.addAll(
            imageData.map((item) => SearchResult.from360ImageDataset(item)));
      }
    } else {
      List<Map<String, dynamic>>? videoStorageData =
          await Video360Provider().ListAllVideo360Storage();
      if (videoStorageData != null) {
        this.viewList.addAll(videoStorageData
            .map((item) => SearchResult.from360VideoStorage(item)));
      }
      List<Map<String, dynamic>>? videoYouTubeData =
          await Video360Provider().ListAllVideo360YouTube();
      if (videoYouTubeData != null) {
        this.viewList.addAll(videoYouTubeData
            .map((item) => SearchResult.from360VideoYouTube(item)));
      }
    }
    return this.viewList;
  }

  Widget textWithStroke({required String text, double fontSize: 12, double strokeWidth: 1, Color textColor: Colors.white, Color strokeColor: Colors.black}) {
        return Stack(
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = strokeColor,
              ),
            ),
            Text(text, style: TextStyle(fontSize: fontSize, color: textColor)),
          ],
        );
      }
  
  Widget _buildItem(SearchResult item) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailPageContainer(searchResult: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
          image: NetworkImage(item.imageSnapshot!),
        )),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: textWithStroke(text: item.title)),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _fetchResult(widget.type),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            print(snapshot.stackTrace);
            return Text("Has Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 8.0,
            children: List.generate(snapshot.data.length, (index) {
              SearchResult item = snapshot.data[index];
              return _buildItem(item);
            }),
          );
        });
  }
}
