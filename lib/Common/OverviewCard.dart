import 'package:flutter/material.dart';
import 'package:ma_visualization/Common/WaterfallBackground.dart';

class OverviewCard extends StatelessWidget {
  final Widget child;

  const OverviewCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2 - 50,
      width: MediaQuery.of(context).size.width / 2,
      child: WaterfallBackground(
        child: Card(
          // elevation: 8,
          // shadowColor: Colors.blue,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(16),
          //   side: BorderSide(color: Colors.blue.shade100),
          // ),
          child: child,
        ),
      ),
    );
  }
}
