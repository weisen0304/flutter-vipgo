import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vipgo/constants/Constants.dart';
import 'package:flutter_vipgo/util/ThemeUtils.dart';
import 'package:flutter_vipgo/widgets/CommonButton.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../pages/PasswordHelpPage.dart';

// 新的登录界面，隐藏WebView登录页面
class PasswordRestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PasswordRestPageState();
}

class PasswordRestPageState extends State<PasswordRestPage> {
  // 首次加载登录页
  static const int stateFirstLoad = 1;
  // 加载完毕登录页，且当前页面是输入账号密码的页面
  static const int stateLoadedInputPage = 2;
  // 加载完毕登录页，且当前页面不是输入账号密码的页面
  static const int stateLoadedNotInputPage = 3;

  int curState = stateFirstLoad;

  // 标记是否是加载中
  bool loading = true;
  // 标记当前页面是否是我们自定义的回调页面
  bool isLoadingCallbackPage = false;
  // 是否正在登录
  bool isOnLogin = false;
  // 是否隐藏输入的文本
  bool obscureText = true;
  // 是否解析了结果
  bool parsedResult = false;

  final usernameCtrl = TextEditingController(text: '');
  final passwordCtrl = TextEditingController(text: '');

  // 检查当前是否是输入账号密码界面，返回1表示是，0表示否
  final scriptCheckIsInputAccountPage =
      "document.getElementById('f_email') != null";

  final jsCtrl = TextEditingController(
      text: 'document.getElementById(\'f_email\') != null');
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
  }

  // 自动登录
  void autoLogin(String account, String pwd) {
    setState(() {
      isOnLogin = true;
    });
    // 填账号
    String jsInputAccount =
        "document.getElementById('f_email').value='$account'";
    // 填密码
    String jsInputPwd = "document.getElementById('f_pwd').value='$pwd'";
    // 点击"连接"按钮
    String jsClickLoginBtn =
        "document.getElementsByClassName('rndbutton')[0].click()";
    // 执行上面3条js语句
    flutterWebViewPlugin
        .evalJavascript("$jsInputAccount;$jsInputPwd;$jsClickLoginBtn");
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = Builder(builder: (ctx) {
      return CommonButton(
          height: 48,
          text: "Send verification code",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PasswordHelpPage();
            }));
          });
    });
    var loadingView;
    if (isOnLogin) {
      loadingView = Center(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[CupertinoActivityIndicator(), Text("loading...")],
        ),
      ));
    } else {
      loadingView = Center();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Password Reset", style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Color(0xf2f4f6ff),
        body: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Enter the email address associated with you vipgo account. We'll sent a code to the email Please enter it below.",
                style: TextStyle(fontSize: 12.0, color: Color(0xffaaaaaa)),
              ),
              Container(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                        hintText: "Email address",
                        hintStyle: TextStyle(color: const Color(0xFF808080)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(6.0))),
                        focusColor: Colors.white,
                        contentPadding: const EdgeInsets.all(13.0)),
                  ))
                ],
              ),
              Container(height: 20.0),
              loginBtn,
            ],
          ),
        ));
  }
}
