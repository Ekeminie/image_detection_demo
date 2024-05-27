import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_detection_demo/controller/steps-controller.dart';

class CustomCircle extends ConsumerWidget {
  final bool full;
  final bool start;

  const CustomCircle({super.key, this.full = false, this.start = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, ref, child) {
      final controller = ref.watch(controllerProvider);
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: CirclePainter(),
                  ),
                  if (controller.steps != GestureSteps.start)
                    CustomPaint(
                      painter: HalfCirclePainter(
                          color: Colors.green,
                          isFull: controller.steps == GestureSteps.hasStepTwo),
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                      ),
                    ),
                  Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
                decoration: BoxDecoration(
                    color: Colors.black54.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  "${controller.steps.value!}/2",
                  style: const TextStyle(color: Colors.white),
                ))
          ],
        ),
      );
    });
  }
}

class CirclePainter extends CustomPainter {
  CirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    double startAngle = math.pi / 2;
    double endAngle = startAngle + math.pi;

    // if (value == 2) {
    //   paint.color = Colors.green;
    //   endAngle = 2 * math.pi;
    // }

    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle,
        endAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HalfCirclePainter extends CustomPainter {
  final Color color;
  final bool isFull;
  HalfCirclePainter({required this.color, this.isFull = false});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    double startAngle = -math.pi / 2;
    double endAngle = startAngle + 1.5 * math.pi;

    if (isFull) {
      endAngle = startAngle + 3 * math.pi;
    }

    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle,
        endAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
