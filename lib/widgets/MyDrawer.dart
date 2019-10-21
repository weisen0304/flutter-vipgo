import 'package:flutter/material.dart';
import '../pages/AboutPage.dart';
import '../pages/BlackHousePage.dart';
import '../pages/PublishTweetPage.dart';
import '../pages/MarketplacePage.dart';
import '../pages/NewsListPage.dart';
import '../pages/CommonWebPage.dart';
import '../util/ThemeUtils.dart';

class MyDrawer extends StatelessWidget {
  // 菜单文本前面的图标大小
  static const double IMAGE_ICON_WIDTH = 26.0;
  // 菜单后面的箭头的图标大小
  static const double ARROW_ICON_WIDTH = 12.0;
  // 菜单后面的箭头图片
  var rightArrowIcon = Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
    color: Color(0xFFCCCCCC),
  );
  // 菜单的文本
  List menuTitles = [
    'Home',
    'Join as Seller',
    'What is Vipgo',
    'United States'
  ];
  // 菜单文本前面的图标
  List menuIcons = [
    './images/leftmenu/ic_fabu.png',
    './images/leftmenu/ic_xiaoheiwu.png',
    './images/leftmenu/ic_about.png',
    './images/leftmenu/ic_settings.png'
  ];
  // 菜单文本的样式
  TextStyle menuStyle = TextStyle(
    fontSize: 15.0,
  );
  Color themeColor = ThemeUtils.currentColorTheme;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(width: 304.0),
      child: Material(
        elevation: 16.0,
        child: ListView.builder(
          itemCount: menuTitles.length * 2 + 1,
          itemBuilder: renderRow,
          padding: const EdgeInsets.all(0.0), // 加上这一行可以让Drawer展开时，状态栏中不显示白色
        ),
      ),
    );
  }

  Widget getIconImage(path) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 0.0, 6.0, 0.0),
      child: Image.asset(path, width: 28.0, height: 28.0),
    );
  }

  Widget renderRow(BuildContext context, int index) {
    if (index == 0) {
      // render cover image
      // var img = Image.asset(
      //   './images/cover_img.jpg',
      //   width: 304.0,
      //   height: 304.0,
      // );
      return Container(
        width: 304.0,
        height: 132.0,
        color: themeColor,
        padding: const EdgeInsets.fromLTRB(10.0, 80.0, 0.0, 20.0),
        child: Text(
          'hello, weisen170304@gmail.com',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    }
    // 舍去之前的封面图
    index -= 1;
    // 如果是奇数则渲染分割线
    if (index.isOdd) {
      return Divider();
    }
    // 偶数，就除2取整，然后渲染菜单item
    index = index ~/ 2;
    // 菜单item组件
    var listItemContent = Padding(
      // 设置item的外边距
      padding: const EdgeInsets.fromLTRB(30.0, 18.0, 10.0, 18.0),
      // Row组件构成item的一行
      child: Row(
        children: <Widget>[
          index == menuTitles.length - 1
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Image.asset('images/app_flags/us.jpg',
                      width: IMAGE_ICON_WIDTH, height: IMAGE_ICON_WIDTH),
                )
              : Text(''),
          // 菜单item的图标
          // getIconImage(menuIcons[index]),
          // 菜单item的文本，需要
          Expanded(
              child: Text(
            menuTitles[index],
            style: menuStyle,
          )),

          rightArrowIcon
        ],
      ),
    );

    return InkWell(
      child: listItemContent,
      onTap: () {
        switch (index) {
          case 0:
            // Home
            // Navigator.of(context).pop();
            // TODO: 判断是否为首页底部路由切换
            // ModalRoute.of(context).isCurrent
            //     ? Navigator.of(context).pop()
            //     : Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
            //         return NewsListPage();
            //       }));
            break;
          case 1:
            // Join as Seller
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return CommonWebPage(
                url: 'https://seller.myvipon.com/',
                title: 'Join as Seller',
              );
            }));
            break;
          case 2:
            // What is Vipgo
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return CommonWebPage(
                url:
                    'https://www.vipon.com/amazon-coupons/about?ref=menu_aboutvipon',
                title: 'What is Vipgo',
              );
            }));
            break;
          case 3:
            // United States
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return MarketplacePage();
            }));
            break;
        }
      },
    );
  }
}
