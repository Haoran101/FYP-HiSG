
import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;

class WebScraperApp extends StatefulWidget {
  @override
  _WebScraperAppState createState() => _WebScraperAppState();
}

class _WebScraperAppState extends State<WebScraperApp> {
  // initialize WebScraper by passing base url of website
  final webScraper = WebScraper('https://www.visitsingapore.com');
  late Future<Text> content;

  // Response of getElement is always List<Map<String, dynamic>>

  Future<Text> fetchAlbum() async {
    final response = await http.get(Uri.parse('https://www.visitsingapore.com/editorials/shopping-on-a-budget-in-singapore/'));

     if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Text(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
  @override
  void initState() {
    super.initState();
    // Requesting to fetch before UI drawing starts
    content = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<Text>(
          future: content,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
        
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
        )
    );
}
}