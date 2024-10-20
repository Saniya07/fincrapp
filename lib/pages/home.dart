import 'package:fincr/pages/split_it_up/split_it_up.dart';
import 'package:fincr/pages/tracker/tracker.dart';
import 'package:flutter/material.dart';
import 'package:fincr/components/navigation.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigation(
      currentTab: 1,
      currentScreen: SplitItUp(),
    );
  }
}
