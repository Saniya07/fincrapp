import 'package:fincr/pages/add/add.dart';
import 'package:fincr/pages/settings/settings.dart';
import 'package:fincr/pages/split_it_up/split_it_up.dart';
import 'package:fincr/pages/tracker/tracker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fincr/assets/colors.dart';

class AppNavigation extends StatefulWidget {
  int currentTab = 0;
  int previousTab = 0;
  Widget currentScreen;

  AppNavigation(
      {super.key, required this.currentTab, required this.currentScreen});

  @override
  _AppNavigationState createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  final pageStorageBucket = PageStorageBucket();

  Column getAppNavigationItem(screen, tab, tabText, tabIcon) {
    if (tabText == "Add") {
      if (widget.currentTab != 2) {
        widget.previousTab = widget.currentTab;
      }
      return Column(
        children: [
          SizedBox(height: widget.currentTab == tab ? 8 : 12),
          MaterialButton(
              splashColor: CustomColors.appColor,
              onPressed: () {
                setState(() {
                  widget.currentScreen = DynamicAdd(
                    fromScreenNumber: widget.previousTab,
                  );
                  widget.currentTab = tab;
                });
              },
              minWidth: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Icon(tabIcon, size: 30, color: CustomColors.appColor),
                  ),
                ],
              )),
        ],
      );
    }
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.only(bottom: 2),
          height: 4,
          width: 68,
          decoration: BoxDecoration(
              color: widget.currentTab == tab
                  ? Colors.white
                  : CustomColors.appColor),
        ),
        SizedBox(height: widget.currentTab == tab ? 8 : 12),
        MaterialButton(
            splashColor: CustomColors.appColor,
            onPressed: () {
              setState(() {
                widget.currentScreen = screen;
                widget.currentTab = tab;
              });
            },
            minWidth: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tabIcon,
                    size: 30,
                    color: widget.currentTab == tab
                        ? Colors.white
                        : CustomColors.appGrey),
                Text(
                  tabText,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: widget.currentTab == tab
                          ? Colors.white
                          : CustomColors.appGrey),
                ),
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: pageStorageBucket, child: widget.currentScreen),
      bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: CustomColors.appColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 0,
          height: 80,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getAppNavigationItem(
                    const Tracker(), 0, "Tracker", Icons.receipt_long),
                getAppNavigationItem(
                    const SplitItUp(), 1, "Split", Icons.safety_divider),
                getAppNavigationItem(DynamicAdd(), 2, "Add", Icons.add),
                getAppNavigationItem(
                    const Tracker(), 3, "Finols", Icons.track_changes),
                getAppNavigationItem(
                    const Settings(), 4, "Settings", Icons.settings),
              ],
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     getAppNavigationItem(
            //         currentScreen, 2, "Finols", Icons.track_changes),
            //     getAppNavigationItem(
            //         const Tracker(), 3, "Settings", Icons.settings),
            //   ],
            // )
          )),
    );
  }
}

class FilterTab extends StatelessWidget {
  final List<String> tabTitles;
  final List<Container> tabViews;

  const FilterTab({super.key, required this.tabTitles, required this.tabViews});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: CustomColors.appColor,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: CustomColors.appPrimaryColor,
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(7),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: const BoxDecoration(
                      color: CustomColors.appColor,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    labelColor: CustomColors.appPrimaryColor,
                    unselectedLabelColor: CustomColors.appColor,
                    tabs: tabTitles
                        .map((title) => FilterTabItem(title: title))
                        .toList(),
                  )),
            ),
          ),
        ),
        body: Container(
          color: CustomColors.appColor,
          child: TabBarView(children: tabViews),
        ),
      ),
    );
  }
}

class FilterTabItem extends StatelessWidget {
  final String title;

  const FilterTabItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
