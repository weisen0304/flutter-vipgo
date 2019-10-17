import 'package:flutter/material.dart';
import 'package:flutter_osc/constants/Constants.dart';
import 'package:flutter_osc/events/ChangeThemeEvent.dart';
import 'package:flutter_osc/events/LoginEvent.dart';
import 'package:flutter_osc/events/LogoutEvent.dart';
import 'package:flutter_osc/util/ThemeUtils.dart';
import '../pages/CommonWebPage.dart';
import '../pages/LoginPage.dart';
import '../pages/NewLoginPage.dart';
import '../pages/HistoryListPage.dart';
import '../pages/DealRequestPage.dart';
import '../pages/EarnMoneyDetailPage.dart';
import '../pages/MyFavoritePage.dart';
import '../pages/NotificationPage.dart';
import '../pages/MarketplacePage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/Api.dart';
import '../util/NetUtils.dart';
import '../util/DataUtils.dart';
import '../model/UserInfo.dart';

class MyInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyInfoPageState();
  }
}

class MyInfoPageState extends State<MyInfoPage> {
  Color themeColor = ThemeUtils.currentColorTheme;

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var titles = [
    "My Deal Requests",
    "Refer & Earn Money",
    "My Favorite",
    "My Browsing History",
    "Notification",
    "Account Settings"
  ];
  var moreCount = 1;
  var imagePaths = [
    "images/ic_my_message.png",
    "images/ic_my_blog.png",
    "images/ic_my_blog.png",
    "images/ic_my_question.png",
    "images/ic_discover_pos.png",
    "images/ic_my_team.png",
    "images/ic_my_recommend.png"
  ];
  var contentItem = [
    {'title': 'My Deal Requests', 'icon': 'images/ic_my_message.png'},
    {'title': 'Refer & Earn Money', 'icon': 'images/ic_my_blog.png'},
    {'title': 'My Favorite', 'icon': 'images/ic_my_blog.png'},
    {'title': 'My Browsing History', 'icon': 'images/ic_discover_pos.png'},
    {'title': 'Notification', 'icon': 'images/ic_my_team.png'},
    {'title': 'Account Settings', 'icon': 'images/ic_my_recommend.png'}
  ];
  var icons = [];
  var userAvatar;
  var userName;
  var titleTextStyle = TextStyle(fontSize: 16.0);
  var rightArrowIcon = Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );

  MyInfoPageState() {
    for (int i = 0; i < imagePaths.length; i++) {
      icons.add(getIconImage(imagePaths[i]));
    }
  }

  @override
  void initState() {
    super.initState();
    _showUserInfo();
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      // 收到退出登录的消息，刷新个人信息显示
      _showUserInfo();
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      // 收到登录的消息，重新获取个人信息
      getUserInfo();
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        themeColor = event.color;
      });
    });
  }

  _showUserInfo() {
    DataUtils.getUserInfo().then((UserInfo userInfo) {
      if (userInfo != null) {
        print(userInfo.name);
        print(userInfo.avatar);
        setState(() {
          userAvatar = userInfo.avatar;
          userName = userInfo.name;
        });
      } else {
        setState(() {
          userAvatar = null;
          userName = null;
        });
      }
    });
  }

  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child:
          Image.asset(path, width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
    );
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemCount: contentItem.length * 2,
      itemBuilder: (context, i) => renderRow(i),
    );
    return new Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: new AppBar(
        title: Text('Profile'),
      ),
      body: listView,
    );
  }

  // 获取用户信息
  getUserInfo() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String accessToken = sp.get(DataUtils.SP_AC_TOKEN);
      Map<String, String> params = Map();
      params['access_token'] = accessToken;
      NetUtils.get(Api.userInfo, params: params).then((data) {
        if (data != null) {
          var map = json.decode(data);
          setState(() {
            userAvatar = map['avatar'];
            userName = map['name'];
          });
          DataUtils.saveUserInfo(map);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _login() async {
    // 打开登录页并处理登录成功的回调
    final result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewLoginPage();
    }));
    // result为"refresh"代表登录成功
    if (result != null && result == "refresh") {
      // 刷新用户信息
      getUserInfo();
      // 通知动弹页面刷新
      Constants.eventBus.fire(LoginEvent());
    }
  }

  _showUserInfoDetail() {}

  renderRow(i) {
    if (i == 0) {
      var avatarContainer = Container(
          color: Colors.white,
          // height: 200.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 40.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "images/jl_logo.png",
                          width: 120.0,
                          height: 80.0,
                        ),
                        Text(
                          'weisen170304@gmail.com',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 20.0, 0),
                                child: Icon(
                                  Icons.help,
                                  size: 16,
                                ),
                              )
                            ]),
                        Text(
                          '\$0.00',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Container(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            //   return HistoryListPage();
                            // }));
                          },
                          child: Container(
                            width: 110,
                            height: 36,
                            decoration: BoxDecoration(
                                color: themeColor,
                                border: Border.all(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0.0))),
                            child: Center(
                              child: Text(
                                'WITHDRAW',
                                // this.widget.text,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 6,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return HistoryListPage();
                            }));
                          },
                          child: Container(
                            width: 110,
                            height: 36,
                            decoration: BoxDecoration(
                                // color: color,
                                border: Border.all(color: themeColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0.0))),
                            child: Center(
                              child: Text(
                                'HISTORY',
                                // this.widget.text,
                                style: TextStyle(color: themeColor),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ));
      return GestureDetector(
        onTap: () {
          DataUtils.isLogin().then((isLogin) {
            if (!isLogin) {
              // 已登录，显示用户详细信息
              _showUserInfoDetail();
            } else {
              // 未登录，跳转到登录页面
              _login();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          child: avatarContainer,
        ),
      );
    }
    --i;
    if (i.isOdd) {
      return Divider(
        height: 1.0,
      );
    }
    i = i ~/ 2;
    var item = contentItem[i];
    if (i != contentItem.length - moreCount) {
      var listItemContent = Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Image.asset(item['icon'],
                  width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
            ),
            Expanded(
                child: Text(
              item['title'],
              style: titleTextStyle,
            )),
            rightArrowIcon
          ],
        ),
      );
      return InkWell(
        child: Container(
          color: Colors.white,
          child: listItemContent,
        ),
        onTap: () {
          if (item['title'] == 'My Deal Requests') {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DealRequestPage()));
          } else if (item['title'] == 'Refer & Earn Money') {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EarnMoneyDetailPage()));
          } else if (item['title'] == 'My Favorite') {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MyFavoritePage()));
          } else if (item['title'] == 'My Browsing History') {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HistoryListPage()));
          } else if (item['title'] == 'Notification') {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NotificationPage()));
          }
        },
      );
    } else {
      var moreItemContent = Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Image.asset(item['icon'],
                  width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
            ),
            Expanded(
                child: Text(
              item['title'],
              style: titleTextStyle,
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Image.network(
                  'https://www.vipon.com/images/app_flags/us.jpg',
                  width: IMAGE_ICON_WIDTH,
                  height: IMAGE_ICON_WIDTH),
            ),
            rightArrowIcon
          ],
        ),
      );
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Container(color: Colors.white, child: moreItemContent),
        ),
        onTap: () {
          if (item['title'] == 'Account Settings') {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MarketplacePage()));
          }
        },
      );
    }
  }

  _showLoginDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('没���登录，现在去登录吗？'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  '确定',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _login();
                },
              )
            ],
          );
        });
  }

  _handleListItemClick(String title) {
    DataUtils.isLogin().then((isLogin) {
      if (!isLogin) {
        // 未登录
        _showLoginDialog();
      } else {
        DataUtils.getUserInfo().then((info) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommonWebPage(
                  title: "我的博客",
                  url: "https://my.oschina.net/u/${info.id}/blog")));
        });
      }
    });
  }
}
