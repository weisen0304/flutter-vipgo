import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/pages/NewLoginPage.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';
import 'package:flutter_osc/widgets/CommonButton.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// 新的登录界面，隐藏WebView登录页面
class JoinNowPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JoinNowPageState();
}

class JoinNowPageState extends State<JoinNowPage> {
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

  bool isAgrre = false;

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
          text: "Join Now",
          onTap: () {
            if (isOnLogin) return;
            // 拿到用户输入的账号密码
            String username = usernameCtrl.text.trim();
            String password = passwordCtrl.text.trim();
            if (username.isEmpty || password.isEmpty) {
              Scaffold.of(ctx).showSnackBar(SnackBar(
                content: Text("账号和密码不能为空！"),
              ));
              return;
            }
            // 关闭键盘
            FocusScope.of(context).requestFocus(FocusNode());
            // 发送给webview，让webview登录后再取回token
            autoLogin(username, password);
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
          // title: Text("Join Now", style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        backgroundColor: Color(0xf2f4f6ff),
        body: Container(
          padding: const EdgeInsets.fromLTRB(40.0, 120.0, 40.0, 50.0),
          child: Column(
            children: <Widget>[
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   height: 0.0,
              //   child: WebviewScaffold(
              //     key: _scaffoldKey,
              //     hidden: true,
              //     url: Constants.loginUrl, // 登录的URL
              //     withZoom: true, // 允许网页缩放
              //     withLocalStorage: true, // 允许LocalStorage
              //     withJavascript: true, // 允许执行js代码
              //   ),
              // ),
              Center(
                child: Image.asset('images/jl_logo.png',
                    width: 150.0, height: 60.0),
              ),
              Center(
                  child: Text(
                "Join Vipgo",
                style: TextStyle(fontSize: 20.0),
              )),
              Container(height: 10.0),
              Center(
                child: Text(
                  "Create custom dela Alerts",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, color: Color(0xffaaaaaa)),
                ),
              ),
              Center(
                child: Text(
                  "and be the first to know about new deals",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, color: Color(0xffaaaaaa)),
                ),
              ),
              Container(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: const Color(0xFF808080)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0))),
                        focusColor: Colors.white,
                        contentPadding: const EdgeInsets.all(13.0)),
                  ))
                ],
              ),
              Container(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                        controller: passwordCtrl,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: const Color(0xFF808080)),
                          filled: true,
                          fillColor: Colors.white,
                          enabled: true,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(6.0))),
                          contentPadding: const EdgeInsets.all(13.0),
                          suffix: InkWell(
                            child: Icon(
                              Icons.remove_red_eye,
                              color: Color(0xFFCCCCCC),
                            ),
                            onTap: () => print('123'),
                          ),
                        )),
                  )
                ],
              ),
              Container(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Please enter the answer:',
                    style: TextStyle(color: const Color(0xFF808080)),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '9 - 6 =  ',
                        style: TextStyle(color: const Color(0xFF808080)),
                      ),
                      Container(
                        width: 60,
                        child: TextField(
                          controller: usernameCtrl,
                          decoration: InputDecoration(
                              hintText: "",
                              hintStyle:
                                  TextStyle(color: const Color(0xFF808080)),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      const Radius.circular(10.0))),
                              focusColor: Colors.white,
                              contentPadding: const EdgeInsets.all(6.0)),
                        ),
                      )
                    ],
                  )
                ],
              ),
              Container(height: 20.0),
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                    width: 20,
                    child: Checkbox(
                      value: this.isAgrre,
                      activeColor: Colors.blue,
                      onChanged: (bool isAgrre) {
                        print(this.isAgrre);
                        this.setState(() {
                          this.isAgrre = !this.isAgrre;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: new TextSpan(
                        text:
                            'Subscribe to Vipgo newsletter to receive the best deals, coupons and special offerss.',
                        style: TextStyle(color: const Color(0xFF808080)),
                      ),
                    ),
                  )
                ],
              ),
              Container(height: 16.0),
              loginBtn,
              Container(height: 16.0),
              Text.rich(
                TextSpan(
                    text: "Already have an account?",
                    style: TextStyle(
                        fontSize: 12.0, color: Color(0xffaaaaaa), height: 2.0),
                    children: <TextSpan>[
                      TextSpan(
                          text: "  Sign In",
                          style: TextStyle(
                              fontSize: 12.0, color: Color(0xff409eff)),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              // 添加一个点击事件
                              // Navigator.of(context)
                              //     .push(MaterialPageRoute(builder: (context) {
                              //   return NewLoginPage();
                              // }));
                              Navigator.of(context).pop();
                            })
                    ]),
                textAlign: TextAlign.center,
              ),
              Text.rich(
                TextSpan(
                    text:
                        "By clicking  Sign In, you have read and agree to the",
                    style: TextStyle(
                        fontSize: 12.0, color: Color(0xffaaaaaa), height: 1.5),
                    children: <TextSpan>[
                      TextSpan(
                          text: " Terams of Service",
                          style: TextStyle(
                              fontSize: 12.0, color: Color(0xff409eff))),
                      TextSpan(
                        text: " and",
                      ),
                      TextSpan(
                          text: " Privacy Policy",
                          style: TextStyle(
                              fontSize: 12.0, color: Color(0xff409eff)))
                    ]),
                textAlign: TextAlign.center,
              ),
              Expanded(
                  child: Column(
                children: <Widget>[
                  Expanded(child: loadingView),
                ],
              ))
            ],
          ),
        ));
  }
}
