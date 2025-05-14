import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../Model/DetailsDataModel.dart';

class DetailsDataPopup extends StatefulWidget {
  final String title;
  final List<DetailsDataModel> data;
  final double totalActual;
  final String group;

  DetailsDataPopup({
    Key? key,
    required this.title,
    required this.data,
    required this.totalActual,
    required this.group,
  }) : super(key: key);

  @override
  State<DetailsDataPopup> createState() => _DetailsDataPopupState();
}

class _DetailsDataPopupState extends State<DetailsDataPopup> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _filterController = TextEditingController();
  late List<DetailsDataModel> filteredData;
  double costLoss = 0;

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
    _filterController.addListener(_applyFilterForInputField);

    costLoss = filteredData.fold<double>(0, (sum, item) => (sum + item.amount));
  }

  void _applyFilterForInputField() {
    final query = _filterController.text.toLowerCase();
    setState(() {
      filteredData =
          widget.data.where((item) {
            return item.dept.toLowerCase().contains(query) ||
                item.maktx.toLowerCase().contains(query) ||
                item.xblnr2.toLowerCase().contains(query) ||
                item.bktxt.toLowerCase().contains(query) ||
                item.matnr.toLowerCase().contains(query) ||
                item.useDate.toLowerCase().contains(query) ||
                item.unit.toLowerCase().contains(query) ||
                item.qty.toString().toLowerCase().contains(query) ||
                item.amount.toString().toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _getUniqueValues(String Function(DetailsDataModel) selector) {
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
    );
  }

  void _resetFilter() {
    setState(() {
      _filterController.clear();
      selectedXblnr2 = null;
      selectedMaktx = null;
      selectedMatnr = null;
      selectedDept = null;
      selectedUnit = null;
      selectedDept = null;
      selectedUsedDate = null;
      selectedBktxt = null;
      selectedNote = null;
      filteredData = widget.data;
    });
  }

  Widget _buildHeader(ThemeData theme) {
    // Tính tổng amount
    final totalAmount = filteredData.fold<double>(
      0,
      (sum, item) => (sum + item.amount),
    );

    double diff = widget.totalActual - (costLoss / 1000);

    // Nếu độ lệch nhỏ hơn 0.01 thì coi như bằng 0
    if (diff.abs() < 0.01) {
      diff = 0;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              children: [
                // widget.group != "PE"
                //     ? Text(
                //       "Share: ${diff.toStringAsFixed(1)}K\$",
                //       style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 18,
                //       ),
                //     )
                //     : SizedBox(),
                // SizedBox(width: 16),
                Text(
                  "Total: ${(totalAmount / 1000).toStringAsFixed(1)}K\$",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(width: 16),
                FilledButton.icon(
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('Refresh'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
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
              hintText: 'Search by Dept, Material No., Description, Note...',
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
  String? selectedMatnr;
  String? selectedMaktx;
  String? selectedXblnr2;
  String? selectedUnit;
  String? selectedUsedDate;
  String? selectedBktxt;
  String? selectedNote;

  void _applyFilter() {
    final query = _filterController.text.toLowerCase();
    setState(() {
      filteredData =
          widget.data.where((item) {
            final matchesSearch =
                item.dept.toLowerCase().contains(query) ||
                item.maktx.toLowerCase().contains(query) ||
                item.xblnr2.toLowerCase().contains(query) ||
                item.bktxt.toLowerCase().contains(query) ||
                item.matnr.toLowerCase().contains(query) ||
                item.useDate.toLowerCase().contains(query) ||
                item.unit.toLowerCase().contains(query) ||
                item.qty.toString().toLowerCase().contains(query) ||
                item.amount.toString().toLowerCase().contains(query);
            final matchesDept =
                selectedDept == null || item.dept == selectedDept;
            final matchesMatnr =
                selectedMatnr == null || item.matnr == selectedMatnr;
            final matchesMaktx =
                selectedMaktx == null || item.maktx == selectedMaktx;
            final matchesXblnr2 =
                selectedXblnr2 == null || item.xblnr2 == selectedXblnr2;
            final matchesUnit =
                selectedUnit == null || item.unit == selectedUnit;
            final matchesUsedDate =
                selectedUsedDate == null || item.useDate == selectedUsedDate;
            final matchesBktxt =
                selectedBktxt == null || item.bktxt == selectedBktxt;

            return matchesSearch &&
                matchesDept &&
                matchesMatnr &&
                matchesMaktx &&
                matchesXblnr2 &&
                matchesUnit &&
                matchesUsedDate &&
                matchesBktxt;
          }).toList();
    });
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
                  child: Center(
                    child: Text(
                      v,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,

        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Sticky Header (dòng tiêu đề)
            Table(
              border: TableBorder.all(
                color: theme.dividerColor.withOpacity(0.8),
              ),
              columnWidths: {
                0: FixedColumnWidth(130),
                1: FixedColumnWidth(150),
                2: FixedColumnWidth(500),
                3: FixedColumnWidth(150),
                4: FixedColumnWidth(220),
                5: FixedColumnWidth(220),
                6: FixedColumnWidth(100),
                7: FixedColumnWidth(100),
                8: FixedColumnWidth(120),
              },
              children: [
                TableRow(
                  children: [
                    _buildDropdownHeader(
                      title: 'Dept',
                      selectedValue: selectedDept,
                      values: _getUniqueValues((e) => e.dept),
                      onChanged: (value) {
                        setState(() {
                          selectedDept = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildDropdownHeader(
                      title: 'Material No',
                      selectedValue: selectedMatnr,
                      values: _getUniqueValues((e) => e.matnr),
                      onChanged: (value) {
                        setState(() {
                          selectedMatnr = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildDropdownHeader(
                      title: 'Description',
                      selectedValue: selectedMaktx,
                      values: _getUniqueValues((e) => e.maktx),
                      onChanged: (value) {
                        setState(() {
                          selectedMaktx = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildDropdownHeader(
                      title: 'Used Date',
                      selectedValue: selectedUsedDate,
                      values: _getUniqueValues((e) => e.useDate),
                      onChanged: (value) {
                        setState(() {
                          selectedUsedDate = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildDropdownHeader(
                      title: 'Doc Number',
                      selectedValue: selectedXblnr2,
                      values: _getUniqueValues((e) => e.xblnr2),
                      onChanged: (value) {
                        setState(() {
                          selectedXblnr2 = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildDropdownHeader(
                      title: 'BKTXT',
                      selectedValue: selectedBktxt,
                      values: _getUniqueValues((e) => e.bktxt),
                      onChanged: (value) {
                        setState(() {
                          selectedBktxt = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildTableCell('Qty', isHeader: true),
                    _buildDropdownHeader(
                      title: 'Unit',
                      selectedValue: selectedUnit,
                      values: _getUniqueValues((e) => e.unit),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value;
                          _applyFilter();
                        });
                      },
                    ),
                    _buildTableCell('Amount \$', isHeader: true),
                  ],
                ),
              ],
            ),
            // Scrollable content
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
                        0: FixedColumnWidth(130),
                        1: FixedColumnWidth(150),
                        2: FixedColumnWidth(500),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(220),
                        5: FixedColumnWidth(220),
                        6: FixedColumnWidth(100),
                        7: FixedColumnWidth(100),
                        8: FixedColumnWidth(120),
                      },
                      children:
                          filteredData.map((item) {
                            return TableRow(
                              children: [
                                _buildTableCell(item.dept),
                                _buildTableCell(item.matnr),
                                _buildTableCell(item.maktx),
                                _buildTableCell(item.useDate),
                                _buildTableCell(item.xblnr2),
                                _buildTableCell(item.bktxt),
                                _buildTableCell(
                                  item.qty.toString(),
                                  isNumber: true,
                                ),
                                _buildTableCell(item.unit),
                                _buildTableCell(
                                  item.amount.toStringAsFixed(2),
                                  isNumber: true,
                                ),
                              ],
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

  Uint8List createExcel(List<DetailsDataModel> data) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Thêm tiêu đề
    sheet.appendRow([
      'Dept',
      'matnr',
      'kostl',
      'Used Date',
      'Doc Number',
      'Note',
      'Qty',
      'Unit',
      'Amount',
    ]);

    // Thêm dữ liệu
    for (var item in data) {
      sheet.appendRow([
        item.dept,
        item.matnr,
        item.maktx,
        item.useDate,
        item.xblnr2,
        item.bktxt,
        item.qty,
        item.unit,
        item.amount,
      ]);
    }

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes!);
  }
}
