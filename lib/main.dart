import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestoreRefs.dart';
import './canvasItems.dart';

// Put name list label on top of canvasItems and variable list items
// Ability to create new GameBoard or download existing one
// Variable dropdown should show first 5 letters of var ID and defaultValue
// Tap on CanvasItem to highlight which item
// Ability to edit exisitg canvas item or variable
// Fix drag and drop position is off by a bit
// Change x and y to slider
// Ability to load the app on the phone without edit options.

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
  Map<String, Map<String, dynamic>> _functions = Map();

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
          newCanvasItems.addCanvasItem(
              doc.documentID,
              CanvasItem.variable(doc.data['value'],
                  left: doc.data['left'].toDouble(),
                  top: doc.data['top'].toDouble()));
        } else if (doc.data['type'] == 'Button') {
          newCanvasItems.addCanvasItem(
              doc.documentID,
              CanvasItem.button(doc.data['value'],
                  name: doc.data['name'],
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
      Map<String, int> newInstantiatedVariables = Map();

      data.documents.forEach((doc) {
        newVariables.update(doc.documentID, (v) => doc.data,
            ifAbsent: () => doc.data);
        newInstantiatedVariables.update(doc.documentID, (v) => v,
            ifAbsent: () => doc.data['defaultValue'].round());
      });
      setState(() {
        _variables = newVariables;
        _instantiatedVariables = newInstantiatedVariables;
      });
    });
    getFunctionsCollection().snapshots().listen((data) {
      final newFunctions = Map<String, Map<String, dynamic>>();
      data.documents.forEach((doc) {
        newFunctions.update(doc.documentID, (v) => doc.data,
            ifAbsent: () => doc.data);
      });
      setState(() {
        _functions = newFunctions;
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
                children: _canvasItems.getPositionedList(
                    _instantiatedVariables, _btnOnPressed, _onDragEnd))),
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
                  ),
                  FlatButton(
                    color: Colors.amber,
                    onPressed: () {
                      _variables.forEach((key, value) {
                        _instantiatedVariables.update(
                            key, (v) => value['defaultValue']);
                      });
                      setState(() {});
                    },
                    child: Text('RESET',
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
                          ),
                          FlatButton(
                            color: Colors.teal,
                            onPressed: _showCreateVariableDialog,
                            child: Text('CREATE VARIABLE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          FlatButton(
                            color: Colors.orange,
                            onPressed: _showCreateButtonFunctionDialog,
                            child: Text('CREATE BUTTON FUNCTION',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ))),
              Container(
                  height: 300,
                  color: Colors.white,
                  child:
                      getVariableListView(_variables, _instantiatedVariables))
            ],
          ),
        ),
      ])),
    ));
  }

  _onDragEnd(String key, double x, double y) {
    getCanvasItemDocument(canvasItemId: key).updateData({'left': x, 'top': y});
  }

  _btnOnPressed(String functionKey) {
    final targetVariableId = _functions[functionKey]['targetVariable'];
    final variable1Id = _functions[functionKey]['variable1'];
    final variable2Id = _functions[functionKey]['variable2'];
    final arithmetic = _functions[functionKey]['arithmetic'];

    final variable1Value = _instantiatedVariables[variable1Id];
    final variable2Value = _instantiatedVariables[variable2Id];
    if (variable1Value == null ||
        variable2Value == null ||
        arithmetic == null) {
      print('variable doesnt exist or has been instantiated yet');
      return;
    }

    var finalValue;
    switch (arithmetic) {
      case '+':
        finalValue = variable1Value + variable2Value;
        break;
      case '-':
        finalValue = variable1Value - variable2Value;
        break;
      case '*':
        finalValue = variable1Value * variable2Value;
        break;
      case '/':
        finalValue = variable1Value / variable2Value;
        break;
    }
    if (finalValue == null) {
      print(finalValue);
      return;
    }
    _instantiatedVariables[targetVariableId] = finalValue;
    setState(() {});
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

  _createVariable(int defaultValue) {
    getVariablesCollection().add({'defaultValue': defaultValue});
  }

  Future<void> _showAddTextDialog() async {
    final nameTextFieldController = TextEditingController();
    final topTextFieldController = TextEditingController(text: '0');
    final leftTextFieldController = TextEditingController(text: '0');

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
    final topTextFieldController = TextEditingController(text: '0');
    final leftTextFieldController = TextEditingController(text: '0');
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
                        value: key,
                        child: Text(
                            '${key.substring(4, 9)} (default: ${_variables[key]['defaultValue']})'));
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
                  autofocus: true,
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
              child: Text('Create'),
              onPressed: () {
                _createVariable(
                    int.parse(defaultValueTextFieldController.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateButtonFunctionDialog() async {
    final nameTextFieldController = TextEditingController();
    final topTextFieldController = TextEditingController(text: '0');
    final leftTextFieldController = TextEditingController(text: '0');
    String _selectedTargetVariableId;
    String _selectedVariable1Id;
    String _selectedVariable2Id;
    String _selectedArithmetic;
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      TextField(
                        autofocus: true,
                        controller: nameTextFieldController,
                        decoration: InputDecoration(labelText: "Name"),
                      ),
                      DropdownButton<String>(
                          hint: new Text("Select a Target Variable"),
                          value: _selectedTargetVariableId,
                          onChanged: (String newValue) {
                            setState(() {
                              _selectedTargetVariableId = newValue;
                            });
                          },
                          items: _variables.keys.map((key) {
                            return DropdownMenuItem<String>(
                                value: key,
                                child: Text(
                                    '${key.substring(4, 9)} (default: ${_variables[key]['defaultValue']})'));
                          }).toList()),
                      DropdownButton<String>(
                          hint: new Text("Select a Variable1"),
                          value: _selectedVariable1Id,
                          onChanged: (String newValue) {
                            setState(() {
                              _selectedVariable1Id = newValue;
                            });
                          },
                          items: _variables.keys.map((key) {
                            return DropdownMenuItem<String>(
                                value: key,
                                child: Text(
                                    '${key.substring(4, 9)} (default: ${_variables[key]['defaultValue']})'));
                          }).toList()),
                      DropdownButton<String>(
                          hint: new Text("Select an Arithmetic"),
                          value: _selectedArithmetic,
                          onChanged: (String newValue) {
                            setState(() {
                              _selectedArithmetic = newValue;
                            });
                          },
                          items: ['+', '-', '*', '/']
                              .map((key) => DropdownMenuItem<String>(
                                  value: key, child: Text(key)))
                              .toList()),
                      DropdownButton<String>(
                          hint: new Text("Select a Variable2"),
                          value: _selectedVariable2Id,
                          onChanged: (String newValue) {
                            setState(() {
                              _selectedVariable2Id = newValue;
                            });
                          },
                          items: _variables.keys.map((key) {
                            return DropdownMenuItem<String>(
                                value: key,
                                child: Text(
                                    '${key.substring(4, 9)} (default: ${_variables[key]['defaultValue']})'));
                          }).toList()),
                      TextField(
                        controller: leftTextFieldController,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        decoration: InputDecoration(labelText: "X"),
                      ),
                      TextField(
                        controller: topTextFieldController,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        decoration: InputDecoration(labelText: "Y"),
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
                    child: Text('Create'),
                    onPressed: () {
                      getFunctionsCollection().add({
                        'arithmetic': _selectedArithmetic,
                        'targetVariable': _selectedTargetVariableId,
                        'variable1': _selectedVariable1Id,
                        'variable2': _selectedVariable2Id,
                      }).then((docRef) {
                        getCanvasItemsCollection().add({
                          'name': nameTextFieldController.text,
                          'left': double.parse(leftTextFieldController.text),
                          'top': double.parse(topTextFieldController.text),
                          'type': 'Button',
                          'value': docRef.documentID
                        });
                      });
                      // _createButtonFunction(
                      //     int.parse(defaultValueTextFieldController.text));
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}

getCanvasItemListView(
    CanvasItems canvasItems, Map<String, int> _instantiatedVariables) {
  return ListView(
      children: canvasItems.canvasItemMap.keys.map((key) {
    final canvasItem = canvasItems.canvasItemMap[key];
    var name;
    switch (canvasItem.type) {
      case CanvasItemType.Text:
        name = 'Text: ' + canvasItem.value;
        break;
      case CanvasItemType.Button:
        name = 'Button: ' + canvasItem.value.substring(4, 9);
        break;
      case CanvasItemType.Variable:
        name =
            'Variable: ${canvasItem.value.substring(4, 9)} (now: ${_instantiatedVariables[canvasItem.value]})';
        break;
      case CanvasItemType.Image:
        break;
    }
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name),
            MaterialButton(
              height: 50.0,
              minWidth: 50.0,
              onPressed: getCanvasItemDocument(canvasItemId: key).delete,
              child: Text('X'),
            )
          ])),
      Divider(height: 4)
    ]));
  }).toList());
}

getVariableListView(
    Map<String, Map<String, dynamic>> variables, _instantiatedVariables) {
  return ListView(
      children: variables.keys.map((key) {
    final defaultValue = variables[key]['defaultValue'];
    final instantiatedValue = _instantiatedVariables[key].toString();

    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                '${key.substring(4, 9)} (default: $defaultValue, now: $instantiatedValue)'
                //  + ': (' + instantiatedValue + ')',
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
