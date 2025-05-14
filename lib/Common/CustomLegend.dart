import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class LegendItem {
  final Color color;
  final String label;
  final bool dashed;

  LegendItem(this.color, this.label, {this.dashed = false});
}

class CustomLegend extends StatelessWidget {
  final List<LegendItem> items;
  final double fontSize;
  final double boxSize;
  final double spacing;

  const CustomLegend({
    super.key,
    required this.items,
    this.fontSize = 16,
    this.boxSize = 16,
    this.spacing = 20,
  });

  Widget _legendItem(LegendItem item) {
    final box =
        item.dashed
            ? DottedBorder(
              color: item.color,
              strokeWidth: 2,
              dashPattern: [4, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(2),
              child: SizedBox(width: boxSize, height: boxSize),
            )
            : Container(width: boxSize, height: boxSize, color: item.color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(width: 6),
        Text(
          item.label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: spacing, children: items.map(_legendItem).toList());
  }
}
