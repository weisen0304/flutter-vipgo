import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class AmzDetailPage extends StatefulWidget {
  final String id;
  final String amzLink;

  AmzDetailPage({Key key, this.id, this.amzLink}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      AmzDetailPageState(id: this.id, amzLink: this.amzLink);
}

class AmzDetailPageState extends State<AmzDetailPage> {
  String id;
  String amzLink;
  bool loaded = false;
  String detailDataStr;
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  AmzDetailPageState({Key key, this.id, this.amzLink});

  @override
  void initState() {
    super.initState();
    // 监听WebView的加载事件
    flutterWebViewPlugin.onStateChanged.listen((state) {
      if (state.type == WebViewState.finishLoad) {
        // 加载完成
        setState(() {
          loaded = true;
        });

        flutterWebViewPlugin.evalJavascript(
            'document.getElementsByClassName("am-navbar am-navbar-light")[0].style = "display: none;"');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> titleContent = [];
    titleContent.add(Text(
      "vipgo.store",
      style: TextStyle(color: Colors.white),
    ));
    if (!loaded) {
      titleContent.add(CupertinoActivityIndicator());
    }
    titleContent.add(Container(width: 50.0));
    return WebviewScaffold(
      url: this.amzLink,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: titleContent,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      withZoom: false,
      withLocalStorage: true,
      withJavascript: true,
    );
  }
}
