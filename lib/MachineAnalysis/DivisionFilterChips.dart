import 'package:flutter/material.dart';

class DivisionFilterChips extends StatelessWidget {
  final List<String> divisions;
  final List<String> selectedDivs;
  final Function(String, bool) onSelectionChanged;

  const DivisionFilterChips({
    required this.divisions,
    required this.selectedDivs,
    required this.onSelectionChanged,
    super.key,
  });

  bool get isKVHSelected => selectedDivs.contains('KVH');
  bool get isOtherSelected =>
      selectedDivs.any((div) => div != 'KVH'); // PRESS/MOLD/GUIDE selected

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children:
          divisions.map((div) {
            bool isSelected = selectedDivs.contains(div);

            // Logic disable:
            bool isDisabled = false;
            if (div == 'KVH' && isOtherSelected) {
              isDisabled = true;
            } else if (div != 'KVH' && isKVHSelected) {
              isDisabled = true;
            }

            return FilterChip(
              label: Text(div),
              selected: isSelected,
              onSelected:
                  isDisabled
                      ? null
                      : (selected) {
                        onSelectionChanged(div, selected);
                      },
            );
          }).toList(),
    );
  }
}
