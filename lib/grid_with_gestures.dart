library grid_with_gestures;

import 'grid_painter.dart';
import 'package:flutter/material.dart';

class GridWithGestureDetector extends StatefulWidget {
  const GridWithGestureDetector({
    super.key,
    required this.canvasWidth,
    required this.margins,
    required this.canvasHeight,
    required this.gridSize,
    required this.dataList,
  });

  final double canvasWidth;
  final double margins;
  final double canvasHeight;
  final double gridSize;
  final List<List<bool>> dataList;

  @override
  State<GridWithGestureDetector> createState() =>
      _GridWithGestureDetectorState();
}

class _GridWithGestureDetectorState extends State<GridWithGestureDetector> {
  double x = 0.0;
  double y = 0.0;
  bool drawCursor = false;
  void _toggleDataPoint(TapDownDetails details) {
    x = ((details.localPosition.dx - widget.margins * widget.canvasWidth) /
                widget.gridSize)
            .round() *
        widget.gridSize;
    y = ((details.localPosition.dy - widget.margins * widget.canvasHeight) /
                widget.gridSize)
            .round() *
        widget.gridSize;
    int i = ((widget.canvasWidth - y) / widget.gridSize) as int;
    if (i < 0) {
      i = 0;
    } else if (i > widget.dataList.length - 1) {
      i = widget.dataList.length - 1;
    }
    int j = x / widget.gridSize as int;
    if (j < 0) {
      j = 0;
    } else if (j > widget.dataList[0].length - 1) {
      j = widget.dataList.length - 1;
    }
    print("$i, $j");
    setState(() {
      widget.dataList[i][j]
          ? widget.dataList[i][j] = false
          : widget.dataList[i][j] = true;
      drawCursor = false;
    });
    //print(dataList);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SizedBox(
          width: widget.canvasWidth * (1.0 + widget.margins * 2),
          height: widget.canvasHeight * (1.0 + widget.margins * 2),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTapDown: _toggleDataPoint,
              child: CustomPaint(
                foregroundPainter: CursorPainter(x, y, drawCursor),
                painter: GridPainter(widget.canvasWidth, widget.canvasHeight,
                    widget.gridSize, widget.margins, widget.dataList),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
