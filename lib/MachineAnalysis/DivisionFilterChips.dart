import 'package:flutter/material.dart';

class DivisionFilterChips extends StatelessWidget {
  final List<String> divisions;
  final List<String> selectedDivs;
  final Function(List<String>) onSelectionChanged; // đổi callback nhận list mới

  const DivisionFilterChips({
    required this.divisions,
    required this.selectedDivs,
    required this.onSelectionChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children:
          divisions.map((div) {
            bool isSelected = selectedDivs.contains(div);

            return FilterChip(
              label: Text(div),
              selected: isSelected,
              onSelected: (selected) {
                List<String> newSelected = List.from(selectedDivs);
                if (selected) {
                  if (div == 'KVH') {
                    // chọn KVH thì bỏ hết nhóm khác
                    newSelected = ['KVH'];
                  } else {
                    // chọn nhóm khác thì bỏ KVH nếu có
                    newSelected.remove('KVH');
                    newSelected.add(div);
                  }
                } else {
                  // bỏ chọn nhóm này
                  newSelected.remove(div);
                }

                // Không cho phép bỏ hết hết nhóm (bắt buộc phải chọn ít nhất 1 nhóm)
                if (newSelected.isEmpty) {
                  newSelected.add(div);
                }

                onSelectionChanged(newSelected);
              },
            );
          }).toList(),
    );
  }
}
