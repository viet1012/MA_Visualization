import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MachineTileWidget extends StatelessWidget {
  final dynamic machine;
  final String? selectedMachine;
  final Color baseColor;
  final Color macNameColor;
  final Color repairFeeColor;
  final double maxLabelWidth;
  final NumberFormat numberFormat;

  const MachineTileWidget({
    Key? key,
    required this.machine,
    required this.selectedMachine,
    required this.baseColor,
    required this.macNameColor,
    required this.repairFeeColor,
    required this.maxLabelWidth,
    required this.numberFormat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy số thứ tự MovAve
    String movAveIndex = "";
    if (machine.scale.startsWith("MovAve")) {
      movAveIndex =
          int.tryParse(machine.scale.replaceAll("MovAve", ""))?.toString() ??
          "";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      constraints: BoxConstraints(maxWidth: maxLabelWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (movAveIndex.isNotEmpty)
            FittedBox(
              fit: BoxFit.contain, // scale chữ vừa với container
              child: Container(
                width: 40, // chiều rộng bubble
                height: 40, // chiều cao bubble
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Stroke
                    Text(
                      movAveIndex,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        foreground:
                            Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.white,
                      ),
                    ),
                    // Fill
                    Text(
                      movAveIndex,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: baseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (movAveIndex.isNotEmpty) const SizedBox(height: 2),

          // if (machine.macName == selectedMachine)
          //   FittedBox(
          //     fit: BoxFit.scaleDown,
          //     child: Text(
          //       machine.scale,
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         color: Colors.yellow,
          //         fontWeight: FontWeight.w500,
          //         shadows: [
          //           Shadow(
          //             color: Colors.white.withOpacity(0.6),
          //             blurRadius: 4,
          //             offset: const Offset(0, 0),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          if (machine.macName == selectedMachine) const SizedBox(height: 2),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              machine.rank,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              machine.macName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: macNameColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${numberFormat.format(machine.repairFee)}\$',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: repairFeeColor,
                shadows: [
                  Shadow(
                    color: Colors.yellowAccent.withOpacity(0.6),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
