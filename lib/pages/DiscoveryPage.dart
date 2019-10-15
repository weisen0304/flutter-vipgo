import 'package:flutter/material.dart';
import 'dart:convert';
import '../api/Api.dart';
import '../util/NetUtils.dart';
import '../pages/ProductDetailPage.dart';

class DiscoveryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DiscoveryPageState();
}

class DiscoveryPageState extends State<DiscoveryPage> {
  static const String TAG_START = "startDivider";
  static const String TAG_END = "endDivider";
  static const String TAG_CENTER = "centerDivider";
  static const String TAG_BLANK = "blankDivider";

  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var listData;
  var curPage = 1;
  var listTotalSize = 0;
  final rightArrowIcon = Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );
  final titleTextStyle = TextStyle(fontSize: 16.0);

  @override
  void initState() {
    super.initState();
    getArticlesList(false);
  }

  // 从网络获取数据，isLoadMore表示是否是加载更多数据
  getArticlesList(bool isLoadMore) {
    String url = Api.articlesList;
    url += "?pageIndex=$curPage&pageSize=10";
    NetUtils.get(url).then((data) {
      if (data != null) {
        // 将接口返回的json字符串解析为map类型
        Map<String, dynamic> map = json.decode(data);
        print(map['code'] == 200);
        if (map['code'] == 200) {
          // code=0表示请求成功
          // var msg = map['msg'];
          // total表示资讯总条数
          listTotalSize = map['data'].length;
          print(listTotalSize);
          // data为数据内容，其中包含slide和news两部分，分别表示头部轮播图数据，和下面的列表数据
          var _listData = map['data'];
          setState(() {
            if (!isLoadMore) {
              // 不是加载更多，则直接为变量赋值
              listData = _listData;
            }
          });
        }
      }
    });
  }

  renderRow(BuildContext ctx, int i) {
    if (listData != null) {
      var item = listData[i];
      var thumbImgUrl = item['image_big'];
      var thumbImg = Container(
        // margin: const EdgeInsets.all(10.0),
        width: 280.0,
        height: 180.0,
        decoration: BoxDecoration(
          // shape: BoxShape.circle,
          // color: const Color(0xFFECECEC),
          image: DecorationImage(
              image: NetworkImage(thumbImgUrl), fit: BoxFit.contain),
          border: Border.all(
            color: const Color(0xFFECECEC),
            width: 0,
          ),
        ),
      );
      var listItemContent = Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: Column(
          children: <Widget>[
            Text(
              item['page_title'],
              style: titleTextStyle,
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 32.0),
                child: thumbImg),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 10.0),
              child: Row(
                children: <Widget>[
                  Text(item['publish_time'],
                      style:
                          TextStyle(fontSize: 13.0, color: Color(0xFFCDCDCD))),
                  Container(
                    width: 10,
                  ),
                  new Icon(Icons.remove_red_eye,
                      size: 16, color: Color(0xFFCDCDCD)),
                  Container(
                    width: 10,
                  ),
                  Text(item['read_count'],
                      style:
                          TextStyle(fontSize: 13.0, color: Color(0xFFCDCDCD))),
                ],
              ),
            ),
            Container(
              height: 12,
              color: Color(0xFFEFEFEF),
            )
          ],
        ),
      );
      return InkWell(
        onTap: () {
          print(item['artcle_url']);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => ProductDetailPage(
                    prodLink: item['article_url'],
                  )));
        },
        child: listItemContent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: Text('Discovery')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, i) => renderRow(context, i),
        ),
      ),
    );
  }
}
