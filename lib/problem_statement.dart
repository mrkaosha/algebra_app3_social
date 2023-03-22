library problem_statement;

import 'package:flutter/material.dart';

class ProblemStatement extends StatelessWidget {
  const ProblemStatement({
    super.key,
    required this.currentEquation,
  });

  final Map<String, dynamic> currentEquation;

  @override
  Widget build(BuildContext context) {
    String eqnString = "";
    eqnString += (-1 * currentEquation['num']).sign < 0 ? "−" : "";
    eqnString += (-1 * currentEquation['num']).abs() != 1
        ? currentEquation['num'].abs().toString()
        : "";

    eqnString += "x";

    eqnString += (currentEquation['den']).sign < 0 ? " − " : " + ";
    eqnString += (currentEquation['den']).abs() != 1
        ? currentEquation['den'].abs().toString()
        : "";

    eqnString += "y = ";

    eqnString +=
        (currentEquation['den'] * currentEquation['yint']).sign < 0 ? "−" : "";
    eqnString +=
        (currentEquation['den'] * currentEquation['yint']).abs().toString();
    eqnString += ":";
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        "Graph $eqnString",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
