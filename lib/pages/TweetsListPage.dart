import 'package:flutter/material.dart';
import '../pages/NewsListPageSearch.dart';

class TweetsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TweetsListPageState();
  }
}

class TweetsListPageState extends State<TweetsListPage> {
  final List<String> entries = <String>[
    'Jewelry',
    'Kitchen & Dining',
    'Men\'s Clothing & Shoes',
    'Pet Supplies',
    'Sports & Outdoors',
    'Toys, kids & Baby',
    'Watches',
    'Women\'s Clothing & Shoes',
    'Adult Products',
    'Other'
  ];
  final List<int> colorCodes = <int>[600, 500, 100];

  Widget getNormalListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: Container(
              height: 56,
              color: Colors.white,
              child: Center(child: Text('${entries[index]}'))),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => NewsListPageSearch()));
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: Text('Shop By Deparment'),
      ),
      body: getNormalListView(),
    );
  }
}
