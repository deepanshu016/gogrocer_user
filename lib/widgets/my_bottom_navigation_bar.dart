import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user/controllers/home_controller.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final Function(int)? onTap;

  const MyBottomNavigationBar({super.key, this.onTap});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  HomeController homeController = Get.find();

  _MyBottomNavigationBarState();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: homeController.tabIndex,
      onDestinationSelected: (value) {
        setState(() {
          if (value != 1) {
            homeController.changeTabIndex(value);
          }
          widget.onTap!(value);
        });
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          label: AppLocalizations.of(context)!.txt_home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          label: AppLocalizations.of(context)!.txt_search,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_outlined),
          label: AppLocalizations.of(context)!.tle_order,
        ),
        NavigationDestination(
            icon: const Icon(Icons.account_circle_outlined),
            label: AppLocalizations.of(context)!.txt_profile
        )
      ],
    );
  }
}
