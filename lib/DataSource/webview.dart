import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class MyWebView extends StatefulWidget {
  final title;
  final selectedUrl;

  MyWebView({
    @required this.title,
    @required this.selectedUrl,
  });

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  bool isLoading= true;

  final _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: 
      Stack(
        children: <Widget>[
          WebView(
        initialUrl: widget.selectedUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
      ),
          isLoading ? Center( child: CircularProgressIndicator(),)
                    : Stack(),
        ],
      ),
      );
  }
}