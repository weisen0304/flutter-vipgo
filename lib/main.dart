/**
 * Author: Weisen
 * Date: 2019-10-14 20:45:32
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants/Constants.dart';
import 'events/ChangeThemeEvent.dart';
import 'util/DataUtils.dart';
import 'util/ThemeUtils.dart';
import 'pages/NewsListPage.dart';
import 'pages/TweetsListPage.dart';
import 'pages/DiscoveryPage.dart';
import 'pages/MyInfoPage.dart';
import './widgets/MyDrawer.dart';

void main() {
  runApp(MyOSCClient());
}
class MyOSCClient extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyOSCClientState();
}

class MyOSCClientState extends State<MyOSCClient> {
  final appBarTitles = ['Home', 'Category', 'Discovery', 'Profile'];
  final tabTextStyleSelected = TextStyle(color: ThemeUtils.currentColorTheme, fontWeight: FontWeight.w300);
  final tabTextStyleNormal = TextStyle(color: const Color(0xff333333), fontWeight: FontWeight.w300);

  Color themeColor = ThemeUtils.currentColorTheme;
  int _tabIndex = 0;

  var tabImages;
  var _body;
  var pages;

  Image getTabImage(path) {
    return Image.asset(path, width: 20.0, height: 20.0);
  }

  @override
  void initState() {
    super.initState();
    DataUtils.getColorThemeIndex().then((index) {
      if (index != null) {
        ThemeUtils.currentColorTheme = ThemeUtils.supportColors[index];
        Constants.eventBus
            .fire(ChangeThemeEvent(ThemeUtils.supportColors[index]));
      }
    });
    Constants.eventBus.on<ChangeThemeEvent>().listen((event) {
      setState(() {
        themeColor = event.color;
      });
    });
    pages = <Widget>[
      NewsListPage(),
      TweetsListPage(),
      DiscoveryPage(),
      MyInfoPage()
    ];
    if (tabImages == null) {
      tabImages = [
        [
          getTabImage('images/home.png'),
          getTabImage('images/home_actived.png')
        ],
        [
          getTabImage('images/category.png'),
          getTabImage('images/category_actived.png')
        ],
        [
          getTabImage('images/collect.png'),
          getTabImage('images/collect_actived.png')
        ],
        [
          getTabImage('images/profile.png'),
          getTabImage('images/profile_actived.png')
        ]
      ];
    }
  }

  TextStyle getTabTextStyle(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabTextStyleSelected;
    }
    return tabTextStyleNormal;
  }

  Image getTabIcon(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabImages[curIndex][1];
    }
    return tabImages[curIndex][0];
  }

  Text getTabTitle(int curIndex) {
    return Text(appBarTitles[curIndex], style: getTabTextStyle(curIndex));
  }

  @override
  Widget build(BuildContext context) {
    _body = IndexedStack(
      children: pages,
      index: _tabIndex,
    );
    return MaterialApp(
      theme: ThemeData(primaryColor: themeColor),
      home: Scaffold(
          // appBar: AppBar(
          //   title: Text(appBarTitles[_tabIndex],
          //   style: TextStyle(color: Colors.white)),
          //   iconTheme: IconThemeData(color: Colors.white)
          // ),
          body: _body,
          bottomNavigationBar: CupertinoTabBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: getTabIcon(0), title: getTabTitle(0)),
              BottomNavigationBarItem(
                  icon: getTabIcon(1), title: getTabTitle(1)),
              BottomNavigationBarItem(
                  icon: getTabIcon(2), title: getTabTitle(2)),
              BottomNavigationBarItem(
                  icon: getTabIcon(3), title: getTabTitle(3)),
            ],
            currentIndex: _tabIndex,
            onTap: (index) {
              setState(() {
                _tabIndex = index;
              });
            },
          ),
          drawer: MyDrawer()),
    );
  }
}
