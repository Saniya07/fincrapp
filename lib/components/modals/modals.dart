import 'package:contacts_service/contacts_service.dart';
import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/radio.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/permissions.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fincr/components/modals/modal_utils.dart';

class ColorPickerModal extends StatelessWidget {
  final Color existingColor;
  final ValueChanged<Color> onColorSelect;

  const ColorPickerModal({
    super.key,
    required this.existingColor,
    required this.onColorSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a Color'),
      content: MaterialPicker(
        pickerColor: existingColor,
        onColorChanged: onColorSelect,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class IconPicker extends StatelessWidget {
  final ValueChanged<IconData> onIconSelected;

  IconPicker({required this.onIconSelected});

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.home,
      Icons.star,
      Icons.favorite,
      Icons.person,
      Icons.settings,
      Icons.lunch_dining,
      Icons.directions_car,
      Icons.directions_bike,
      Icons.payments,
      Icons.attach_money,
      Icons.account_balance_wallet
      // Add more icons as needed
    ];

    return AlertDialog(
      title: Text('Select an Icon'),
      content: Container(
        width: double.maxFinite,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Number of icons per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                onIconSelected(icons[index]);
                Navigator.pop(context);
              },
              child: Icon(
                icons[index],
                size: 36,
                color: Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> displayBottomSheetModalForCategory(
    BuildContext context,
    String id,
    String categoryType,
    ValueNotifier<Color>? colorNotifier,
    ValueNotifier<String>? iconNotifier,
    VoidCallback? resetChanges,
    ValueChanged<String>? onDelete,
    void Function(BuildContext, String, String, String, String, String)? onDone,
    TextEditingController? headingController) {
  // Set default values if parameters are not provided
  final ValueNotifier<Color> _colorNotifier =
      colorNotifier ?? ValueNotifier<Color>(Colors.blue);
  final ValueNotifier<String> _iconNotifier =
      iconNotifier ?? ValueNotifier<String>('U+EB94');
  final VoidCallback _resetChanges =
      resetChanges ?? () {/* Default implementation */};
  final ValueChanged<String> _onDelete =
      onDelete ?? (id) {/* Default implementation */};
  final void Function(BuildContext, String, String, String, String, String)
      _onDone = onDone ??
          (context, id, heading, icon, color, categType) {
            /* Default implementation */
          };
  final TextEditingController _headingController =
      headingController ?? TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CustomColors.appColor,
    builder: (BuildContext context) {
      final double availableHeight = MediaQuery.of(context).size.height * 0.8;
      return ValueListenableBuilder<Color>(
        valueListenable: _colorNotifier,
        builder: (context, color, _) {
          return ValueListenableBuilder<String>(
            valueListenable: _iconNotifier,
            builder: (context, icon, _) {
              return Wrap(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    constraints: BoxConstraints(
                      maxHeight: availableHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: CustomColors.appGrey,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(4),
                                color: CustomColors.appColor,
                                onPressed: () {
                                  _resetChanges;
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close, size: 36),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: CustomColors.appGrey,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(4),
                                color: CustomColors.appColor,
                                onPressed: () {
                                  Navigator.pop(context);
                                  _onDelete(id);
                                },
                                icon: const Icon(Icons.delete,
                                    size: 36, color: CustomColors.appRed),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.appColor,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            minimumSize: Size(80, 80),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Container(
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                getIconDataFromString(icon),
                                color: Colors.white,
                                size: 36.0,
                              ),
                            ),
                          ),
                          onPressed: () {
                            showIconPicker(context, _iconNotifier);
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: CustomColors.appColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(60, 60),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color,
                                    border: Border.all(
                                      color: color,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                ),
                                onPressed: () {
                                  showColorPicker(context, _colorNotifier);
                                },
                              ),
                            ),
                            Expanded(
                              child: AppTextInput(
                                placeholder: "",
                                keyboardType: TextInputType.text,
                                controller: _headingController,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                            buttonText: "Done",
                            buttonTextColor: CustomColors.appColor,
                            buttonColor: Colors.white,
                            buttonOutlineColor: Colors.white,
                            onPressed: () {
                              _onDone(
                                  context,
                                  id,
                                  _headingController.text,
                                  _iconNotifier.value,
                                  convertDartColorToHexcode(
                                      _colorNotifier.value),
                                  categoryType);
                            })
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

Future<void> displayBottomSheetModalForAccount(
    BuildContext context,
    Map<String, dynamic>? accountData,
    ValueNotifier<Color>? colorNotifier,
    ValueNotifier<String>? iconNotifier,
    VoidCallback? resetChanges,
    void Function(BuildContext, String)? onDelete,
    void Function(BuildContext, String, String, String, String)? onDone,
    TextEditingController? headingController) {
  // Set default values if parameters are not provided
  final ValueNotifier<Color> _colorNotifier =
      colorNotifier ?? ValueNotifier<Color>(Colors.blue);
  final ValueNotifier<String> _iconNotifier =
      iconNotifier ?? ValueNotifier<String>('U+EB94');
  final VoidCallback _resetChanges =
      resetChanges ?? () {/* Default implementation */};
  final void Function(BuildContext, String) _onDelete =
      onDelete ?? (_context, id) {/* Default implementation */};
  final Function _onDone = onDone ??
      (context, id, newAccountName, accountType, strAmount) {
        /* Default implementation */
      };
  final TextEditingController _headingController =
      headingController ?? TextEditingController();

  final TextEditingController _amountController = TextEditingController(
      text: (accountData?["amount"] is num
          ? (accountData?["amount"] as num).toStringAsFixed(2)
          : "0.00"));

  String selectedRadio = accountData?["account_type"] ?? "CREDIT";

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: CustomColors.appColor,
    builder: (BuildContext context) {
      final double availableHeight = MediaQuery.of(context).size.height * 0.8;
      return ValueListenableBuilder<Color>(
        valueListenable: _colorNotifier,
        builder: (context, color, _) {
          return ValueListenableBuilder<String>(
            valueListenable: _iconNotifier,
            builder: (context, icon, _) {
              return Wrap(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    constraints: BoxConstraints(
                      maxHeight: availableHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: CustomColors.appGrey,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(4),
                                color: CustomColors.appColor,
                                onPressed: () {
                                  _resetChanges();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close, size: 36),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: CustomColors.appGrey,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(4),
                                color: CustomColors.appColor,
                                onPressed: () {
                                  _onDelete(context, accountData?["id"]);
                                },
                                icon: const Icon(Icons.delete,
                                    size: 36, color: CustomColors.appRed),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        RadioButtons(
                            radioMap: const {
                              "Credit Card": "CREDIT",
                              "Investment Account": "INVESTMENT",
                              "Account": "ACCOUNT"
                            },
                            onChangedRadio: (String selRad) {
                              selectedRadio = selRad;
                            },
                            initialSelectedValue:
                                accountData?["account_type"] ?? "CREDIT"),
                        Expanded(
                          child: AppTextInput(
                            placeholder: "",
                            keyboardType: TextInputType.text,
                            controller: _headingController,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                            child: DecimalInputField(
                                controller: _amountController)),
                        const SizedBox(height: 10),
                        PrimaryButton(
                            buttonText: "Done",
                            buttonTextColor: CustomColors.appColor,
                            buttonColor: Colors.white,
                            buttonOutlineColor: Colors.white,
                            onPressed: () {
                              _onDone(
                                  context,
                                  accountData?["id"] ??
                                      "", // Fallback to empty string if null
                                  _headingController.text,
                                  selectedRadio ??
                                      "CREDIT", // Fallback to "CREDIT" if null
                                  _amountController.text);
                            })
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

openContactList(BuildContext context) async {
  if (await requestContactPermission()) {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Contact"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                Contact contact = contacts.elementAt(index);
                return ListTile(
                  title: Text(contact.displayName ?? "No Name"),
                  onTap: () {
                    // Handle contact selection
                    Navigator.of(context).pop(contact);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  } else {
    // Handle the case when the permission is not granted
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Denied"),
          content: Text("Contact permission is required to add people."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void openSelectableListView(
    BuildContext context,
    List<Map<String, dynamic>> items,
    List<Map<String, dynamic>> selectedItems,
    Function(List<Map<String, dynamic>>, String) onSelected,
    String whatIsSelected,
    {bool isMultiSelect = true}) {
  TextEditingController _controller = TextEditingController();

  showModalBottomSheet(
    backgroundColor: CustomColors.appColor,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedItems.contains(items[index]);

                      return Container(
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                          color: CustomColors.appColor,
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 4),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: items[index]["name"] ?? "",
                                  fontSize: 20,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage:
                                    items[index]["profile_picture"] != "" &&
                                            items[index]["profile_picture"]
                                                .isNotEmpty
                                        ? NetworkImage(
                                                items[index]["profile_picture"])
                                            as ImageProvider
                                        : const AssetImage(
                                            "lib/assets/netflix.jpg"),
                                minRadius: 10,
                                maxRadius: 26,
                              ),
                            ),
                            trailing: isMultiSelect
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setModalState(() {
                                        if (value == true) {
                                          selectedItems.add(items[index]);
                                        } else {
                                          selectedItems.remove(items[index]);
                                        }
                                      });
                                    },
                                  )
                                : Radio(
                                    value: items[index],
                                    groupValue: selectedItems.isNotEmpty
                                        ? selectedItems.first
                                        : null,
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedItems.clear();
                                        selectedItems
                                            .add(value as Map<String, dynamic>);
                                      });
                                    },
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelected(selectedItems, whatIsSelected);
                  },
                  child: const Text("Done"),
                ),
              )
            ],
          );
        },
      );
    },
  );
}
