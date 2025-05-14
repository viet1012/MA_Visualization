import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Common/NotFoundScreen.dart';

// ✅ Danh sách các phòng ban hợp lệ
final List<String> validDepts = [
  'Mold',
  'Press',
  'Guide',
  'MA',
  'PE',
  'Common',
  'MTC',
];

String _getCurrentMonth() {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

GoRouter createRouter(VoidCallback onToggleTheme) {
  return GoRouter(
    routes: [
      // GoRoute(
      //   path: '/',
      //   builder:
      //       (context, state) => DashboardScreen(onToggleTheme: onToggleTheme),
      // ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
