import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/text.dart';
import 'package:flutter/material.dart';

class FilterSwitchTab extends StatefulWidget {
  final List<String> tabTitles;
  final ValueChanged<String> onFilterChange;

  const FilterSwitchTab(
      {super.key, required this.tabTitles, required this.onFilterChange});

  @override
  _FilterSwitchTabState createState() => _FilterSwitchTabState();
}

class _FilterSwitchTabState extends State<FilterSwitchTab> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: IntrinsicHeight(
            child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(30))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ...widget.tabTitles.asMap().entries.map((entry) {
          int idx = entry.key;
          String tabTitle = entry.value;
          bool isSelected = selectedIndex == idx;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = idx;
                });
                widget.onFilterChange(tabTitle);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CustomColors.appGrey // Replace with your selected color
                      : Colors.transparent, // Default background color
                  border: Border.all(
                      color: isSelected
                          ? CustomColors.appGrey
                          : CustomColors.appColor,
                      width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: AppText(
                  text: tabTitle,
                  fontSize: 20,
                  textColor: Colors.white,
                ),
              ),
            ),
          );
        }),
      ]),
    )));
  }
}
