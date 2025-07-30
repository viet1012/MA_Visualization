import 'package:flutter/material.dart';

class DivisionFilterChips extends StatelessWidget {
  final List<String> divisions;
  final List<String> selectedDivs;
  final void Function(String, bool) onSelectionChanged;

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
      runSpacing: 8,
      children:
          divisions.map((div) {
            final isSelected = selectedDivs.contains(div);
            return FilterChip(
              label: Text(div),
              selected: isSelected,
              onSelected: (bool selected) {
                onSelectionChanged(div, selected);
              },
              selectedColor: Colors.blueGrey,
              checkmarkColor: Colors.white,
            );
          }).toList(),
    );
  }
}
