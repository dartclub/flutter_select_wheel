import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ItemScrollPhysics from here: https://github.com/icemanbsi/flutter_time_picker_spinner/blob/f1345e0d06937238ca17be3cb636e54f4efcacd1/lib/flutter_time_picker_spinner.dart#L6
class _ItemScrollPhysics extends ScrollPhysics {
  final double itemHeight;
  final double targetPixelsLimit;

  const _ItemScrollPhysics({
    ScrollPhysics parent,
    @required this.itemHeight,
    this.targetPixelsLimit = 3.0,
  })  : assert(itemHeight != null && itemHeight > 0),
        super(parent: parent);

  @override
  _ItemScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _ItemScrollPhysics(
        parent: buildParent(ancestor), itemHeight: itemHeight);
  }

  double _getItem(ScrollPosition position) {
    double maxScrollItem =
        (position.maxScrollExtent / itemHeight).floorToDouble();
    return min(max(0, position.pixels / itemHeight), maxScrollItem);
  }

  double _getPixels(ScrollPosition position, double item) {
    return item * itemHeight;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double item = _getItem(position);
    if (velocity < -tolerance.velocity) {
      item -= targetPixelsLimit;
    } else if (velocity > tolerance.velocity) item += targetPixelsLimit;
    return _getPixels(position, item.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

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

  _listener() {
    int newValue = (_scrollController.position.pixels / 35).round();
    if ((newValue >= 0 || widget.negativeValues) && newValue != value) {
      HapticFeedback.lightImpact();
      widget.onValue(value = newValue);
    }
  }

  @override
  void initState() {
    value = widget.initialValue;

    super.initState();
  }

  @override
  void didUpdateWidget(SelectWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.jumpTo(35.0 * widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.removeListener(_listener);
    _scrollController.addListener(_listener);
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 120,
            height: 35 * 1.5,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
                top: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
          ),
        ),
        ListWheelScrollView.useDelegate(
          physics: _ItemScrollPhysics(itemHeight: 35),
          itemExtent: 35,
          magnification: 1.5,
          useMagnifier: true,
          clipBehavior: Clip.antiAlias,
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
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
