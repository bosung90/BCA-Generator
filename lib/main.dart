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
  var canvasItemMap = Map<String, Widget>();

  MyStateApp() {
    _addText('one', top: 20);
    _addText('two', top: 40);
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
          child: Row(children: [
        Expanded(child: Stack(children: canvasItemMap.values.toList())),
        Container(
            width: 300,
            color: Colors.grey,
            child: Center(
              child: Column(
                children: [
                  FlatButton(
                    color: Colors.cyan,
                    onPressed: () {
                      setState(() {
                        _addText('three', top: 60);
                      });
                    },
                    child: Text('Button'),
                  ),
                ],
              ),
            )),
      ])),
    ));
  }

  _addText(String text,
      {String key, double top, double bottom, double left, double right}) {
    var canvasItemMapKey =
        key == null ? DateTime.now().millisecondsSinceEpoch.toString() : key;
    var positionedTextWidget = Positioned(
        top: top, bottom: bottom, left: left, right: right, child: Text(text));
    canvasItemMap.update(canvasItemMapKey, (v) => positionedTextWidget,
        ifAbsent: () => positionedTextWidget);
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
