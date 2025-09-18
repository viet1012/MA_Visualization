import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/DetailsMSMovingAveModel.dart';
import 'package:universal_html/html.dart' as html;

class DetailsDataMSMovingAvePopup extends StatefulWidget {
  final String title;
  final Color colorTitle;
  final String subTitle;
  final List<DetailsMSMovingAveModel> data;

  const DetailsDataMSMovingAvePopup({
    super.key,
    required this.title,
    required this.colorTitle,
    required this.subTitle,
    required this.data,
  });

  @override
  State<DetailsDataMSMovingAvePopup> createState() =>
      _DetailsDataMSMovingAvePopupState();
}

class _DetailsDataMSMovingAvePopupState
    extends State<DetailsDataMSMovingAvePopup> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _filterController = TextEditingController();
  bool _hasInput = false;
  late List<DetailsMSMovingAveModel> filteredData;
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
    return selectedDept != null || selectedGroupName != null;
  }

  void _applyFilter() {
    final query = _filterController.text.toLowerCase();

    setState(() {
      filteredData =
          widget.data.where((item) {
            // Kiểm tra các điều kiện tìm kiếm trong chuỗi
            final matchesSearch =
                item.div.toLowerCase().contains(query) ||
                item.groupName.toLowerCase().contains(query) ||
                item.machineCode.toLowerCase().contains(query) ||
                item.machineType.toLowerCase().contains(query) ||
                item.refNo.toLowerCase().contains(query);

            // Kiểm tra các bộ lọc theo điều kiện của từng dropdown
            final matchesFilters =
                (selectedDept == null || item.div == selectedDept) &&
                (selectedGroupName == null ||
                    item.groupName == selectedGroupName);

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
      selectedGroupName = null;

      filteredData = widget.data;
      _hasInput = false; // ✅ reset trạng thái
    });
  }

  List<String> _getUniqueValues(
    String Function(DetailsMSMovingAveModel) selector,
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
            maxWidth: MediaQuery.of(context).size.width * .48,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                      const SizedBox(height: 4), // khoảng cách nhỏ giữa 2 text
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
              hintText: 'Search by Dept, GroupName, MachineCode, ...',
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
  String? selectedGroupName;

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

    // lọc tạm thời theo dept đã chọn (nếu có)
    final tempFilteredData =
        widget.data.where((item) {
          return (selectedDept == null || item.div == selectedDept);
        }).toList();

    // lấy danh sách giá trị duy nhất từ data theo key
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
            _hasInput = _checkHasInput();
          });
        };
        break;

      case 'groupName':
        selectedValue = selectedGroupName;
        onChanged = (value) {
          setState(() {
            selectedGroupName = value == '__reset__' ? null : value;
            _applyFilter();
            _hasInput = _checkHasInput();
          });
        };
        break;

      default:
        // không có filter cho cột này thì chỉ render Text bình thường
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

  Widget _buildDataTable(BuildContext context, ThemeData theme) {
    final columnKeys =
        rawJsonList.isNotEmpty ? rawJsonList.first.keys.toList() : [];

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header Table
            Table(
              border: TableBorder.all(
                color: theme.dividerColor.withOpacity(0.8),
              ),
              columnWidths: {
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(160),
                2: FixedColumnWidth(150),
                3: FixedColumnWidth(180),
                4: FixedColumnWidth(150),
                5: FixedColumnWidth(150),
                6: FixedColumnWidth(145),
                7: FixedColumnWidth(120),
                8: FixedColumnWidth(120),
                9: FixedColumnWidth(120),
                10: FixedColumnWidth(110),
                11: FixedColumnWidth(120),
                12: FixedColumnWidth(140),
              },
              children: [
                TableRow(
                  children:
                      columnKeys
                          .map((key) => _buildDynamicDropdownHeader(key))
                          .toList(),
                ),
              ],
            ),

            // Table content
            Expanded(
              child: SizedBox(
                height: 500,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(
                        color: theme.dividerColor.withOpacity(0.8),
                      ),
                      columnWidths: {
                        0: FixedColumnWidth(80),
                        1: FixedColumnWidth(160),
                        2: FixedColumnWidth(150),
                        3: FixedColumnWidth(180),
                        4: FixedColumnWidth(150),
                        5: FixedColumnWidth(150),
                        6: FixedColumnWidth(145),
                        7: FixedColumnWidth(120),
                        8: FixedColumnWidth(120),
                        9: FixedColumnWidth(120),
                        10: FixedColumnWidth(110),
                        11: FixedColumnWidth(120),
                        12: FixedColumnWidth(140),
                      },
                      children:
                          filteredData.map((item) {
                            final jsonRow = item.toJson(); // convert về Map
                            return TableRow(
                              children:
                                  columnKeys.map((key) {
                                    final value = jsonRow[key];
                                    return _buildTableCell(
                                      value?.toString() ?? '',
                                      isNumber: value is num,
                                    );
                                  }).toList(),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
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

    return Container(
      padding: isHeader ? EdgeInsets.only(top: 8) : null,
      // color: Colors.green,
      alignment: isHeader ? Alignment.center : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectableText(
          displayText,
          textAlign: isNumber ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
            color: highlight ? Colors.blue.shade700 : null,
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

  Uint8List createExcel(List<DetailsMSMovingAveModel> data) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Thêm tiêu đề đúng thứ tự
    sheet.appendRow([
      'DIV',
      'GROUPNAME',
      'MACHINECODE',
      'MACHINETYPE',
      'REF_NO',
      'Reason',
      'CONFIRM_DATE',
      'SENDTIME',
      'STARTTIME',
      'FINISHTIME',
      'TEMPRUN',
      'STOPHOUR',
      'ISSUESTATUS',
    ]);

    // Dữ liệu theo đúng thứ tự như tiêu đề
    for (var item in data) {
      sheet.appendRow([
        item.div,
        item.groupName,
        item.machineCode,
        item.machineType,
        item.refNo,
        item.reason,
        item.confirmDate,
        item.sendTime,
        item.startTime,
        item.finishTime,
        item.tempRun,
        item.stopHour,
        item.issueStatus,
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }
}
