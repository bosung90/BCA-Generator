import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/widgets.dart';

main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyStateApp createState() => MyStateApp();
}

class MyStateApp extends State {
  var _value = 'Hello World';

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
          child: Row(children: [
        Expanded(
            child: Stack(children: [
          Positioned(
              top: 0,
              left: 200,
              // right: 0,
              child: Container(color: Colors.red, child: Text('hello')))
        ])),
        Container(
            width: 300,
            color: Colors.grey,
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(_value),
                  FlatButton(
                    color: Colors.cyan,
                    onPressed: () {
                      setState(() {
                        _value = DateTime.now().toString();
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
