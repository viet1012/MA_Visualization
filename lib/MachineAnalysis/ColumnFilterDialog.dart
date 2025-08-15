import 'package:flutter/material.dart';

class ColumnFilterDialog extends StatefulWidget {
  final String columnName;
  final Set<String> uniqueValues;
  final Set<String> selectedValues;

  const ColumnFilterDialog({
    Key? key,
    required this.columnName,
    required this.uniqueValues,
    required this.selectedValues,
  }) : super(key: key);

  @override
  _ColumnFilterDialogState createState() => _ColumnFilterDialogState();
}

class _ColumnFilterDialogState extends State<ColumnFilterDialog> {
  late Set<String> tempFilters;

  @override
  void initState() {
    super.initState();
    tempFilters = Set<String>.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.filter_alt, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filter: ${widget.columnName}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        height: 400,
        width: 400, // max width dialog
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${widget.uniqueValues.length} values',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Selected: ${tempFilters.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

            // Select/Clear all buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        tempFilters.addAll(widget.uniqueValues);
                      });
                    },
                    icon: Icon(Icons.select_all, size: 16),
                    label: Text('Select All'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.green[50],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        tempFilters.clear();
                      });
                    },
                    icon: Icon(Icons.clear_all, size: 16),
                    label: Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.red[50],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Checkbox list
            Expanded(
              child: ListView.builder(
                itemCount: widget.uniqueValues.length,
                itemBuilder: (context, index) {
                  final value = widget.uniqueValues.elementAt(index);
                  final isSelected = tempFilters.contains(value);

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                      ), // width tối đa cho mỗi item
                      child: CheckboxListTile(
                        dense: true,
                        title: Text(
                          value,
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis, // cắt text dài
                        ),
                        value: isSelected,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true)
                              tempFilters.add(value);
                            else
                              tempFilters.remove(value);
                          });
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(tempFilters),
          child: Text('Apply Filter'),
        ),
      ],
    );
  }
}
