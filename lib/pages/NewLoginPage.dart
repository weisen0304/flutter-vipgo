/**
 * Author: Weisen
 * Date: 2019-10-14 20:43:15
 * Github: https://github.com/weisen0304
 */
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/util/DataUtils.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';
import 'package:flutter_osc/widgets/CommonButton.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../pages/PasswordRestPage.dart';
import '../pages/JoinNowPage.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
//   // 'eamil',
//   // 'https://www.googleapis.com/auth/contacts.readonly'
//   'https://www.googleapis.com/auth/drive'
// ]);

// 新的登录界面，隐藏WebView登录页面
class NewLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewLoginPageState();
}

class NewLoginPageState extends State<NewLoginPage> {
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

  // URL变化监听器
  StreamSubscription<String> _onUrlChanged;
  // WebView加载状态变化监听器
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  // 插件提供的对象，该对象用于WebView的各种操作
  FlutterWebviewPlugin flutterWebViewPlugin = FlutterWebviewPlugin();

  // GoogleSignInAccount _currentUser;

  // String _contactText;

  @override
  void initState() {
    super.initState();
    // 监听WebView的加载事件
    // _onStateChanged =
    //     flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
    //   // state.type是一个枚举类型，取值有：WebViewState.shouldStart, WebViewState.startLoad, WebViewState.finishLoad
    //   switch (state.type) {
    //     case WebViewState.shouldStart:
    //       // 准备加载
    //       setState(() {
    //         loading = true;
    //       });
    //       break;
    //     case WebViewState.startLoad:
    //       // 开始加载
    //       break;
    //     case WebViewState.finishLoad:
    //       // 加载完成
    //       setState(() {
    //         loading = false;
    //       });
    //       if (isLoadingCallbackPage) {
    //         // 当前是回调页面，则调用js方法获取数据，延迟加载防止get()获取不到数据
    //         Timer(const Duration(seconds: 1), () {
    //           parseResult();
    //         });
    //         return;
    //       }
    //       switch (curState) {
    //         case stateFirstLoad:
    //         case stateLoadedInputPage:
    //           // 首次加载完登录页，判断是否是输入账号密码的界面
    //           isInputPage().then((result) {
    //             if ("true".compareTo(result) == 0) {
    //               // 是输入账号的页面，则直接填入账号密码并模拟点击登录按钮
    //               // autoLogin();
    //             } else {
    //               // 不是输入账号的页面，则需要模拟点击"换个账号"按钮
    //               redirectToInputPage();
    //             }
    //           });
    //           break;
    //         case stateLoadedNotInputPage:
    //           // 不是输入账号密码的界面，则需要模拟点击"换个账号"按钮
    //           break;
    //       }
    //       break;
    //     case WebViewState.abortLoad:
    //       break;
    //   }
    // });
    // _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((url) {
    //   // 登录成功会跳转到自定义的回调页面，该页面地址为http://yubo725.top/osc/osc.php?code=xxx
    //   // 该页面会接收code，然后根据code换取AccessToken，并将获取到的token及其他信息，通过js的get()方法返回
    //   if (url != null && url.length > 0 && url.contains("/logincallback")) {
    //     isLoadingCallbackPage = true;
    //   }
    // });
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //     _currentUser = account;
    //   });
    //   if (_currentUser != null) {
    //     _handleGetContact();
    //   }
    // });
    // _googleSignIn.signInSilently();
  }

  // Future<void> _handleGetContact() async {
  //   setState(() {
  //     _contactText = "Loading contact info...";
  //   });
  //   final http.Response response = await http.get(
  //     'https://people.googleapis.com/v1/people/me/connections'
  //     '?requestMask.includeField=person.names',
  //     headers: await _currentUser.authHeaders,
  //   );
  //   if (response.statusCode != 200) {
  //     setState(() {
  //       _contactText = "People API gave a ${response.statusCode} "
  //           "response. Check logs for details.";
  //     });
  //     print('People API ${response.statusCode} response: ${response.body}');
  //     return;
  //   }
  //   final Map<String, dynamic> data = json.decode(response.body);
  //   final String namedContact = _pickFirstNamedContact(data);
  //   setState(() {
  //     if (namedContact != null) {
  //       _contactText = "I see you know $namedContact!";
  //     } else {
  //       _contactText = "No contacts to display.";
  //     }
  //   });
  // }

  //   String _pickFirstNamedContact(Map<String, dynamic> data) {
  //   final List<dynamic> connections = data['connections'];
  //   final Map<String, dynamic> contact = connections?.firstWhere(
  //     (dynamic contact) => contact['names'] != null,
  //     orElse: () => null,
  //   );
  //   if (contact != null) {
  //     final Map<String, dynamic> name = contact['names'].firstWhere(
  //       (dynamic name) => name['displayName'] != null,
  //       orElse: () => null,
  //     );
  //     if (name != null) {
  //       return name['displayName'];
  //     }
  //   }
  //   return null;
  // }

