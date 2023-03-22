library grid_painter;

import 'package:flutter/material.dart';
import 'dart:ui';

class GridPainter extends CustomPainter {
  late double _canvasWidth;
  late double _canvasHeight;
  late double _gridSize;
  late double _margin;
  late double _xMargin;
  late double _yMargin;
  late List<List<bool>> _gridData;

  GridPainter(width, height, gridSize, margin, gridData) {
    _canvasWidth = width;
    _canvasHeight = height;
    _gridData = gridData;
    _gridSize = gridSize;
    _margin = margin;
    _xMargin = margin * _canvasWidth;
    _yMargin = margin * _canvasHeight;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    final paintAxes = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    double xv = 0.0;
    double yh = 0.0;
    double verticalHeight = _canvasHeight * (1 + 2 * _margin);
    double horizontalLength = _canvasWidth * (1 + 2 * _margin);
    List<Offset> dataPoints = [];

    for (int i = 0; i <= (_canvasHeight / _gridSize as int); i++) {
      xv = _gridSize * i + _xMargin;
      yh = _gridSize * i + _yMargin;

      //drawing the vertical grid line
      canvas.drawLine(
        Offset(xv, 0),
        Offset(xv, verticalHeight), // **** REFACTOR
        paint,
      );
      //drawing the horizontal grid line
      canvas.drawLine(
        Offset(0, yh),
        Offset(horizontalLength, yh), // **** REFACTOR
        paint,
      );
      // Draw the numbers
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: (i - 10).toString()),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.1);

      textPainter.paint(
        canvas,
        Offset(
          xv - 7,
          _canvasHeight / 2.0 + 5 + _yMargin,
        ),
      ); // x-axis labels

      textPainter.paint(
        canvas,
        Offset(
          -20 + _canvasWidth / 2.0 + _yMargin,
          verticalHeight - yh - 7,
          // this last calculation is awkward but the first y label is -10 and
          // the last is +10, so what to do here...
        ),
      ); // y-axis labels

      // grab the dots for the data points
      var r = _gridData[i];
      r.asMap().forEach((index, d) => {
            if (d)
              {
                dataPoints.add(Offset(
                  index * _gridSize + _xMargin,
                  _canvasWidth - i * _gridSize + _yMargin,
                ))
              }
          });
    } // end for loop

    final TextPainter textPainterY = TextPainter(
      text: const TextSpan(text: "y"),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.1);
    // thick line for y-axis
    canvas.drawLine(
      Offset(
        _canvasWidth / 2.0 + _yMargin,
        0,
      ),
      Offset(
        _canvasWidth / 2.0 + _yMargin,
        verticalHeight,
      ),
      paintAxes,
    );
    textPainterY.paint(
      canvas,
      Offset(
        _canvasWidth / 2.0 + _yMargin,
        -45.0 + _yMargin,
      ),
    ); // draw label for y-axis

    final TextPainter textPainterX = TextPainter(
      text: const TextSpan(text: "x"),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.1);
    // thick line for x-axis
    canvas.drawLine(
      Offset(
        0,
        _canvasHeight / 2.0 + _yMargin,
      ),
      Offset(
        horizontalLength,
        _canvasHeight / 2.0 + _yMargin,
      ),
      paintAxes,
    );
    textPainterX.paint(
      canvas,
      Offset(
        _canvasWidth + 30 + _yMargin,
        _canvasHeight / 2.0 + _yMargin,
      ),
    ); // draw the label for x-axis

    var paint1 = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawPoints(PointMode.points, dataPoints, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CursorPainter extends CustomPainter {
  double _x = 0.0;
  double _y = 0.0;
  bool _drawCursor = false;
  CursorPainter(x, y, drawCursor) {
    _x = x;
    _y = y;
    _drawCursor = drawCursor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _drawCursor ? 10 : 0;
    canvas.drawPoints(PointMode.points, [Offset(_x, _y)], paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
