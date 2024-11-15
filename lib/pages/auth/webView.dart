import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

//dont mind this code, this was only an experiment

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()..setUserAgent("random")..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse("https://accounts.google.com/o/oauth2/v2/auth").replace(queryParameters: {
          "redirect_uri":"http://fakedomain.com:3000/api/sessions/oauth/google",
          "client_id":"157467086379-irobhiqof29bt3um1ls5qq6jl4rg1ji5.apps.googleusercontent.com",
          "access_type":"offline",
          "response_type":"code",
          "prompt":"consent",
          "scope":['https://www.googleapis.com/auth/userinfo.profile',"https://www.googleapis.com/auth/userinfo.email"].join(" ")
        }),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'),
      ),
      body: WebViewWidget(
        
        controller: controller,
      ),
    );
  }
}