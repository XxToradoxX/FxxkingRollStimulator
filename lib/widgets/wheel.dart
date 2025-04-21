import 'package:flutter/material.dart';
import 'dart:math';
import '../../model/wheel_item.dart';

class Wheel extends StatefulWidget {
  final List<WheelItem> items;
  final void Function(int resultIndex)? onSpinComplete;

  const Wheel({Key? key, required this.items, this.onSpinComplete}) : super(key: key);

  @override
  _WheelState createState() => _WheelState();
}

class _WheelState extends State<Wheel> with SingleTickerProviderStateMixin {
  late AnimationController _angleController;
  late Animation<double> _angleAnimation;
  double _angle = 0.0;
  double _prizeResult = 0.0;
  final List<double> _cumulativeRatios = [];
  double _totalRatio = 0.0;
  final List<double> _itemAngles = [];
  bool _showResult = false;
  int? _resultIndex;

  @override
  void initState() {
    super.initState();
    _angleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      upperBound: 1.0,
      lowerBound: 0.0,
    );
    _angleAnimation = CurvedAnimation(
      parent: _angleController,
      curve: Curves.easeOutCirc,
    )..addListener(() {
        if (mounted) {
          setState(() {
            _angle = _angleAnimation.value * 12;
          });
        }
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _showResult = true;
          _resultIndex = _getPrizeIndexByRandom();
          print('中奖索引: $_resultIndex');
          print('中奖名称: ${widget.items[_resultIndex!].name}');
          widget.onSpinComplete?.call(_resultIndex!);
          setState(() {});
        }
      });

    for (var item in widget.items) {
      _totalRatio += item.ratio;
      _cumulativeRatios.add(_totalRatio);
    }

    double startAngle = 0.0;
    for (int i = 0; i < widget.items.length; i++) {
      double endAngle = (widget.items[i].ratio / _totalRatio) * 2 * pi;
      _itemAngles.add(endAngle - startAngle);
      startAngle = endAngle;
    }
  }

  void spin() {
    _showResult = false;
    _resultIndex = null;
    setState(() {});

    _prizeResult = Random().nextDouble();
    print('随机值: $_prizeResult');
    _angleController.forward(from: 0);
  }

  int? _getPrizeIndexByRandom() {
    double random = _prizeResult;
    for (int i = 0; i < widget.items.length; i++) {
      if (random <= _cumulativeRatios[i] / _totalRatio) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Transform.rotate(
            angle: _angle * 2 * pi - _prizeResultPi,
            child: CustomPaint(
              size: const Size(300, 300),
              painter: WheelPainter(
                items: widget.items,
                cumulativeRatios: _cumulativeRatios,
                totalRatio: _totalRatio,
                showResult: _showResult,
                resultIndex: _resultIndex,
              ),
            ),
          ),
          Positioned(
            child: GestureDetector(
              onTap: spin,
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'GO',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (_showResult && _resultIndex != null)
            Positioned(
              top: -100,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _prizeResultPi {
    return _prizeResult * 2 * pi;
  }

  @override
  void dispose() {
    _angleController.dispose();
    super.dispose();
  }
}

class WheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final List<double> cumulativeRatios;
  final double totalRatio;
  final bool showResult;
  final int? resultIndex;

  WheelPainter({
    required this.items,
    required this.cumulativeRatios,
    required this.totalRatio,
    required this.showResult,
    required this.resultIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    double startAngle = 0.0;

    for (int i = 0; i < items.length; i++) {
      double endAngle = (cumulativeRatios[i] / totalRatio) * 2 * pi;
      paint.color = items[i].color;
      canvas.drawArc(rect, startAngle - (pi / 2), endAngle - startAngle, true, paint);
      startAngle = endAngle;
    }

    startAngle = 0.0;
    for (int i = 0; i < items.length; i++) {
      double endAngle = (cumulativeRatios[i] / totalRatio) * 2 * pi;
      canvas.save();
      double acStartAngles = startAngle - (pi / 2);
      double acEndAngles = endAngle - (pi / 2);
      double roaAngle = acStartAngles / 2 + acEndAngles / 2 + pi;

      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(roaAngle);

      TextSpan span = TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
          shadows: [
            Shadow(
              color: Color(0x80000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        text: items[i].name,
      );

      TextPainter tp = _getTextPainter(span, size, endAngle - startAngle);
      tp.paint(canvas, Offset(-size.width / 2 + 20, 0 - (tp.height / 2)));

      // if (showResult && resultIndex == i) {
      //   paint.color = Colors.red;
      //   paint.style = PaintingStyle.fill;

      //   Path arrowPath = Path();
      //   arrowPath.moveTo(0, -20);
      //   arrowPath.lineTo(-10, 10);
      //   arrowPath.lineTo(0, 5);
      //   arrowPath.lineTo(10, 10);
      //   arrowPath.close();

      //   canvas.drawPath(arrowPath, paint);
      // }

      canvas.restore();
      startAngle = endAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is WheelPainter &&
           (oldDelegate.items != items ||
            oldDelegate.cumulativeRatios != cumulativeRatios ||
            oldDelegate.totalRatio != totalRatio ||
            oldDelegate.showResult != showResult ||
            oldDelegate.resultIndex != resultIndex);
  }

  double maxHeight(Size size, double angle) {
    final double radius = size.width / 2;
    var maxHeight = radius * 2 * sin(angle / 2);
    maxHeight = maxHeight * 0.75;
    return maxHeight;
  }

  TextPainter _getTextPainter(TextSpan span, Size size, double angle) {
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    );
    tp.layout(minWidth: size.width / 4, maxWidth: size.width / 4);
    if (tp.height > maxHeight(size, angle)) {
      var temSpan = TextSpan(
        style: span.style!.copyWith(fontSize: span.style!.fontSize! - 1.0),
        text: span.text,
      );
      tp = _getTextPainter(temSpan, size, angle);
    }
    return tp;
  }
}