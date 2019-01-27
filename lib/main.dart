import 'package:flutter/material.dart';
// import 'package:english_words/english_words.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

main() {
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyStateApp createState() => MyStateApp();
}

const GAME_ID = 'Gv3sMVfwTtQr66XaP9vr';

CollectionReference getGamesCollection() =>
    Firestore.instance.collection('Games');
DocumentReference getGameDocument({String gameId = GAME_ID}) =>
    Firestore.instance.collection('Games').document(gameId);
CollectionReference getCanvasItemsCollection({String gameId = GAME_ID}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('CanvasItems');
DocumentReference getCanvasItemDocument(
        {String gameId = GAME_ID, String canvasItemId}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('CanvasItems')
        .document(canvasItemId);

CollectionReference getVariablesCollection({String gameId = GAME_ID}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('Variables');

DocumentReference getVariableDocument(
        {String gameId = GAME_ID, String variableId}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('Variables')
        .document(variableId);

class MyStateApp extends State {
  var _canvasItems = CanvasItems();
  Map<String, Map<String, dynamic>> _variables = Map();

  MyStateApp() {
    getCanvasItemsCollection().snapshots().listen((data) {
      final newCanvasItems = CanvasItems();
      data.documents.forEach((doc) {
        if (doc.data['type'] == 'Text') {
          newCanvasItems.addCanvasItem(
              doc.documentID,
              CanvasItem.text(doc.data['value'],
                  left: doc.data['left'].toDouble(),
                  top: doc.data['top'].toDouble()));
        }
      });
      setState(() {
        _canvasItems = newCanvasItems;
      });
    });
    getVariablesCollection().snapshots().listen((data) {
      final newVariables = Map<String, Map<String, dynamic>>();
      data.documents.forEach((doc) {
        newVariables.update(doc.documentID, (v) => doc.data,
            ifAbsent: () => doc.data);
      });
      setState(() {
        _variables = newVariables;
      });
    });
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
          child: Row(children: [
        Expanded(child: Stack(children: _canvasItems.getPositionedList())),
        Container(
            width: 300,
            // padding: EdgeInsets.all(10),
            color: Colors.yellow,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: getCanvasItemListView(_canvasItems)),
                  FlatButton(
                    color: Colors.redAccent,
                    onPressed: () {
                      _canvasItems.getKeyTextList().forEach((key) {
                        getCanvasItemsCollection().document(key.data).delete();
                      });
                    },
                    child: Text('CLEAR ALL',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ])),
        Container(
          width: 300,
          color: Colors.grey,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      color: Colors.lightBlueAccent,
                      padding: EdgeInsets.all(10),
                      child: ListView(
                        children: [
                          FlatButton(
                            color: Colors.cyan,
                            onPressed: _showAddTextDialog,
                            child: Text('ADD TEXT',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          FlatButton(
                            color: Colors.blueAccent,
                            onPressed: _showAddVariableDialog,
                            child: Text('ADD VARIABLE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ))),
              Container(
                  height: 300,
                  color: Colors.white,
                  child: getVariableListView(_variables))
            ],
          ),
        ),
      ])),
    ));
  }

  _addText(String text,
      {double top, double bottom, double left, double right}) {
    final canvasItemsCollection = getCanvasItemsCollection();
    canvasItemsCollection
        .add({'left': left, 'top': top, 'type': 'Text', 'value': text});
  }

  _addVariable(String variableKey,
      {double top, double bottom, double left, double right}) {
    final canvasItemsCollection = getCanvasItemsCollection();
    canvasItemsCollection.add(
        {'left': left, 'top': top, 'type': 'Variable', 'value': variableKey});
  }

  Future<void> _showAddTextDialog() async {
    final nameTextFieldController = TextEditingController();
    final topTextFieldController = TextEditingController();
    final leftTextFieldController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  autofocus: true,
                  controller: nameTextFieldController,
                  decoration: InputDecoration(labelText: "Text"),
                ),
                TextField(
                  controller: leftTextFieldController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  decoration: InputDecoration(labelText: "x"),
                ),
                TextField(
                  controller: topTextFieldController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  decoration: InputDecoration(labelText: "y"),
                )
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: Navigator.of(context).pop,
              textColor: Colors.grey,
            ),
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                _addText(nameTextFieldController.text,
                    top: double.parse(topTextFieldController.text),
                    left: double.parse(leftTextFieldController.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddVariableDialog() async {
    final defaultValueTextFieldController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: defaultValueTextFieldController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  decoration: InputDecoration(labelText: "Default Value"),
                ),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: Navigator.of(context).pop,
              textColor: Colors.grey,
            ),
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                _addVariable(defaultValueTextFieldController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateVariableDialog() async {
    final defaultValueTextFieldController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: defaultValueTextFieldController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  decoration: InputDecoration(labelText: "Default Value"),
                ),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: Navigator.of(context).pop,
              textColor: Colors.grey,
            ),
            FlatButton(
              child: Text('Add'),
              onPressed: () {
                _addVariable(defaultValueTextFieldController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

getCanvasItemListView(CanvasItems canvasItems) {
  return ListView(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      children: canvasItems.canvasItemMap.keys
          .map((key) => Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key,
                              ),
                              RawMaterialButton(
                                onPressed:
                                    getCanvasItemDocument(canvasItemId: key)
                                        .delete,
                                child: Text('X'),
                              )
                            ])),
                    Divider()
                  ])))
          .toList());
}

getVariableListView(Map<String, Map<String, dynamic>> variables) {
  print(variables);
  return ListView(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      children: variables.keys.map((key) {
        return Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      key,
                    ),
                    RawMaterialButton(
                      onPressed: getVariableDocument(variableId: key).delete,
                      child: Text('X'),
                    )
                  ])),
          Divider()
        ]));
      }).toList());
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

  void addCanvasItem(String key, CanvasItem item) {
    canvasItemMap.update(key, (v) => item, ifAbsent: () => item);
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
