import 'package:flutter/material.dart';

class AnimatedTableCell extends StatefulWidget {
  final String text;
  final String displayText;
  final bool isHeader;
  final bool isNumber;
  final bool highlight;
  final Color colorBackground;
  final List<String> animatedKeys; // danh sách key sẽ có hiệu ứng

  const AnimatedTableCell({
    super.key,
    required this.text,
    required this.displayText,
    required this.isHeader,
    required this.isNumber,
    required this.highlight,
    required this.colorBackground,
    this.animatedKeys = const [], // mặc định không highlight cột nào
  });

  @override
  _AnimatedTableCellState createState() => _AnimatedTableCellState();
}

class _AnimatedTableCellState extends State<AnimatedTableCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: widget.colorBackground,
      end: widget.colorBackground.withOpacity(.2),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: widget.isHeader ? const EdgeInsets.only(top: 8) : null,
          color:
              widget.isHeader &&
                      widget.animatedKeys.contains(widget.text.toUpperCase())
                  ? _colorAnimation.value
                  : null,
          alignment: widget.isHeader ? Alignment.center : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              widget.displayText,
              textAlign: widget.isNumber ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontWeight:
                    widget.isHeader ? FontWeight.w600 : FontWeight.normal,
                color: widget.highlight ? Colors.blue.shade700 : null,
                fontSize: widget.isHeader ? 18 : 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
