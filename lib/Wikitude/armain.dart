import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'DestinationPage.dart';
import 'arview.dart';
import 'category.dart';
import 'custom_expansion_tile.dart';
import 'sample.dart';

import 'package:augmented_reality_plugin_wikitude/wikitude_plugin.dart';
import 'package:augmented_reality_plugin_wikitude/wikitude_response.dart';

Future<String> _loadSamplesJson() async {
  return await rootBundle.loadString('samples/samples.json');
}

Future<List<Category>> _loadSamples() async {
  String samplesJson = await _loadSamplesJson();
  List<dynamic> categoriesFromJson = json.decode(samplesJson);
  List<Category> categories = [];

  for (int i = 0; i < categoriesFromJson.length; i++) {
    categories.add(new Category.fromJson(categoriesFromJson[i]));
  }
  return categories;
}

class MainMenu extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Augmented Reality'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 80, left: 20, right: 20, bottom: 30),
              child: Text(
                "Meet Singapore, now with AR",
                style: TextStyle(fontSize: 22, color: Colors.black54),
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 10),
                child: Image.asset("assets/img/AR.png")),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder(
                  future: _loadSamples(),
                  builder: (context, AsyncSnapshot<List<Category>> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: CategoryExpansionTile(
                          categories: snapshot.data!,
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }

}

class CategoryExpansionTile extends StatefulWidget {
  final List<Category> categories;
  CategoryExpansionTile({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  CategoryExpansionTileState createState() => new CategoryExpansionTileState();
}

class CategoryExpansionTileState extends State<CategoryExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            return CustomExpansionTile(
              key: PageStorageKey("$index"),
              headerBackgroundColor: Colors.white,
              headerBackgroundColorAccent: Colors.white,
              headerContentPadding: EdgeInsets.fromLTRB(15, 2, 15, 2),
              borderHeight: 0.6,
              borderColor: Colors.white,
              iconColor: Colors.white,
              children: createSamplesTileList(widget.categories[index].samples),
            );
          }),
    );
  }

  List<Widget> createSamplesTileList(List<Sample> samples) {
    List<Widget> tileList = [];

    for (int i = 0; i < samples.length; i++) {
      Sample sample = samples[i];
      List<String> features = [];
      for (int j = 0; j < sample.requiredFeatures.length; j++) {
        features.add(sample.requiredFeatures[j]);
      }

      tileList.add(FutureBuilder(
          future: _isDeviceSupporting(features),
          builder: (context, AsyncSnapshot<WikitudeResponse> snapshot) {
            if (snapshot.hasData) {
              return Container(
                  margin: EdgeInsets.symmetric(vertical: 15.0),
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).primaryColor),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white)),
                          child: Text(
                            sample.name,
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            if (snapshot.data!.success)
                            {
                              sample.name == "AR Walking Navigation"?
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DestinationPage())):
                              _pushArView(sample);
                            }
                            else {
                              _showDialog("Device missing features",
                                  snapshot.data!.message);
                            }
                          },
                        ),
                      )));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }));
    }

    return tileList;
  }

  Future<WikitudeResponse> _isDeviceSupporting(List<String> features) async {
    return await WikitudePlugin.isDeviceSupporting(features);
  }

  Future<WikitudeResponse> _requestARPermissions(List<String> features) async {
    return await WikitudePlugin.requestARPermissions(features);
  }

  Future<void> _pushArView(Sample sample) async {
    WikitudeResponse permissionsResponse =
        await _requestARPermissions(sample.requiredFeatures);
    if (permissionsResponse.success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArViewWidget(sample: sample)),
      );
    } else {
      _showPermissionError(permissionsResponse.message);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showPermissionError(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Permissions required"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Open settings'),
                onPressed: () {
                  Navigator.of(context).pop();
                  WikitudePlugin.openAppSettings();
                },
              )
            ],
          );
        });
  }
}