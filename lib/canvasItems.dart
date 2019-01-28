import 'package:flutter/material.dart';

class CanvasItems {
  final canvasItemMap = Map<String, CanvasItem>();

  List getPositionedList(
      Map<String, int> _instantiatedVariables, btnOnPressed, onDragEnd) {
    List<Positioned> positionedList = [];
    canvasItemMap.keys.forEach((key) {
      final item = canvasItemMap[key];
      switch (item.type) {
        case CanvasItemType.Text:
          positionedList.add(Positioned(
            top: item.position['top'],
            left: item.position['left'],
            right: item.position['right'],
            bottom: item.position['bottom'],
            child: Draggable(
                child: Text(item.value),
                feedback: Text(item.value,
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        decoration: TextDecoration.none)),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  onDragEnd(key, details.offset.dx, details.offset.dy);
                }),
          ));
          break;
        case CanvasItemType.Variable:
          positionedList.add(Positioned(
            top: item.position['top'],
            left: item.position['left'],
            right: item.position['right'],
            bottom: item.position['bottom'],
            child: Draggable(
                child: Text(_instantiatedVariables[item.value].toString()),
                feedback: Text(_instantiatedVariables[item.value].toString(),
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        decoration: TextDecoration.none)),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  onDragEnd(key, details.offset.dx, details.offset.dy);
                }),
          ));
          break;
        case CanvasItemType.Button:
          positionedList.add(Positioned(
            top: item.position['top'],
            left: item.position['left'],
            right: item.position['right'],
            bottom: item.position['bottom'],
            child: Draggable(
                child: MaterialButton(
                    color: Colors.grey,
                    onPressed: () {
                      btnOnPressed(item.value);
                    },
                    child: Text(item.name != null ? item.name : 'Button')),
                feedback: MaterialButton(
                    color: Colors.grey,
                    onPressed: () {
                      btnOnPressed(item.value);
                    },
                    child: Text(item.name != null ? item.name : 'Button')),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  onDragEnd(key, details.offset.dx, details.offset.dy);
                }),
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
  var name;

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
      {double top, double bottom, double left, double right, String name}) {
    this.value = functionKey;
    this.name = name;
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
