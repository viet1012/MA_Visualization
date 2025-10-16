import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/DetailsRFMovingAveModel.dart';
import 'package:universal_html/html.dart' as html;

import '../MachineAnalysis/AnimatedTableCell.dart';

class DetailsDataRFMovingAvePopup extends StatefulWidget {
  final String title;
  final Color colorTitle;
  final String subTitle;
  final List<DetailsRFMovingAveModel> data;
  final double maxHeight;

  const DetailsDataRFMovingAvePopup({
    super.key,
    required this.title,
    required this.colorTitle,
    required this.subTitle,
    required this.data,
    required this.maxHeight,
  });

  @override
  State<DetailsDataRFMovingAvePopup> createState() =>
      _DetailsDataPMPopupState();
}

class _DetailsDataPMPopupState extends State<DetailsDataRFMovingAvePopup> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _filterController = TextEditingController();
  bool _hasInput = false;
  late List<DetailsRFMovingAveModel> filteredData;
  late List<Map<String, dynamic>> rawJsonList; // bạn lưu từ response

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
    _filterController.addListener(() {
      setState(() {
        _hasInput = _filterController.text.trim().isNotEmpty;
      });
    });
    _filterController.addListener(_applyFilter);
    rawJsonList = widget.data.map((e) => e.toJson()).toList();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _checkHasInput() {
    return selectedDept != null;
  }

  void _applyFilter() {
    final query = _filterController.text.toLowerCase();

    setState(() {
      filteredData =
          widget.data.where((item) {
            // Kiểm tra các điều kiện tìm kiếm trong chuỗi
            final matchesSearch =
                item.div.toLowerCase().contains(query) ||
                item.macGrp.toLowerCase().contains(query) ||
                item.macId.toLowerCase().contains(query) ||
                item.cate.toLowerCase().contains(query) ||
                item.matnr.toLowerCase().contains(query) ||
                item.maktx.toLowerCase().contains(query) ||
                item.macId.toLowerCase().contains(query);

            // Kiểm tra các bộ lọc theo điều kiện của từng dropdown
            final matchesFilters =
                (selectedDept == null || item.div == selectedDept) &&
                (selectedCate == null || item.cate == selectedCate);

            return matchesSearch &&
                matchesFilters; // Kết hợp cả hai điều kiện: tìm kiếm và lọc
          }).toList();
      print("Filtered Data Length: ${filteredData.length}");
    });
  }

  void _resetFilter() {
    setState(() {
      _filterController.clear();

      selectedDept = null;
      selectedCate = null;

      filteredData = widget.data;
      _hasInput = false; // ✅ reset trạng thái
    });
  }

  List<String> _getUniqueValues(
    String Function(DetailsRFMovingAveModel) selector,
  ) {
    return widget.data.map(selector).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 12,
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: widget.maxHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 16),
                Expanded(child: _buildDataTable(context, theme)),
                const SizedBox(height: 16),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final totalAmount = filteredData.fold<double>(
      0,
      (sum, item) => (sum + item.act),
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: widget.colorTitle,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 10), // khoảng cách nhỏ giữa 2 text
                      Text(
                        widget.subTitle, // hoặc widget.subtitle nếu có
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.yellowAccent[700],
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  SizedBox(width: 8),
                  Text(
                    '[Details Data]',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.blueAccent.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "Total: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "${(totalAmount / 1000).toStringAsFixed(1)}K\$",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),
                FilledButton.icon(
                  icon: Icon(Icons.cleaning_services_rounded),
                  label: Text('Clear'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _hasInput ? Colors.red.shade600 : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                  ),
                  onPressed: _resetFilter,
                ),
                SizedBox(width: 16),
                FilledButton.icon(
                  icon: Icon(Icons.download_rounded, size: 20),
                  label: Text('Export Excel'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    final excelBytes = createExcel(filteredData);
                    downloadExcel(
                      excelBytes,
                      '${widget.title}_details_data.xlsx',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: theme.dividerColor, thickness: 1),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextField(
            controller: _filterController,
            decoration: InputDecoration(
              hintText: 'Search by Dept, MacGrp, MacName, ...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              filled: true,
              fillColor: theme.cardColor.withOpacity(.5),
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  String? selectedDept;
  String? selectedCate;

  List<String> _getUniqueValuesFromList(
    List<dynamic> list,
    String Function(dynamic) extractor,
  ) {
    final set = <String>{};
    for (var item in list) {
      final value = extractor(item);
      if (value.isNotEmpty) {
        set.add(value);
      }
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  Widget _buildDynamicDropdownHeader(String key) {
    final title = key.toUpperCase();

    final tempFilteredData =
        widget.data.where((item) {
          return (selectedDept == null || item.div == selectedDept);
        }).toList();

    // Lấy danh sách giá trị duy nhất theo key trong kết quả đã lọc
    List<String> values = _getUniqueValuesFromList(
      tempFilteredData,
      (item) => item.toJson()[key]?.toString() ?? '',
    );

    String? selectedValue;
    void Function(String?)? onChanged;

    switch (key) {
      case 'dept':
        selectedValue = selectedDept;
        onChanged = (value) {
          setState(() {
            selectedDept = value == '__reset__' ? null : value;
            _applyFilter();
            _hasInput = _checkHasInput(); // kiểm tra tổng thể filter
          });
        };
        break;

      case 'cate':
        selectedValue = selectedCate;
        onChanged = (value) {
          setState(() {
            selectedCate = value == '__reset__' ? null : value;
            _applyFilter();
            _hasInput = _checkHasInput(); // kiểm tra tổng thể filter
          });
        };
        break;
      default:
        // Không filter được -> render Text bình thường
        return _buildTableCell(title, isHeader: true, columnKey: key);
    }

    return _buildDropdownHeader(
      title: title,
      selectedValue: selectedValue,
      values: values,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownHeader({
    required String title,
    required String? selectedValue,
    required List<String> values,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          DropdownButton<String>(
            value: selectedValue ?? '__reset__',
            isExpanded: true,
            items: [
              DropdownMenuItem<String>(
                value: '__reset__',
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              ...values.map(
                (v) => DropdownMenuItem<String>(
                  value: v,
                  child: Text(
                    v,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  double _getColumnWidth(String key) {
    switch (key.toLowerCase()) {
      case "div":
        return 80; // rộng hơn
      case "macgrp":
        return 110; // nhỏ hơn
      case "macid":
        return 100;
      case "macname":
        return 180;
      case "cate":
        return 130;
      case "matnr":
        return 120;
      case "maktx":
        return 260;
      case "usedate":
        return 120;
      case "kostl":
        return 120;
      case "konto":
        return 110;
      case "xblnr2":
        return 130;
      case "bktxt":
        return 140;
      case "qty":
        return 80;

      default:
        return 100; // mặc định
    }
  }

  _buildDataTable(BuildContext context, ThemeData theme) {
    final columnKeys =
        rawJsonList.isNotEmpty ? rawJsonList.first.keys.toList() : [];

    final Map<String, double> columnMax = {};

    // Tính max cho từng cột số
    for (var key in columnKeys) {
      columnMax[key] = 0.0;
    }

    for (var item in filteredData) {
      final row = item.toJson();
      for (var key in columnKeys) {
        final v = row[key];
        if (v is num) {
          final d = v.toDouble();
          if (d > (columnMax[key] ?? 0)) {
            columnMax[key] = d;
          }
        }
      }
    }

    return SingleChildScrollView(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              // Header
              Table(
                border: TableBorder.all(
                  color: theme.dividerColor.withOpacity(0.8),
                ),
                columnWidths: {
                  for (int i = 0; i < columnKeys.length; i++)
                    i: FixedColumnWidth(_getColumnWidth(columnKeys[i])),
                },
                children: [
                  TableRow(
                    children:
                        columnKeys.map((key) {
                          return _buildDynamicDropdownHeader(key);
                        }).toList(),
                  ),
                ],
              ),

              // Nội dung cuộn theo chiều dọc
              SizedBox(
                height: 700,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SizedBox(
                    width: columnKeys.fold<double>(
                      0,
                      (sum, key) => sum + _getColumnWidth(key),
                    ), // 👈 tổng width theo từng cột
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, rowIndex) {
                        final jsonRow = filteredData[rowIndex].toJson();

                        return Row(
                          children:
                              columnKeys.map((key) {
                                final value = jsonRow[key];
                                final isNumber = value is num;
                                final txt = value?.toString() ?? '';
                                return Container(
                                  width: _getColumnWidth(key),
                                  decoration: BoxDecoration(
                                    border: BoxBorder.all(
                                      color: theme.dividerColor.withOpacity(
                                        0.8,
                                      ),
                                    ),
                                  ),
                                  child: _buildTableCell(
                                    txt,
                                    isHeader: false,
                                    isNumber: isNumber,
                                    columnKey: key,
                                    // numValue:
                                    //     isNumber ? value.toDouble() : null,
                                    // columnMaxValue: columnMax[key],
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool highlight = false,
    bool isNumber = false,
    String? columnKey, // thêm tham số để biết cột nào
  }) {
    final isActual =
        columnKey != null && columnKey.toLowerCase().contains('act');
    final displayText = (isActual && isHeader) ? '${text} ' : text;
    final isActColumn = columnKey?.trim() == 'act';

    return isHeader && text == 'ACT'
        ? AnimatedTableCell(
          text: 'ACT',
          displayText: displayText,
          isHeader: true,
          isNumber: true,
          highlight: false,
          colorBackground: widget.colorTitle,
          animatedKeys: ['ACT'],
        )
        : Container(
          height: isHeader ? 60 : 80,
          padding: isHeader ? EdgeInsets.only(top: 8) : null,
          // color: Colors.green,
          alignment: isHeader ? Alignment.center : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              displayText,
              textAlign: isNumber ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontWeight:
                    isHeader || isActColumn
                        ? FontWeight.w600
                        : FontWeight.normal,
                color: isActColumn ? widget.colorTitle : null,
                fontSize: isHeader ? 18 : 16,
              ),
            ),
          ),
        );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = Colors.deepOrange;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton.icon(
          label: Text('Close'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.hovered)) {
                return errorColor.withOpacity(0.8); // Hover
              } else if (states.contains(MaterialState.pressed)) {
                return errorColor.withOpacity(1); // Pressed
              } else if (states.contains(MaterialState.focused)) {
                return errorColor.withOpacity(0.95); // Focused
              }
              return errorColor; // Default
            }),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            elevation: MaterialStateProperty.all(2),
            overlayColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.05), // Hiệu ứng ripple
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void downloadExcel(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  Uint8List createExcel(List<DetailsRFMovingAveModel> data) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Thêm tiêu đề đúng thứ tự
    sheet.appendRow([
      'DIV',
      'MacGrp',
      'MacID',
      'MacName',
      'Cate',
      'MATNR',
      'MAKTX',
      'UseDate',
      'KOSTL',
      'KONTO',
      'XBLNR2',
      'BKTXT',
      'QTY',
      'UNIT',
      'ACT',
      'Note',
    ]);

    // Dữ liệu theo đúng thứ tự như tiêu đề
    for (var item in data) {
      sheet.appendRow([
        item.div,
        item.macGrp,
        item.macId,
        item.macName,
        item.cate,
        item.matnr,
        item.maktx,
        item.useDate,
        item.kostl,
        item.konto,
        item.xblnr2,
        item.bktxt,
        item.qty,
        item.unit,
        item.act,
        item.note,
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }
}
