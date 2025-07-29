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

// import 'package:syncfusion_flutter_charts/charts.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bubble Chart Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.grey[50],
//       ),
//       home: BubbleChartDemo(),
//     );
//   }
// }
//
// class BubbleChartDemo extends StatefulWidget {
//   @override
//   _BubbleChartDemoState createState() => _BubbleChartDemoState();
// }
//
// class _BubbleChartDemoState extends State<BubbleChartDemo> {
//   late List<BubbleData> chartData;
//   late TooltipBehavior _tooltipBehavior;
//   late ZoomPanBehavior _zoomPanBehavior;
//
//   @override
//   void initState() {
//     chartData = getBubbleData();
//     _tooltipBehavior = TooltipBehavior(
//       enable: true,
//       format: 'point.x: point.y\nSize: point.size',
//       header: '',
//       canShowMarker: false,
//     );
//     _zoomPanBehavior = ZoomPanBehavior(
//       enablePinching: true,
//       enablePanning: true,
//       enableDoubleTapZooming: true,
//       enableSelectionZooming: true,
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Bubble Chart Demo',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blue[700],
//         elevation: 4,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Info
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Phân tích Doanh số theo Thị trường',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[800],
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Biểu đồ bong bóng thể hiện mối quan hệ giữa doanh thu, lợi nhuận và quy mô thị trường',
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//
//               // Main Bubble Chart
//               Card(
//                 elevation: 6,
//                 child: Container(
//                   height: 400,
//                   padding: EdgeInsets.all(16.0),
//                   child: SfCartesianChart(
//                     title: ChartTitle(
//                       text: 'Doanh thu vs Lợi nhuận theo Thị trường',
//                       textStyle: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     legend: Legend(
//                       isVisible: true,
//                       position: LegendPosition.bottom,
//                       overflowMode: LegendItemOverflowMode.wrap,
//                     ),
//                     tooltipBehavior: _tooltipBehavior,
//                     zoomPanBehavior: _zoomPanBehavior,
//                     primaryXAxis: NumericAxis(
//                       title: AxisTitle(text: 'Doanh thu (tỷ VND)'),
//                       majorGridLines: MajorGridLines(width: 0),
//                       minorGridLines: MinorGridLines(width: 0),
//                     ),
//                     primaryYAxis: NumericAxis(
//                       title: AxisTitle(text: 'Lợi nhuận (%)'),
//                       majorGridLines: MajorGridLines(
//                         width: 1,
//                         color: Colors.grey[300],
//                       ),
//                     ),
//                     series: <BubbleSeries<BubbleData, double>>[
//                       BubbleSeries<BubbleData, double>(
//                         name: 'Thị trường Việt Nam',
//                         dataSource:
//                             chartData
//                                 .where((data) => data.region == 'Vietnam')
//                                 .toList(),
//                         xValueMapper: (BubbleData data, _) => data.revenue,
//                         yValueMapper: (BubbleData data, _) => data.profit,
//                         sizeValueMapper:
//                             (BubbleData data, _) => data.marketSize,
//                         color: Colors.blue[400],
//                         opacity: 0.7,
//                         dataLabelSettings: DataLabelSettings(
//                           isVisible: true,
//                           labelAlignment: ChartDataLabelAlignment.middle,
//                           textStyle: TextStyle(
//                             fontSize: 10,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       BubbleSeries<BubbleData, double>(
//                         name: 'Thị trường Quốc tế',
//                         dataSource:
//                             chartData
//                                 .where((data) => data.region == 'International')
//                                 .toList(),
//                         xValueMapper: (BubbleData data, _) => data.revenue,
//                         yValueMapper: (BubbleData data, _) => data.profit,
//                         sizeValueMapper:
//                             (BubbleData data, _) => data.marketSize,
//                         color: Colors.orange[400],
//                         opacity: 0.7,
//                         dataLabelSettings: DataLabelSettings(
//                           isVisible: true,
//                           labelAlignment: ChartDataLabelAlignment.middle,
//                           textStyle: TextStyle(
//                             fontSize: 10,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       BubbleSeries<BubbleData, double>(
//                         name: 'Thị trường Châu Á',
//                         dataSource:
//                             chartData
//                                 .where((data) => data.region == 'Asia')
//                                 .toList(),
//                         xValueMapper: (BubbleData data, _) => data.revenue,
//                         yValueMapper: (BubbleData data, _) => data.profit,
//                         sizeValueMapper:
//                             (BubbleData data, _) => data.marketSize,
//                         color: Colors.green[400],
//                         opacity: 0.7,
//                         dataLabelSettings: DataLabelSettings(
//                           isVisible: true,
//                           labelAlignment: ChartDataLabelAlignment.middle,
//                           textStyle: TextStyle(
//                             fontSize: 10,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//
//               // Interactive Features
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Tính năng tương tác:',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[800],
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       _buildFeatureItem('🔍', 'Pinch để zoom in/out'),
//                       _buildFeatureItem('👆', 'Kéo để pan biểu đồ'),
//                       _buildFeatureItem('📊', 'Tap vào bubble để xem tooltip'),
//                       _buildFeatureItem('🎯', 'Double tap để zoom fit'),
//                       _buildFeatureItem(
//                         '📈',
//                         'Kích thước bubble = quy mô thị trường',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 20),
//
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           chartData = getBubbleData();
//                         });
//                       },
//                       icon: Icon(Icons.refresh),
//                       label: Text('Làm mới dữ liệu'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue[600],
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         _zoomPanBehavior.reset();
//                       },
//                       icon: Icon(Icons.center_focus_strong),
//                       label: Text('Reset Zoom'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange[600],
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeatureItem(String icon, String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(icon, style: TextStyle(fontSize: 16)),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<BubbleData> getBubbleData() {
//     return [
//       // Vietnam Market
//       BubbleData('HCM', 'Vietnam', 150, 25, 80),
//       BubbleData('HN', 'Vietnam', 120, 22, 65),
//       BubbleData('DN', 'Vietnam', 80, 18, 45),
//       BubbleData('CT', 'Vietnam', 60, 15, 35),
//       BubbleData('HP', 'Vietnam', 45, 12, 25),
//
//       // International Market
//       BubbleData('US', 'International', 300, 35, 120),
//       BubbleData('EU', 'International', 250, 30, 100),
//       BubbleData('UK', 'International', 180, 28, 75),
//       BubbleData('CA', 'International', 140, 26, 60),
//
//       // Asia Market
//       BubbleData('JP', 'Asia', 280, 32, 110),
//       BubbleData('KR', 'Asia', 200, 29, 85),
//       BubbleData('SG', 'Asia', 160, 31, 70),
//       BubbleData('TH', 'Asia', 110, 24, 55),
//       BubbleData('MY', 'Asia', 90, 21, 40),
//     ];
//   }
// }
//
// class BubbleData {
//   BubbleData(
//     this.market,
//     this.region,
//     this.revenue,
//     this.profit,
//     this.marketSize,
//   );
//
//   final String market;
//   final String region;
//   final double revenue;
//   final double profit;
//   final double marketSize;
// }
