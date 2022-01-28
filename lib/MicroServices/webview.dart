import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class MyWebView extends StatefulWidget {
  final title;
  final selectedUrl;
  final htmlString;

  MyWebView({
    @required this.title,
    this.selectedUrl,
    this.htmlString,
  });

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  bool isLoading = true;
    final _controller = Completer<WebViewController>();

  _renderWebview() {
    if (this.widget.selectedUrl != null) {
      //render from website
      return WebView(
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
      );
    } else {
      //render from local html string
      return WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          webViewController.loadUrl(Uri.dataFromString(this.widget.htmlString,
                  mimeType: 'text/html', encoding: utf8)
              .toString());
          _controller.complete(webViewController);
        },
        onPageFinished: (finish) {
          setState(() {
            isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          _renderWebview(),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(),
        ],
      ),
    );
  }
}
