
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class Editorial extends StatefulWidget {
  const Editorial({ Key? key }) : super(key: key);

  @override
  _EditorialState createState() => _EditorialState();
}

class _EditorialState extends State<Editorial> {
  Future<String> getresponse() async {
  // This example uses the Google Books API to search for books about http.
  // https://developers.google.com/books/docs/overview
  var url =
      Uri.https('www.visitsingapore.com', '/editorials/singapores-annual-cultural-events/', {'q': '{http}'});

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    return 'Request failed with status: ${response.statusCode}.';
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: 
        FutureBuilder<String>(
        future: getresponse(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData){
            String result = snapshot.data.toString();
            return SingleChildScrollView(
              child: Html(
                data: result.replaceAll("display:none;visibility:hidden", ""),
              ));
          } else {
            return Text("Not Available");
          }})
    );
  }
}