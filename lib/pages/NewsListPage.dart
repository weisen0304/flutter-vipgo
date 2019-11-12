import 'dart:async';
import 'package:flutter/material.dart';
import '../util/NetUtils.dart';
import '../util/ThemeUtils.dart';
import '../api/Api.dart';
import 'dart:convert';
import '../constants/Constants.dart';
import '../widgets/SlideView.dart';
import '../pages/NewsDetailPage.dart';
import '../pages/NewsListPageSearch.dart';
import '../pages/DealRequestPage.dart';
import '../widgets/CommonEndLine.dart';
import '../widgets/SlideViewIndicator.dart';
import '../widgets/CommonButton.dart';
import 'package:flutter/cupertino.dart';
import '../pages/CommonWebPage.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  final TextStyle titleTextStyle = TextStyle(fontSize: 15.0);
  final TextStyle subtitleStyle =
      TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0);
  final List<Tab> _topTabs = <Tab>[
    Tab(
      text: 'Featured',
    ),
    Tab(
      text: 'Instant',
    ),
    Tab(
      text: 'Upcoming',
    ),
    Tab(
      text: 'Group',
    )
  ];
  TabController _tabController;

  var listData;
  var slideData;
  var curPage = 1;
  var listTotalSize = 0;
  SlideView slideView;
  SlideViewIndicator indicator;
  Color themeColor = ThemeUtils.currentColorTheme;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _topTabs.length);
    _tabController.addListener(() {
      listData.clear();
      getNewsList(true);
    });
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels &&
          pixels > 0 &&
          listData.length < listTotalSize) {
        curPage++;
        getNewsList(true);
      }
    });
    getNewsList(false);
  }

  Future<Null> _pullToRefresh() async {
    curPage = 1;
    listData.clear();
    getNewsList(true);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 无数据时，显示Loading
    if (listData == null) {
      return Center(
        // CircularProgressIndicator是一个圆形的Loading进度条
        child: CircularProgressIndicator(),
      );
    } else {
      // 有数据，显示ListView
      Widget listView = ListView.builder(
        itemCount: listData.length * 2,
        itemBuilder: (context, i) => renderRow(i),
        controller: _controller,
      );

      return new DefaultTabController(
          initialIndex: 0,
          length: _topTabs.length,
          child: new Scaffold(
            appBar: new AppBar(
              leading: InkWell(
                child: Icon(
                  Icons.dehaze,
                  size: 24,
                ),
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              title: Row(
                children: <Widget>[
                  Expanded(
                    // flex: 10,
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Search Deal",
                          hintStyle: TextStyle(
                              color: const Color(0xFF808080), fontSize: 12.0),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                  const Radius.circular(6.0))),
                          focusColor: Colors.white,
                          contentPadding: const EdgeInsets.all(8.0)),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return NewsListPageSearch();
                        }));
                      },
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                InkWell(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                    padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                    child: Image.asset(
                      'images/app_iconfont/coupon2.png',
                      width: 24.0,
                      height: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => DealRequestPage()));
                  },
                )
              ],
              bottom: new TabBar(
                tabs: _topTabs,
                controller: _tabController,
                labelColor: Colors.white,
                indicatorColor: themeColor,
                onTap: (i) => {getNewsList(false)},
              ),
            ),
            body: new TabBarView(
                controller: _tabController,
                children: _topTabs.map((Tab tab) {
                  return RefreshIndicator(
                      child: listView, onRefresh: _pullToRefresh);
                }).toList()),
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
          builder: (context) => CupertinoAlertDialog(
                  title: Text('The Code Has Been Copied!'), //对话框标题
                  content: SingleChildScrollView(
                    //对话框内容部分
                    child: ListBody(
                      children: [
                        Text(
                            'simply paste "${map['voucher']}" into the promo code box at checkout.')
                      ],
                    ),
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Got it'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => CommonWebPage(
                                  title: 'Vipgo.store',
                                  url: map['amz_link'],
                                )));
                      },
                    ),
                    // CupertinoDialogAction(
                    //   child: Text('取消'),
                    //   onPressed: () {},
                    // ),
                  ]));
    });
  }

  // 从网络获取数据，isLoadMore表示是否是加载更多数据
  getNewsList(bool isLoadMore) {
    String url = Api.newsList;
    url += "?pageIndex=$curPage&pageSize=10";
    print(url);
    NetUtils.get(url).then((data) {
      print(data);
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        if (map['code'] == 200) {
          listTotalSize = 24;
          // data为数据内容，其中包含slide和news两部分，分别表示头部轮播图数据，和下面的列表数据
          var _listData = map['data'];
          setState(() {
            if (!isLoadMore) {
              // 不是加载更多，则直接为变量赋值
              listData = _listData;
            } else {
              // 是加载更多，则需要将取到的news数据追加到原来的数据后�����
              List list1 = List();
              // 添加原来的数据
              list1.addAll(listData);
              // 添加新取到的数据
              list1.addAll(_listData);
              // 判断是否获取了所有的数据，如果是，则需要显示底部的"我也是有底线的"布局
              if (list1.length >= listTotalSize) {
                list1.add(Constants.endLineTag);
              }
              // 给列表数据赋值
              listData = list1;
            }
          });
        }
      }
    });
  }

  Widget renderRow(i) {
    i -= 1;
    if (i.isOdd) {
      return Divider(height: 1.0);
    }
    i = i ~/ 2;
    var itemData = listData[i];
    if (itemData is String && itemData == Constants.endLineTag) {
      return CommonEndLine();
    }
    var titleRow = Row(
      children: <Widget>[
        Expanded(
          child: Text(itemData['art_name'], style: titleTextStyle),
        )
      ],
    );
    var timeRow = Row(
      children: <Widget>[
        Container(
          child: Text(
            itemData['final_price_format'],
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: Text(
            itemData['price_format'],
            style: TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 120,
                child: CommonButton(
                    height: 40,
                    text: "Group Coupon",
                    onTap: () => {
                          // getCouponCode(itemData['product_id'])
                        }),
              ),
            ],
          ),
        ),
      ],
    );
    var thumbImgUrl = itemData['image'];
    var thumbImg = Container(
      // margin: const EdgeInsets.all(10.0),
      width: 100.0,
      height: 80.0,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        // color: const Color(0xFFECECEC),
        image: DecorationImage(
            image: ExactAssetImage('./images/ic_img_default.jpg'),
            fit: BoxFit.cover),
        border: Border.all(
          color: const Color(0xFFECECEC),
          width: 0,
        ),
      ),
    );
    if (thumbImgUrl != null && thumbImgUrl.length > 0) {
      thumbImg = Container(
        // margin: const EdgeInsets.all(10.0),
        width: 100.0,
        height: 80.0,
        decoration: BoxDecoration(
          // shape: BoxShape.circle,
          // color: const Color(0xFFECECEC),
          image: DecorationImage(
              image: NetworkImage(thumbImgUrl), fit: BoxFit.cover),
          border: Border.all(
            color: const Color(0xFFECECEC),
            width: 0,
          ),
        ),
      );
    }
    var row = Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(0),
          child: Container(
            width: 100.0,
            height: 80.0,
            // color: const Color(0xFFECECEC),
            child: Center(
              child: thumbImg,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                titleRow,
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                  child: timeRow,
                )
              ],
            ),
          ),
        ),
      ],
    );
    return InkWell(
      child: row,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => NewsDetailPage(id: itemData['product_id'])));
      },
    );
  }
}
