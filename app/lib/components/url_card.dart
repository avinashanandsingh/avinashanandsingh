import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UrlCard extends StatefulWidget {
  final String url;
  const UrlCard({super.key, required this.url});

  @override
  State<UrlCard> createState() => UrlCardState();
}

class UrlCardState extends State<UrlCard> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JS
      ..loadRequest(Uri.parse(widget.url)); // Load initial URL
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller); // Display the WebView
  }
}
