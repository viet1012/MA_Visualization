import 'package:flutter/material.dart';
import 'package:ma_visualization/Provider/MachineStoppingProvider.dart';
import 'package:ma_visualization/Provider/PMProvider.dart';
import 'package:ma_visualization/Provider/RepairFeeDailyProvider.dart';
import 'package:provider/provider.dart';

import 'MachineTrend/MachineTrendScreen.dart';
import 'Provider/DateProvider.dart';
import 'Provider/RepairFeeProvider.dart';
import 'Routes/GoRouter.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RepairFeeProvider()),
        ChangeNotifierProvider(create: (_) => MachineStoppingProvider()),
        ChangeNotifierProvider(create: (_) => RepairFeeDailyProvider()),
        ChangeNotifierProvider(create: (_) => PMProvider()),
        ChangeNotifierProvider(create: (_) => DateProvider()),
      ],
      child: DashboardApp(),
      // child: MaterialApp(home: MachineTrendScreen()),
    ),
  );
}

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDarkMode = true; // 🔥 Mặc định bật chế độ tối

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = createRouter(_toggleTheme); // Tạo router mới với chế độ tối
    return MaterialApp.router(
      routerConfig: router,
      // Cấu hình router cho MaterialApp
      title: 'MA Monitoring Web',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
