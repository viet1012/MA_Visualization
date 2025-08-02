import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/MachineAnalysis.dart';
import 'DepartmentUtils.dart';

class MachineComparisonWidget extends StatefulWidget {
  final MachineAnalysis firstMachine;
  final MachineAnalysis secondMachine;
  final NumberFormat numberFormat;
  final VoidCallback onClose;

  const MachineComparisonWidget({
    Key? key,
    required this.firstMachine,
    required this.secondMachine,
    required this.numberFormat,
    required this.onClose,
  }) : super(key: key);

  @override
  State<MachineComparisonWidget> createState() =>
      _MachineComparisonWidgetState();
}

class _MachineComparisonWidgetState extends State<MachineComparisonWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán các chỉ số so sánh
    final repairFeeDiff =
        widget.secondMachine.repairFee - widget.firstMachine.repairFee;
    final stopHourDiff =
        widget.secondMachine.stopHour - widget.firstMachine.stopHour;
    final stopCaseDiff =
        widget.secondMachine.stopCase - widget.firstMachine.stopCase;

    final betterRepairFee =
        repairFeeDiff < 0 ? widget.secondMachine : widget.firstMachine;
    final betterStopHour =
        stopHourDiff < 0 ? widget.secondMachine : widget.firstMachine;
    final betterStopCase =
        stopCaseDiff < 0 ? widget.secondMachine : widget.firstMachine;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header với gradient
                _buildHeader(),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Machine comparison header
                      _buildMachineHeaders(),

                      const SizedBox(height: 32),

                      // Comparison metrics
                      _buildComparisonMetric(
                        'Repair Fee',
                        widget.firstMachine.repairFee,
                        widget.secondMachine.repairFee,
                        repairFeeDiff,
                        betterRepairFee == widget.firstMachine ? 1 : 2,
                        '\$',
                        Icons.attach_money_rounded,
                        Colors.green,
                      ),

                      _buildComparisonMetric(
                        'Stop Hours',
                        widget.firstMachine.stopHour,
                        widget.secondMachine.stopHour,
                        stopHourDiff,
                        betterStopHour == widget.firstMachine ? 1 : 2,
                        'h',
                        Icons.schedule_rounded,
                        Colors.orange,
                      ),

                      _buildComparisonMetric(
                        'Stop Cases',
                        widget.firstMachine.stopCase,
                        widget.secondMachine.stopCase,
                        stopCaseDiff,
                        betterStopCase == widget.firstMachine ? 1 : 2,
                        '',
                        Icons.warning_rounded,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Machine Comparison',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineHeaders() {
    return Row(
      children: [
        Expanded(
          child: _buildMachineHeader(
            widget.firstMachine,
            DepartmentUtils.getDepartmentColor(widget.firstMachine.div),
            '1st',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildMachineHeader(
            widget.secondMachine,
            DepartmentUtils.getDepartmentColor(widget.secondMachine.div),
            '2nd',
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMachineHeader(
    MachineAnalysis machine,
    Color color,
    String position,
    Color positionColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: positionColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              position,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            machine.macName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${machine.div} • Rank #${machine.rank}',
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMetric(
    String title,
    double value1,
    double value2,
    double diff,
    int winner,
    String unit,
    IconData icon,
    Color iconColor,
  ) {
    final diffPercentage = value1 != 0 ? (diff / value1 * 100).abs() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricValue(
                widget.numberFormat.format(value1) + unit,
                winner == 1,
                DepartmentUtils.getDepartmentColor(widget.firstMachine.div),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          diff > 0
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      diff > 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: diff > 0 ? Colors.red : Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${diffPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: diff > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildMetricValue(
                widget.numberFormat.format(value2) + unit,
                winner == 2,
                DepartmentUtils.getDepartmentColor(widget.secondMachine.div),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricValue(String value, bool isWinner, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient:
            isWinner
                ? LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                )
                : null,
        borderRadius: BorderRadius.circular(12),
        border:
            isWinner
                ? Border.all(color: color.withOpacity(0.5), width: 2)
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWinner) ...[
            Icon(Icons.star_rounded, size: 18, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              color: isWinner ? color : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(MachineAnalysis m1, MachineAnalysis m2) {
    // Tính toán máy nào tốt hơn tổng thể
    int m1Score = 0;
    int m2Score = 0;

    if (m1.repairFee < m2.repairFee) {
      m1Score++;
    } else {
      m2Score++;
    }

    if (m1.stopHour < m2.stopHour) {
      m1Score++;
    } else {
      m2Score++;
    }

    if (m1.stopCase < m2.stopCase) {
      m1Score++;
    } else {
      m2Score++;
    }

    final winner = m1Score > m2Score ? m1 : m2;
    final winnerScore = m1Score > m2Score ? m1Score : m2Score;
    final winnerColor = DepartmentUtils.getDepartmentColor(winner.div);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            winnerColor.withOpacity(0.15),
            winnerColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: winnerColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: winnerColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade400],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'OVERALL WINNER',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: winnerColor.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            winner.macName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: winnerColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: winnerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${winner.div} • Rank #${winner.rank}',
              style: TextStyle(
                fontSize: 14,
                color: winnerColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.military_tech_rounded, color: winnerColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Wins $winnerScore out of 3 metrics',
                style: TextStyle(
                  fontSize: 14,
                  color: winnerColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
