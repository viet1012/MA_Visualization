import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';
import 'MachineBubbleScreen.dart';
import 'MachineTableScreen.dart';

class DepartmentStatsWidget extends StatefulWidget {
  final List<MachineAnalysis> data;
  final NumberFormat numberFormat;
  final AnalysisMode selectedMode;
  final String div;
  final String month;
  final String monthBack;
  final int topLimit;

  const DepartmentStatsWidget({
    super.key,
    required this.data,
    required this.numberFormat,
    required this.selectedMode,
    required this.div,
    required this.month,
    required this.monthBack,
    required this.topLimit,
  });

  @override
  State<DepartmentStatsWidget> createState() => _DepartmentStatsWidgetState();
}

class _DepartmentStatsWidgetState extends State<DepartmentStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _moneyController;
  late AnimationController _rotationController;
  late AnimationController _clockController;
  late AnimationController _scaleController;

  late Animation<double> _moneyAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _clockAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Money bounce animation
    _moneyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _moneyAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _moneyController, curve: Curves.elasticInOut),
    );

    // Rotation animation for stop case
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Clock swing animation
    _clockController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _clockAnimation = Tween<double>(begin: -0.4, end: 0.4).animate(
      CurvedAnimation(parent: _clockController, curve: Curves.easeInOut),
    );

    // Scale pulse animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.3).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Start animations with delays
    _startAnimations();
  }

  void _startAnimations() {
    // Money bounce - repeating
    _moneyController.repeat(reverse: true);

    // Rotation - repeating
    Future.delayed(const Duration(milliseconds: 300), () {
      _rotationController.repeat();
    });

    // Clock swing - repeating
    Future.delayed(const Duration(milliseconds: 600), () {
      _clockController.repeat(reverse: true);
    });

    // Scale pulse - repeating
    Future.delayed(const Duration(milliseconds: 900), () {
      _scaleController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _rotationController.dispose();
    _clockController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gom nhóm theo phòng ban (division)
    final Map<String, List<MachineAnalysis>> deptData = {};

    // Bước 1: Thêm vào Map
    for (var item in widget.data) {
      deptData.putIfAbsent(item.div, () => []).add(item);
    }

    // Bước 3: Sắp xếp theo predefinedOrder
    List<String> predefinedOrder = ['KVH', 'PRESS', 'MOLD', 'GUIDE'];
    List<String> departmentOrder = deptData.keys.toList();

    departmentOrder.sort((a, b) {
      int indexA = predefinedOrder.indexOf(a);
      int indexB = predefinedOrder.indexOf(b);
      if (indexA == -1) indexA = predefinedOrder.length;
      if (indexB == -1) indexB = predefinedOrder.length;
      return indexA.compareTo(indexB);
    });

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  departmentOrder.map((dept) {
                    List<MachineAnalysis> machines = deptData[dept]!;

                    double totalRepairFee = machines.fold(
                      0,
                      (sum, m) => sum + m.repairFee,
                    );
                    double totalStopHour = machines.fold(
                      0,
                      (sum, m) => sum + m.stopHour,
                    );
                    int totalStopCase = machines.fold(
                      0,
                      (sum, m) => sum + m.stopCase.toInt(),
                    );

                    return Container(
                      width: 550,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DepartmentUtils.getDepartmentColor(
                          dept,
                        ).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: DepartmentUtils.getDepartmentColor(dept),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color:
                                                DepartmentUtils.getDepartmentColor(
                                                  dept,
                                                ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    dept,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: DepartmentUtils.getDepartmentColor(
                                        dept,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAnimatedStatItem(
                                AnimatedBuilder(
                                  animation: _moneyAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _moneyAnimation.value,
                                      child: const Text(
                                        '💰',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                                'Repair Fee',
                                '${widget.numberFormat.format(totalRepairFee)}\$',
                              ),
                              _buildAnimatedStatItem(
                                AnimatedBuilder(
                                  animation: _rotationAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _rotationAnimation.value * 3.14159,
                                      child: const Text(
                                        '🔄',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                                'Stop Case',
                                widget.numberFormat.format(totalStopCase),
                              ),
                              _buildAnimatedStatItem(
                                AnimatedBuilder(
                                  animation: _clockAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _clockAnimation.value,
                                      child: const Text(
                                        '⏰',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                                'Stop Hour',
                                '${widget.numberFormat.format(totalStopHour)}h',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    Widget animatedIcon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        animatedIcon,
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
