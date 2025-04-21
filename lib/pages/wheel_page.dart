import 'package:flutter/material.dart';
import '../../widgets/wheel.dart';
import '../../model/wheel_item.dart';

class WheelPage extends StatefulWidget {
  final List<WheelItem> items;
  final String title; // 转盘标题

  const WheelPage({Key? key, required this.items, required this.title}) : super(key: key);

  @override
  _WheelPageState createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage> {
  String? _resultText; // 用于存储中奖结果
  bool _showResult = false; // 标记是否显示结果

  // 在旋转结束后显示结果
  void _onSpinComplete(int resultIndex) {
    setState(() {
      _showResult = true;
      _resultText = '恭喜抽中：${widget.items[resultIndex].name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // 显示传递过来的标题
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 显示中奖结果
            if (_showResult)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20), // 添加上下边距
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _resultText ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // 添加三角形箭头
            const TrianglePointer(),
            Expanded(
              child: Wheel(
                items: widget.items,
                onSpinComplete: _onSpinComplete, // 传递回调函数
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 三角形箭头
class TrianglePointer extends StatelessWidget {
  const TrianglePointer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrianglePainter(),
      child: Container(),
    );
  }
}

// 三角形绘制器
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 20); // 三角形顶点
    path.lineTo(size.width / 2 - 10, 0); // 三角形左下角
    path.lineTo(size.width / 2 + 10, 0); // 三角形右下角
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}