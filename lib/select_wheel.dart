import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnValue = void Function(num value);

class SelectWheel extends StatefulWidget {
  final String label;
  final num step;
  final num initialValue;
  final OnValue onValue;
  final bool negativeValues;

  SelectWheel({
    Key key,
    this.initialValue = 0,
    this.step = 5,
    this.label = 'min',
    this.onValue = print,
    this.negativeValues = false,
  }) : super(key: key);

  @override
  _SelectWheelState createState() => _SelectWheelState();
}

class _SelectWheelState extends State<SelectWheel> {
  final ScrollController _scrollController = ScrollController();

  int value = 0;

  @override
  void initState() {
    value = widget.initialValue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      int newValue = (_scrollController.position.pixels / 35).round();
      if ((newValue >= 0 || widget.negativeValues) && newValue != value) {
        HapticFeedback.lightImpact();
        widget.onValue(value = newValue);
      }
    });
    return ListWheelScrollView.useDelegate(
      itemExtent: 35,
      magnification: 5,
      clipBehavior: Clip.hardEdge,
      diameterRatio: 2.5,
      perspective: 0.008,
      controller: _scrollController,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (BuildContext context, int i) =>
            (widget.negativeValues || i >= 0)
                ? Container(
                    child: Center(
                      child: Text('${i * widget.step}${widget.label}'),
                    ),
                    width: 120,
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                  )
                : null,
      ),
    );
  }
}
