import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestoreRefs.dart';
import './canvasItems.dart';

// 1. When Variable is added, create stateValue with defaultValue
// 2. When rendering Variable on Canvas, print stateValue
// 3. Ability to Create new Variable with defaultValue
// 4. CanvasItemList show value for Text, and id for variable

main() {
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyStateApp createState() => MyStateApp();
}

class MyStateApp extends State {
  var _canvasItems = CanvasItems();
  Map<String, Map<String, dynamic>> _variables = Map();
  Map<String, int> _instantiatedVariables = Map();

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
        } else if (doc.data['type'] == 'Variable') {
          getVariableDocument(variableId: doc.data['value'])
              .get()
              .then((onValue) {
            _instantiatedVariables.update(doc.data['value'], (v) => v,
                ifAbsent: () => onValue.data['defaultValue'].round());
            setState(() {});
          });
          newCanvasItems.addCanvasItem(
              doc.documentID,
              CanvasItem.variable(doc.data['value'],
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
        Expanded(
            child: Stack(
                children:
                    _canvasItems.getPositionedList(_instantiatedVariables))),
        Container(
            width: 300,
            color: Colors.yellow,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: getCanvasItemListView(
                          _canvasItems, _instantiatedVariables)),
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
    final topTextFieldController = TextEditingController();
    final leftTextFieldController = TextEditingController();
    String _selectedVariableId;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: ListBody(children: [
              DropdownButton<String>(
                  hint: new Text("Select a Variable"),
                  value: _selectedVariableId,
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedVariableId = newValue;
                    });
                  },
                  items: _variables.keys.map((key) {
                    return DropdownMenuItem<String>(
                        value: key, child: Text(key));
                  }).toList()),
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
            ])),
            actions: [
              FlatButton(
                child: Text('Cancel'),
                onPressed: Navigator.of(context).pop,
                textColor: Colors.grey,
              ),
              FlatButton(
                child: Text('Add'),
                onPressed: () {
                  if (_selectedVariableId != null) {
                    _addVariable(_selectedVariableId,
                        top: double.parse(topTextFieldController.text),
                        left: double.parse(leftTextFieldController.text));
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
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

getCanvasItemListView(
    CanvasItems canvasItems, Map<String, int> _instantiatedVariables) {
  return ListView(
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
                              Text(key),
                              MaterialButton(
                                height: 50.0,
                                minWidth: 50.0,
                                onPressed:
                                    getCanvasItemDocument(canvasItemId: key)
                                        .delete,
                                child: Text('X'),
                              )
                            ])),
                    Divider(height: 4)
                  ])))
          .toList());
}

getVariableListView(Map<String, Map<String, dynamic>> variables) {
  return ListView(
      children: variables.keys.map((key) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              key,
            ),
            MaterialButton(
              height: 50.0,
              minWidth: 50.0,
              onPressed: getVariableDocument(variableId: key).delete,
              child: Text('X'),
            )
          ])),
      Divider(height: 4)
    ]));
  }).toList());
}
