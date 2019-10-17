import 'dart:async';
import 'package:flutter/material.dart';
import '../util/NetUtils.dart';
import '../util/ThemeUtils.dart';
import '../api/Api.dart';
import 'dart:convert';
import '../constants/Constants.dart';
import '../widgets/SlideView.dart';
import '../pages/AmzDetailPage.dart';
import '../widgets/SlideViewIndicator.dart';

final slideViewIndicatorStateKey = GlobalKey<SlideViewIndicatorState>();

class MarketplacePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MarketplacePageState();
}

class MarketplacePageState extends State<MarketplacePage> {
  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  final ScrollController _controller = ScrollController();
  final TextStyle titleTextStyle = TextStyle(fontSize: 15.0);
  final TextStyle subtitleStyle =
      TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0);

  var listData;
  var slideData;
  var curPage = 1;
  int curMarket = 0;
  var listTotalSize = 0;
  var contentItem = [
    {
      'title': 'United States',
      'icon': 'images/app_flags/us.jpg'
    },
    {
      'title': 'United Kingdom',
      'icon': 'images/app_flags/uk.jpg'
    },
    {'title': 'Italy', 'icon': 'images/app_flags/it.jpg'},
    {
      'title': 'Germany',
      'icon': 'images/app_flags/de.jpg'
    },
    {'title': 'Spin', 'icon': 'images/app_flags/es.jpg'},
    {
      'title': 'France',
      'icon': 'images/app_flags/fr.jpg'
    },
    {
      'title': 'Canada',
      'icon': 'images/app_flags/ca.jpg'
    },
    {'title': 'Janpa', 'icon': 'images/app_flags/jp.jpg'}
  ];
  var rightArrowIcon = Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );
  SlideView slideView;
  SlideViewIndicator indicator;
  Color themeColor = ThemeUtils.currentColorTheme;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && contentItem.length < listTotalSize) {
        // scroll to bottom, get next page data
//        print("load more ... ");
        curPage++;
        getDealsList(true);
      }
    });
    getDealsList(false);
  }

  Future<Null> _pullToRefresh() async {
    curPage = 1;
    getDealsList(false);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 无数据时，显示Loading
    if (contentItem == null) {
      return Center(
        // CircularProgressIndicator是一个圆形的Loading进度条
        child: CircularProgressIndicator(),
      );
    } else {
      // 有数据，显示ListView
      Widget listView = ListView.builder(
        itemCount: contentItem.length * 2,
        itemBuilder: (context, i) => renderRow(i),
        controller: _controller,
      );
      // return RefreshIndicator(child: listView, onRefresh: _pullToRefresh);

      return new Scaffold(
          appBar: new AppBar(
            title: Text('Marketplace'),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 20.0, 8.0, 0.0),
                child: InkWell(
                  child: Text('Done'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: listView,
            ),
          ));
    }
  }

  // 获取优惠券码
  getCouponCode(String productId) {
    String url = Api.couponCode;
    url += "?product_id=$productId";
    NetUtils.get(url).then((data) {
      Map<String, dynamic> map = json.decode(data);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('The Code Has Been Copied !'),
                content: Text(
                    'Simply paste "${map['voucher']}"into the promo code box at checkout.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('close'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  FlatButton(
                      child: Text('Buy Now'),
                      onPressed: () => {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) =>
                                    AmzDetailPage(amzLink: map['amz_link'])))
                          }
                      // Navigator.pop(context, true),
                      ),
                ],
              ));
    });
  }

  // 从网络获取数据，isLoadMore表示是否是加载更多数据
  getDealsList(bool isLoadMore) {
    String url = Api.dealsList;
    url += "?pageIndex=$curPage&pageSize=10";
    NetUtils.get(url).then((data) {
      if (data != null) {
        // 将接口返回的json字符串解析为map类型
        Map<String, dynamic> map = json.decode(data);
        if (map['code'] == 200) {
          // code=0表示请求成功
          // var msg = map['msg'];
          // total表示资讯总条数
          listTotalSize = map['data'].length;
          // data为数据内容，其中包含slide和news两部分，分别表示头部轮播图数据，和下面的列表数据
          var _listData = map['data'];
          var _slideData = [];
          setState(() {
            if (!isLoadMore) {
              // 不是加载更多，则直接为变量赋值
              listData = _listData;
              slideData = _slideData;
            } else {
              // 是加载更多，则需要将取到的news数据追加到原来的数据后面
              List list1 = List();
              // 添加原来的数据
              list1.addAll(listData);
              // 添加新取到的数据
              list1.addAll(_listData);
              // 判断是否获取了所有的数据，如果是，则需要显示底部的"我也是有底线的"布局
              if (list1.length >= listTotalSize) {
                list1.add(Constants.endLineTag);
              }
              // 给列表数据赋��
              listData = list1;
              // 轮播图数据
              slideData = _slideData;
            }
            initSlider();
          });
        }
      }
    });
  }

  void initSlider() {
    indicator =
        SlideViewIndicator(slideData.length, key: slideViewIndicatorStateKey);
    slideView = SlideView(slideData, indicator, slideViewIndicatorStateKey);
  }

  renderRow(i) {
    if (i.isOdd) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Divider(
          height: 1.0,
        ),
      );
    }
    i = i ~/ 2;
    var item = contentItem[i];
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
          curMarket == i
              ? Icon(
                  Icons.done,
                  color: Colors.green,
                )
              : Text('')
        ],
      ),
    );
    return InkWell(
      child: Container(
        color: Colors.white,
        child: listItemContent,
      ),
      onTap: () {
        setState(() {
          curMarket = i;
        });
      },
    );
  }
}
