import 'package:fincr/assets/colors.dart';
import 'package:fincr/components/buttons.dart';
import 'package:fincr/components/listview.dart';
import 'package:fincr/components/modals/modals.dart';
import 'package:fincr/components/text.dart';
import 'package:fincr/constants/constants.dart';
import 'package:fincr/utils.dart';
import 'package:flutter/material.dart';

class AccountsSettings extends StatefulWidget {
  AccountsSettings({super.key});

  @override
  State<AccountsSettings> createState() => _AccountsSettingsState();
}

class _AccountsSettingsState extends State<AccountsSettings> {
  List<Map<String, dynamic>> accountsData = [];

  @override
  void initState() {
    super.initState();
    _getAndSetAccounts();
  }

  void _getAndSetAccounts() async {
    var data = await getFromTable(TABLENAMES.ACCOUNTS);

    for (var d in data) {
      d.putIfAbsent(
          "account_type", () => (d["is_credit_card"] ? "CREDIT" : "ACCOUNT"));
      d.putIfAbsent(
          "account_type",
          () =>
              (d["is_investment_account"] ? "INVESTMENT" : d["account_type"]));
    }
    setState(() {
      accountsData.clear();
      accountsData = data;
    });
  }

  void _onDeleteAccount(BuildContext _context, String id) {
    deleteFromTable(TABLENAMES.ACCOUNTS, "id", id);
    Navigator.pop(_context);
    _getAndSetAccounts();
  }

  void _onUpdateAccount(BuildContext _context, String id, String newAccountName,
      String accountType, String strAmount) async {
    Map<String, dynamic> payload = {
      "name": newAccountName,
      "amount": parseAmountFromString(strAmount)
    };
    if (accountType == "CREDIT") {
      payload.putIfAbsent("is_credit_card", () => true);
      payload.putIfAbsent("is_investment_account", () => false);
    } else if (accountType == "INVESTMENT") {
      payload.putIfAbsent("is_credit_card", () => false);
      payload.putIfAbsent("is_investment_account", () => true);
    } else {
      payload.putIfAbsent("is_credit_card", () => false);
      payload.putIfAbsent("is_investment_account", () => false);
    }

    Navigator.pop(_context);
    updateObjectInTable(TABLENAMES.ACCOUNTS, "id", id, payload);
    _getAndSetAccounts();
  }

  void _createAccount(BuildContext _context, String id, String name,
      String accountType, String strCurrentAmount) {
    if (name == '' || accountType == '' || strCurrentAmount == '') {
      showToast("Please fill all fields", Colors.red, Colors.white);
      return;
    }

    insertInTable(TABLENAMES.ACCOUNTS, {
      "name": name,
      "amount": strCurrentAmount,
      "is_credit_card": accountType == "CREDIT" ? true : false,
      "is_investment_account": accountType == "INVESTMENT" ? true : false
    });
    Navigator.pop(_context);
    _getAndSetAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.appColor,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                    child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const AppText(
                            text: "Accounts",
                            fontSize: 20,
                            textColor: Colors.white)
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AccountsSettingsListView(
                          data: accountsData,
                          onDeleteAccount: _onDeleteAccount,
                          onUpdateAccount: _onUpdateAccount),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PrimaryButton(
                          buttonText: "Add new Account",
                          buttonTextColor: CustomColors.appColor,
                          buttonColor: Colors.white,
                          buttonOutlineColor: Colors.white,
                          onPressed: () {
                            displayBottomSheetModalForAccount(context, {}, null,
                                null, null, null, _createAccount, null);
                          }),
                    )
                  ],
                )))));
  }
}
