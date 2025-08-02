import 'package:flutter/material.dart';

class AnimatedChoiceChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final LinearGradient? selectedGradient;
  final Color? unselectedColor;
  final double? elevation;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final TextStyle? labelStyle;
  final double? iconSize;
  final bool showIcon;
  final bool enableHapticFeedback;
  final Duration animationDuration;

  const AnimatedChoiceChip({
    super.key,
    required this.label,
    this.icon = Icons.check_circle_outline,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    this.selectedGradient,
    this.unselectedColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.labelStyle,
    this.iconSize,
    this.showIcon = true,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  @override
  State<AnimatedChoiceChip> createState() => _AnimatedChoiceChipState();
}

class _AnimatedChoiceChipState extends State<AnimatedChoiceChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _colorAnimation = ColorTween(
      begin: widget.unselectedColor ?? Colors.grey.shade100,
      end: widget.selectedColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedChoiceChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
    }
    widget.onTap();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final padding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.98 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow:
                  widget.isSelected
                      ? [
                        BoxShadow(
                          color: widget.selectedColor.withOpacity(0.25),
                          blurRadius: 12 + (_elevationAnimation.value * 0.5),
                          offset: Offset(
                            0,
                            4 + (_elevationAnimation.value * 0.3),
                          ),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: widget.selectedColor.withOpacity(0.15),
                          blurRadius: 20 + _elevationAnimation.value,
                          offset: Offset(0, 8 + _elevationAnimation.value),
                          spreadRadius: 2,
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 1,
                        ),
                      ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: InkWell(
                onTap: _handleTap,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: borderRadius,
                splashColor: widget.selectedColor.withOpacity(0.15),
                highlightColor: widget.selectedColor.withOpacity(0.08),
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOutCubic,
                  padding: padding,
                  decoration: BoxDecoration(
                    gradient:
                        widget.isSelected && widget.selectedGradient != null
                            ? widget.selectedGradient
                            : null,
                    color:
                        widget.isSelected && widget.selectedGradient == null
                            ? _colorAnimation.value
                            : (widget.unselectedColor ?? Colors.white),
                    borderRadius: borderRadius,
                    border: Border.all(
                      color:
                          widget.isSelected
                              ? Colors.transparent
                              : Colors.grey.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.showIcon) ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            widget.isSelected
                                ? Icons.check_circle
                                : widget.icon,
                            key: ValueKey(
                              '${widget.label}-${widget.isSelected}',
                            ),
                            size: widget.iconSize ?? 18,
                            color:
                                widget.isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: widget.showIcon ? 10 : 0),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: widget.animationDuration,
                        curve: Curves.easeInOutCubic,
                        style:
                            widget.labelStyle?.copyWith(
                              color:
                                  widget.isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              fontWeight:
                                  widget.isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                            ) ??
                            TextStyle(
                              color:
                                  widget.isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              fontWeight:
                                  widget.isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
