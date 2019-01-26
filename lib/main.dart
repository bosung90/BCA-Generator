import 'package:flutter/material.dart';
// import 'package:english_words/english_words.dart';
// import 'package:flutter/widgets.dart';

main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyStateApp createState() => MyStateApp();
}

class MyStateApp extends State {
  final canvasItems = CanvasItems();

  MyStateApp() {
    _addText('one', top: 20);
    _addText('two', top: 40);
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
          child: Row(children: [
        Expanded(child: Stack(children: canvasItems.getPositionedList())),
        Container(
            width: 300,
            color: Colors.grey,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      FlatButton(
                        color: Colors.cyan,
                        onPressed: () {
                          setState(() {
                            _addText('three', top: 60);
                          });
                        },
                        child: Text('Add Text'),
                      )
                    ],
                  )),
                  Container(
                      height: 300,
                      color: Colors.white,
                      child: ListView(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          children: canvasItems.canvasItemMap.keys
                              .map((key) => Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Container(
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    key,
                                                  ),
                                                  RawMaterialButton(
                                                    onPressed: () => null,
                                                    child: Text('Edit'),
                                                  )
                                                ])),
                                        Divider()
                                      ])))
                              .toList()))
                ],
              ),
            )),
      ])),
    ));
  }

  _addText(String text,
      {double top, double bottom, double left, double right}) {
    final canvasItem = CanvasItem.text(text,
        top: top, bottom: bottom, left: left, right: right);
    canvasItems.addCanvasItem(canvasItem);
  }
}

class CanvasItems {
  final canvasItemMap = Map<String, CanvasItem>();
  var uuidCounter = 0;

  List getPositionedList() {
    List<Positioned> positionedList = [];
    canvasItemMap.values.forEach((item) => positionedList.add(item.positioned));
    return positionedList;
  }

  List getKeyTextList() {
    List<Widget> widgets = [];
    canvasItemMap.keys.forEach((key) => widgets.add(Text(key)));
    return widgets;
  }

  addCanvasItem(CanvasItem item) {
    final canvasItemKey = (uuidCounter++).toString();
    canvasItemMap.update(canvasItemKey, (v) => item, ifAbsent: () => item);
  }
}

enum CanvasItemType { Text, Image, Variable }

class CanvasItem {
  Positioned positioned;
  CanvasItemType type;
  var value;

  CanvasItem.text(String text,
      {double top, double bottom, double left, double right}) {
    this.value = text;
    this.positioned = Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Text(this.value));
    this.type = CanvasItemType.Text;
  }

  editCanvasItem(BuildContext context) {
    showDialog(context: context);
  }
}

// class RandomWordsState extends State<RandomWords> {
//   final _suggestions = <WordPair>[];
//   final _biggerFont = const TextStyle(fontSize: 18.0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Startup Name Generator'),
//       ),
//       body: _buildSuggestions(),
//     );
//   }

//   Widget _buildSuggestions() {
//     return ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         itemBuilder: /*1*/ (context, i) {
//           if (i.isOdd) return Divider(); /*2*/

//           final index = i ~/ 2; /*3*/
//           if (index >= _suggestions.length) {
//             _suggestions.addAll(generateWordPairs().take(10)); /*4*/
//           }
//           return _buildRow(_suggestions[index]);
//         });
//   }

//   Widget _buildRow(WordPair pair) {
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//     );
//   }
// }

// class RandomWords extends StatefulWidget {
//   @override
//   RandomWordsState createState() => RandomWordsState();
// }
