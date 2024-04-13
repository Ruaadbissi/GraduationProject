import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'dart:math' as math;



class NutritionProportions extends StatefulWidget {
  @override
  _NutritionProportionsState createState() => _NutritionProportionsState();
}

class _NutritionProportionsState extends State<NutritionProportions> {
  List<String> nutritionLabels = [
    " calories",
    " fat",
    " protein",
    " carbs",
    "Sugar and\n Fiber"
  ];

  List<double> nutritionValues = [18, 100, 15, 50, 30];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(nutritionLabels.length, (index) {
          return buildCircularProgress(nutritionLabels[index], nutritionValues[index], index);
        }),
      ),
    );}

  Widget buildCircularProgress(String label, double value, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: CircleProgressPainter(value),
                  child: Center(
                    child: Text(
                      " $label\n$value ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }}

class CircleProgressPainter extends CustomPainter {
  final double percentage; // Expecting percentage values

  CircleProgressPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white // Set the color of the circle
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    // Draw the circle
    canvas.drawCircle(center, radius, paint);

    // Draw the colored arc representing the ratio
    final arcPaint = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.amber.shade900; // Set the color of the ratio arc

    final sweepAngle = 2 * math.pi * percentage / 100;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}