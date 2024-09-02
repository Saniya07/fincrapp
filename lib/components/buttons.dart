import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final Color buttonTextColor;
  final Color buttonColor;
  final Color buttonOutlineColor;
  double width = 380;
  double height = 52;
  final VoidCallback? onPressed;

  PrimaryButton({
    super.key,
    required this.buttonText,
    required this.buttonTextColor,
    required this.buttonColor,
    required this.buttonOutlineColor,
    this.width = 380,
    this.height = 52,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        // foregroundColor: colorScheme.onError,
        foregroundColor: CustomColors.appColor,
        backgroundColor: buttonColor,
        fixedSize: Size(width, height),
        shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: buttonOutlineColor, width: 2)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: GoogleFonts.poppins(
          fontSize: 20,
          color: buttonTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MultiButtonRow extends StatelessWidget {
  final List<String> buttonTexts;
  final List<Icon> buttonIcons;

  const MultiButtonRow(
      {super.key, required this.buttonTexts, required this.buttonIcons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(buttonTexts.length, (index) {
        return Column(
          children: [
            CircleAvatar(
                minRadius: 10, maxRadius: 20, child: buttonIcons[index])
          ],
        );
      }),
    );
  }
}

class IconButtonRow extends StatefulWidget {
  final String userId;
  final List<String> selectedPeopleIds;
  final TextEditingController amountToSplitController;

  final Map<String, IconData> iconsMap;
  final Function(String, Map<String, double>) onIconSelected;

  final Map<String, double> alreadySplit;
  String selectedSplitMethod = "";

  final Map<String, Map<String, dynamic>> selectedPeopleDataMap;
  Map<String, TextEditingController> peopleSplitControllers;

  IconButtonRow({
    super.key,
    required this.userId,
    required this.selectedPeopleDataMap,
    required this.selectedPeopleIds,
    required this.amountToSplitController,
    required this.alreadySplit,
    required this.iconsMap,
    required this.onIconSelected,
    this.selectedSplitMethod = "",
  }) : peopleSplitControllers = {
          for (var peopleId in selectedPeopleIds)
            peopleId: TextEditingController(
                text: (alreadySplit[peopleId] ?? 0.00).toStringAsFixed(2))
        };

  @override
  _IconButtonRowState createState() => _IconButtonRowState();
}

class _IconButtonRowState extends State<IconButtonRow> {
  int? selectedIconIndex;
  double totalAmount = 0.00;

  @override
  void initState() {
    super.initState();

    if (widget.selectedSplitMethod.isNotEmpty) {
      int index = 0;
      for (var data in widget.iconsMap.keys.toList()) {
        if (data == widget.selectedSplitMethod) {
          selectedIconIndex = index;
        }
        index += 1;
      }
    }

    totalAmount = calculateTotalAmount();
  }

  double calculateTotalAmount() {
    double _totalAmount = 0.00;
    for (var key in widget.peopleSplitControllers.keys.toList()) {
      _totalAmount +=
          parseAmountFromString(widget.peopleSplitControllers[key]?.text ?? "");
    }
    return _totalAmount;
  }

  void _updateTotal() {
    // Delay the setState until after the current build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        totalAmount = calculateTotalAmount();
      });
    });
  }

  void _openModal(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Split by ${widget.iconsMap.keys.toList()[index]}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...widget.peopleSplitControllers.entries
                      .map((entry) => Row(
                            children: [
                              AppText(
                                  text: widget.selectedPeopleDataMap[entry.key]
                                          ?["name"] ??
                                      "hello",
                                  fontSize: 12,
                                  textColor: Colors.black),
                              Flexible(
                                child: DecimalInputField(
                                  controller: entry.value,
                                  textColor: Colors.black,
                                  onChanged: (text) {
                                    setModalState(() {
                                      totalAmount = calculateTotalAmount();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                  const SizedBox(height: 12),
                  AppText(
                    text:
                        "$totalAmount/${parseAmountFromString(widget.amountToSplitController.text)}",
                    fontSize: 16,
                    textColor: totalAmount <
                            parseAmountFromString(
                                widget.amountToSplitController.text)
                        ? Colors.black
                        : (totalAmount >
                                parseAmountFromString(
                                    widget.amountToSplitController.text)
                            ? CustomColors.appRed
                            : CustomColors.appGreen),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (totalAmount !=
                              parseAmountFromString(
                                  widget.amountToSplitController.text)) {
                            showToast("Split doesn't add up to total",
                                Colors.red, Colors.black);
                            return;
                          }
                          setState(() {
                            selectedIconIndex = index;
                            widget.onIconSelected(
                              widget.iconsMap.keys.toList()[index],
                              {
                                for (var peopleId in widget.selectedPeopleIds)
                                  peopleId: parseAmountFromString(widget
                                          .peopleSplitControllers[peopleId]
                                          ?.text ??
                                      "0.00")
                              },
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Select'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.iconsMap.keys.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (widget.selectedPeopleIds.isEmpty ||
                  widget.userId.isEmpty ||
                  widget.amountToSplitController.text.isEmpty ||
                  widget.amountToSplitController.text == "0.00") {
                showToast("Fill the amount and select a friend first",
                    Colors.red, Colors.white);
                return;
              }
              _openModal(context, index);
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: selectedIconIndex == index
                    ? Colors.blueAccent
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.iconsMap.values.toList()[index],
                color: selectedIconIndex == index ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