  // Future<void> _handleSignIn() async {
  //   try {
  //     await _googleSignIn.signIn();
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  // Future<void> _handleSignOut() async {
  //   _googleSignIn.disconnect();
  // }

  // 检查当前WebView是否是输入账号密码的页面
  Future<String> isInputPage() async {
    return await flutterWebViewPlugin
        .evalJavascript("document.getElementById('f_email') != null");
  }

  // 跳转到输入界面
  redirectToInputPage() {
    curState = stateLoadedInputPage;
    String js =
        "document.getElementsByClassName('userbar')[0].getElementsByTagName('a')[1].click()";
    flutterWebViewPlugin.evalJavascript(js);
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

  // 解析WebView中的数据
  void parseResult() {
    if (parsedResult) {
      return;
    }
    parsedResult = true;
    flutterWebViewPlugin.evalJavascript("window.atob(get())").then((result) {
      // result json字符串，包含token信息
      if (result != null && result.length > 0) {
        // 拿到了js中的数据
        try {
          // what the fuck?? need twice decode??
          var map = json.decode(result); // s is String
          if (map is String) {
            map = json.decode(map); // map is Map
          }
          if (map != null) {
            // 登录成功，取到了token，关闭当前页面
            DataUtils.saveLoginInfo(map);
            // Navigator.pop(context, "refresh");
          }
        } catch (e) {
          print("parse login result error: $e");
        }
      }
    }).catchError((error) {
      print("get() error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    var loginBtn = Builder(builder: (ctx) {
      return CommonButton(
          height: 48,
          text: "Sign In",
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
            // autoLogin(username, password);
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
          // title: Text("Log In", style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
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
                child: Image.asset('images/vipgo_logo_168x580@1x.png',
                    width: 150.0, height: 60.0),
              ),
              Center(
                  child: Text(
                "Welcome Back",
                style: TextStyle(fontSize: 20.0),
              )),
              Container(height: 10.0),
              Center(
                child: Text(
                  "Sign in your account to save your favorite deals, create custom deal alerts and more.",
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
                                const Radius.circular(6.0))),
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
                              child: Text(
                                'Forget?',
                                style: TextStyle(
                                    color: ThemeUtils.currentColorTheme),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return PasswordRestPage();
                                }));
                              }),
                        )),
                  )
                ],
              ),
              Container(height: 20.0),
              loginBtn,
              Container(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                          padding: EdgeInsets.all(2.0),
                          // width: 200.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: const Color(0xffcccccc), width: 0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0))),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    'images/facebook.png',
                                    width: 20,
                                    height: 20,
                                    color: Color(0xff3c5a99),
                                  )),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'with Facebook',
                                  style:
                                      TextStyle(color: const Color(0xFF808080)),
                                ),
                              ),
                            ],
                          ))),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                            padding: EdgeInsets.all(2.0),
                            width: 100.0,
                            height: 45.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xffcccccc), width: 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Image.asset(
                                      'images/google.png',
                                      width: 20,
                                      height: 20,
                                      color: Color(0xffd81e06),
                                    )),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'with google',
                                    style: TextStyle(
                                        color: const Color(0xFF808080)),
                                  ),
                                ),
                              ],
                            )),
                        // onTap: _handleSignIn,
                      )),
                ],
              ),
              Container(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text.rich(TextSpan(
                      text: "Don't have an account?",
                      style:
                          TextStyle(fontSize: 12.0, color: Color(0xffaaaaaa)),
                      children: <TextSpan>[
                        TextSpan(
                            text: "  Join Now",
                            style: TextStyle(
                                fontSize: 12.0, color: Color(0xff409eff)),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                //添加一个点击事件
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return JoinNowPage();
                                }));
                              })
                      ])),
                ],
              ),
              Expanded(
                  child: Column(
                children: <Widget>[
                  Expanded(child: loadingView),
//                  Container(
//                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
//                    alignment: Alignment.bottomCenter,
//                    child: InkWell(
//                      child: Padding(
//                          padding: const EdgeInsets.all(10.0),
//                          child: Text("使用WebView登录方式", style: TextStyle(fontSize: 13.0, color: ThemeUtils.currentColorTheme))
//                      ),
//                      onTap: () async {
//                        // 跳���到LoginPage
//                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
//                          return LoginPage();
//                        }));
//                        if (result != null && result == "refresh") {
//                          Navigator.pop(context, "refresh");
//                        }
//                      },
//                    ),
//                  ),
                ],
              ))
            ],
          ),
        ));
  }

  // @override
  // void dispose() {
  //   // 回收相关资源
  //   // Every listener should be canceled, the same should be done with this stream.
  //   _onUrlChanged.cancel();
  //   _onStateChanged.cancel();
  //   flutterWebViewPlugin.dispose();

  //   super.dispose();
  // }
}
