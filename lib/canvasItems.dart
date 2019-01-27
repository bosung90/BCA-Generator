import 'package:flutter/material.dart';

class CanvasItems {
  final canvasItemMap = Map<String, CanvasItem>();

  List getPositionedList(Map<String, int> _instantiatedVariables) {
    List<Positioned> positionedList = [];
    canvasItemMap.values.forEach((item) {
      switch (item.type) {
        case CanvasItemType.Text:
          positionedList.add(Positioned(
            top: item.position['top'],
            left: item.position['left'],
            right: item.position['right'],
            bottom: item.position['bottom'],
            child: Text(item.value),
          ));
          break;
        case CanvasItemType.Variable:
          positionedList.add(Positioned(
            top: item.position['top'],
            left: item.position['left'],
            right: item.position['right'],
            bottom: item.position['bottom'],
            child: Text(_instantiatedVariables[item.value].toString()),
          ));
          break;
        case CanvasItemType.Button:
          positionedList.add(Positioned(
            top: item.position['top'],
            left: item.position['left'],
            right: item.position['right'],
            bottom: item.position['bottom'],
            child: MaterialButton(onPressed: () {}, child: Text('B')),
          ));
          break;
        default:
          break;
      }
    });
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

enum CanvasItemType { Text, Image, Variable, Button }

class CanvasItem {
  Map<String, double> position = Map();
  CanvasItemType type;
  var value;

  CanvasItem.variable(String variableKey,
      {double top, double bottom, double left, double right}) {
    this.value = variableKey;
    this.position = {
      'top': top,
      'bottom': bottom,
      'left': left,
      'right': right
    };
    this.type = CanvasItemType.Variable;
  }

  CanvasItem.button(String functionKey,
      {double top, double bottom, double left, double right}) {
    this.value = functionKey;
    this.position = {
      'top': top,
      'bottom': bottom,
      'left': left,
      'right': right
    };
    this.type = CanvasItemType.Button;
  }

  CanvasItem.text(String text,
      {double top, double bottom, double left, double right}) {
    this.value = text;
    this.position = {
      'top': top,
      'bottom': bottom,
      'left': left,
      'right': right
    };
    this.type = CanvasItemType.Text;
  }

  editCanvasItem(BuildContext context) {
    showDialog(context: context);
  }
}
