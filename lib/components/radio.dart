import 'package:flutter/material.dart';

class RadioButtons extends StatefulWidget {
  final Map<String, String> radioMap;
  final ValueChanged<String> onChangedRadio;
  final String initialSelectedValue;

  const RadioButtons(
      {super.key,
      required this.radioMap,
      required this.onChangedRadio,
      required this.initialSelectedValue});

  @override
  State<RadioButtons> createState() => _RadioButtonsState();
}

class _RadioButtonsState extends State<RadioButtons> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    // Initialize selectedValue with the first value in the map, or you can customize this.
    selectedValue = widget.initialSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = widget.radioMap.keys.toList();

    return Column(
      children: <Widget>[
        ...labels.map((label) => ListTile(
              title: Text(
                label,
                style: TextStyle(
                  color: widget.radioMap[label] == selectedValue
                      ? Colors.blue // Color when selected
                      : Colors.black, // Color when not selected
                ),
              ),
              leading: Radio<String>(
                value: widget.radioMap[label]!, // Safe unwrap with !
                groupValue: selectedValue,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onChangedRadio(value);
                  }
                },
              ),
            )),
      ],
    );
  }
}
