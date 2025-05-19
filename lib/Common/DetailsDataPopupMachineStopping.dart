import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/DetailsDataMachineStoppingModel.dart';
import 'package:universal_html/html.dart' as html;

class DetailsDataPopupMachineStopping extends StatefulWidget {
  final String title;
  final List<DetailsDataMachineStoppingModel> data;

  DetailsDataPopupMachineStopping({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  State<DetailsDataPopupMachineStopping> createState() =>
      _DetailsDataPopupMachineStoppingState();
}

class _DetailsDataPopupMachineStoppingState
    extends State<DetailsDataPopupMachineStopping> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _filterController = TextEditingController();
  bool _hasInput = false;

  late List<DetailsDataMachineStoppingModel> filteredData;
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

  void _applyFilter() {
    final query = _filterController.text.toLowerCase();

    setState(() {
      filteredData =
          widget.data.where((item) {
            // Kiểm tra các điều kiện tìm kiếm trong chuỗi
            final matchesSearch =
                (item.div?.toLowerCase() ?? '').contains(query) ||
                (item.groupName?.toLowerCase() ?? '').contains(query) ||
                (item.machineCode?.toLowerCase() ?? '').contains(query) ||
                (item.machineType?.toLowerCase() ?? '').contains(query) ||
                (item.statusCode?.toLowerCase() ?? '').contains(query) ||
                (item.confirmDate?.toLowerCase() ?? '').contains(query) ||
                (item.sendTime?.toLowerCase() ?? '').contains(query) ||
                (item.startTime?.toLowerCase() ?? '').contains(query) ||
                (item.esTime?.toLowerCase() ?? '').contains(query) ||
                (item.finishTime?.toLowerCase() ?? '').contains(query) ||
                (item.stopHour?.toString() ?? '').contains(query) ||
                (item.sendDate?.toString() ?? '').contains(query) ||
                (item.issueStatus?.toLowerCase() ?? '').contains(query);

            // Kiểm tra các bộ lọc theo điều kiện của từng dropdown
            final matchesFilters =
                (selectedSendDate == null ||
                    item.sendDate == selectedSendDate) &&
                (selectedDiv == null || item.div == selectedDiv) &&
                (selectedGroupName == null ||
                    item.groupName == selectedGroupName) &&
                (selectedMachineCode == null ||
                    item.machineCode == selectedMachineCode) &&
                (selectedMachineType == null ||
                    item.machineType == selectedMachineType) &&
                (selectedStatusCode == null ||
                    item.statusCode == selectedStatusCode) &&
                (selectedConfirmDate == null ||
                    item.confirmDate == selectedConfirmDate) &&
                (selectedSendTime == null ||
                    item.sendTime == selectedSendTime) &&
                (selectedStartTime == null ||
                    item.startTime == selectedStartTime) &&
                (selectedEsTime == null || item.esTime == selectedEsTime) &&
                (selectedFinishTime == null ||
                    item.finishTime == selectedFinishTime) &&
                (selectedStopHour == null ||
                    item.stopHour?.toString() == selectedStopHour) &&
                (selectedIssueStatus == null ||
                    item.issueStatus == selectedIssueStatus);

            return matchesSearch &&
                matchesFilters; // Kết hợp cả hai điều kiện: tìm kiếm và lọc
          }).toList();
      print("Filtered Data Length: ${filteredData.length}");
    });
  }

  void _resetFilter() {
    setState(() {
      _filterController.clear();
      selectedSendDate = null;
      selectedDiv = null;
      selectedGroupName = null;
      selectedMachineCode = null;
      selectedMachineType = null;
      selectedStatusCode = null;
      selectedConfirmDate = null;
      selectedSendTime = null;
      selectedStartTime = null;
      selectedEsTime = null;
      selectedFinishTime = null;
      selectedStopHour = null;
      selectedIssueStatus = null;
      filteredData = widget.data;
      _hasInput = false; // ✅ reset trạng thái
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _checkHasInput() {
    return selectedSendDate != null ||
        selectedDiv != null ||
        selectedGroupName != null ||
        selectedMachineCode != null ||
        selectedMachineType != null ||
        selectedStatusCode != null ||
        selectedConfirmDate != null ||
        selectedSendTime != null ||
        selectedStartTime != null ||
        selectedEsTime != null ||
        selectedFinishTime != null ||
        selectedStopHour != null ||
        selectedIssueStatus != null;
  }

  List<String> _getUniqueValues(
    String Function(DetailsDataMachineStoppingModel) selector,
  ) {
    return widget.data.map(selector).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
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
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 4),
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
                    downloadExcel(excelBytes, 'details_data.xlsx');
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
              hintText:
                  'Search by Div, Group Name, Machine Code, Machine Type...',
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

  String? selectedSendDate;
  String? selectedDiv;
  String? selectedGroupName;
  String? selectedMachineCode;
  String? selectedMachineType;
  String? selectedStatusCode;
  String? selectedConfirmDate;
  String? selectedSendTime;
  String? selectedStartTime;
  String? selectedEsTime;
  String? selectedFinishTime;
  String? selectedStopHour;
  String? selectedIssueStatus;

  Widget _buildDynamicDropdownHeader(String key) {
    final title = key.toUpperCase();
    List<String> values = _getUniqueValues(
      (item) => item.toJson()[key]?.toString() ?? '',
    );

    final valueMap = {
      'sendDate': selectedSendDate,
      'div': selectedDiv,
      'groupName': selectedGroupName,
      'machineCode': selectedMachineCode,
      'machineType': selectedMachineType,
      'statusCode': selectedStatusCode,
      'confirmDate': selectedConfirmDate,
      'sendTime': selectedSendTime,
      'startTime': selectedStartTime,
      'esTime': selectedEsTime,
      'finishTime': selectedFinishTime,
      'stopHour': selectedStopHour,
      'issueStatus': selectedIssueStatus,
    };

    final setterMap = {
      'sendDate': (String? value) => selectedSendDate = value,
      'div': (String? value) => selectedDiv = value,
      'groupName': (String? value) => selectedGroupName = value,
      'machineCode': (String? value) => selectedMachineCode = value,
      'machineType': (String? value) => selectedMachineType = value,
      'statusCode': (String? value) => selectedStatusCode = value,
      'confirmDate': (String? value) => selectedConfirmDate = value,
      'sendTime': (String? value) => selectedSendTime = value,
      'startTime': (String? value) => selectedStartTime = value,
      'esTime': (String? value) => selectedEsTime = value,
      'finishTime': (String? value) => selectedFinishTime = value,
      'stopHour': (String? value) => selectedStopHour = value,
      'issueStatus': (String? value) => selectedIssueStatus = value,
    };

    if (!valueMap.containsKey(key)) {
      // Không khớp key -> render Text bình thường
      return _buildTableCell(title, isHeader: true);
    }

    String? selectedValue = valueMap[key];
    onChanged(value) {
      setState(() {
        setterMap[key]!(value == '__reset__' ? null : value);
        _applyFilter();
        _hasInput = _checkHasInput(); // kiểm tra tổng thể filter
      });
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
                  padding: EdgeInsets.only(left: 0),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              ...values.map(
                (v) => DropdownMenuItem<String>(
                  value: v,
                  child: Center(
                    child: Text(
                      v,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(110),
                2: FixedColumnWidth(160),
                3: FixedColumnWidth(150),
                4: FixedColumnWidth(200),
                5: FixedColumnWidth(140),
                6: FixedColumnWidth(160),
                7: FixedColumnWidth(160),
                8: FixedColumnWidth(145),
                9: FixedColumnWidth(120),
                10: FixedColumnWidth(125),
                11: FixedColumnWidth(130),
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
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 10,
                radius: const Radius.circular(5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(
                        color: theme.dividerColor.withOpacity(0.8),
                      ),
                      columnWidths: {
                        0: FixedColumnWidth(120),
                        1: FixedColumnWidth(110),
                        2: FixedColumnWidth(160),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(200),
                        5: FixedColumnWidth(140),
                        6: FixedColumnWidth(160),
                        7: FixedColumnWidth(160),
                        8: FixedColumnWidth(145),
                        9: FixedColumnWidth(120),
                        10: FixedColumnWidth(125),
                        11: FixedColumnWidth(130),
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
  }) {
    return Container(
      padding: isHeader ? EdgeInsets.only(top: 8) : null,
      // color: Colors.green,
      alignment: isHeader ? Alignment.center : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
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

  Uint8List createExcel(List<DetailsDataMachineStoppingModel> data) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Thêm tiêu đề đúng thứ tự các trường trong model
    sheet.appendRow([
      'sendDate',
      'div',
      'groupName',
      'machineCode',
      'machineType',
      'statusCode',
      'confirmDate',
      'sendTime',
      'startTime',
      'esTime',
      'finishTime',
      'stopHour',
      'issueStatus',
    ]);

    // Thêm dữ liệu từng dòng
    for (var item in data) {
      sheet.appendRow([
        item.sendDate,
        item.div,
        item.groupName,
        item.machineCode,
        item.machineType,
        item.statusCode,
        item.confirmDate,
        item.sendTime,
        item.startTime,
        item.esTime,
        item.finishTime,
        item.stopHour?.toStringAsFixed(2), // làm tròn 2 chữ số
        item.issueStatus,
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }
}
