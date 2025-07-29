import 'package:flutter/material.dart';

class NoDataWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final double iconSize;
  final Color? primaryColor;
  final Color? backgroundColor;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool showAnimation;
  final Widget? customIllustration;

  const NoDataWidget({
    super.key,
    this.title = "Không có dữ liệu",
    this.message = "Vui lòng chọn tháng khác hoặc thử lại sau.",
    this.icon = Icons.analytics_outlined,
    this.iconSize = 80,
    this.primaryColor,
    this.backgroundColor = Colors.black,
    this.onRetry,
    this.retryButtonText = "Reload",
    this.showAnimation = true,
    this.customIllustration,
  });

  @override
  State<NoDataWidget> createState() => _NoDataWidgetState();
}

class _NoDataWidgetState extends State<NoDataWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.showAnimation) {
      _startAnimations();
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _bounceController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _floatController.repeat(reverse: true);
    });

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = widget.primaryColor ?? colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? Colors.grey.shade50;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child:
          widget.showAnimation
              ? _buildAnimatedContent(primaryColor)
              : _buildStaticContent(primaryColor),
    );
  }

  Widget _buildAnimatedContent(Color primaryColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeAnimation,
        _bounceAnimation,
        _floatAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Floating animated icon with glow effect
              Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: ScaleTransition(
                  scale: _bounceAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child:
                        widget.customIllustration ??
                        Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: ScaleTransition(
                            scale: _bounceAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: ScaleTransition(
                                scale: _pulseAnimation,
                                child: Icon(
                                  widget.icon,
                                  size: widget.iconSize,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Animated title with gradient
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    ).createShader(bounds),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle with fade in
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.onRetry != null) ...[
                const SizedBox(height: 32),

                // Animated retry button
                ScaleTransition(
                  scale: _bounceAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: widget.onRetry,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.retryButtonText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticContent(Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
          ),
          child:
              widget.customIllustration ??
              Icon(widget.icon, size: widget.iconSize, color: primaryColor),
        ),

        const SizedBox(height: 32),

        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
              ).createShader(bounds),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          widget.message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        if (widget.onRetry != null) ...[
          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: widget.onRetry,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.retryButtonText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
