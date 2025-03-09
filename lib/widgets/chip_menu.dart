import 'package:flutter/material.dart';
import 'package:user/models/category_list_model.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/screens/search_results_screen.dart';
import 'package:user/utils/navigation_utils.dart';

import 'my_chip.dart';

class ChipMenu extends StatefulWidget {
  @required
  final List<Product>? trendingSearchProductList;
  final List<String>? selectedItems;
  final List<CategoryList>? categoryList;
  @required
  final Function(String)? onChanged;
  final int? screenId;
  final dynamic analytics;
  final dynamic observer;

  const ChipMenu({super.key, this.trendingSearchProductList, this.onChanged, this.selectedItems, this.categoryList, this.screenId, this.analytics, this.observer});

  @override
  State<ChipMenu> createState() => _ChipMenuState();
}

class _ChipMenuState extends State<ChipMenu> {
  int? _selectedIndex;

  _ChipMenuState();

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 4.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        children: widget.screenId == 1 ? _categoryList() : _productList());
  }

  List<Widget> _categoryList() {
    List<Widget> categoriesList = [];
    for (int i = 0; i < widget.categoryList!.length; i++) {
      categoriesList.add(MyChip(
        key: UniqueKey(),
        label: widget.categoryList![i].title,
        isSelected: false,
        onPressed: () {},
      ));
    }
    return categoriesList;
  }

  List<Widget> _productList() {
    List<Widget> trendingSearchProducts = [];
    for (int i = 0; i < widget.trendingSearchProductList!.length; i++) {
      trendingSearchProducts.add(MyChip(
        key: UniqueKey(),
        label: widget.trendingSearchProductList![i].productName,
        isSelected: widget.trendingSearchProductList![i].isSelected,
        onPressed: () {
          widget.trendingSearchProductList!.map((e) => e.isSelected = false).toList();
          setState(() {
            _selectedIndex = i;
            if (_selectedIndex == i) {
              widget.trendingSearchProductList![i].isSelected = true;
            }
          });
          Navigator.of(context).push(NavigationUtils.createAnimatedRoute(
              1.0,
              SearchResultsScreen(
                analytics: widget.analytics,
                observer: widget.observer,
                searchParams: widget.trendingSearchProductList![i].productName,
              )));
        },
      ));
    }
    return trendingSearchProducts;
  }
}
