import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:user/models/product_filter_model.dart';
import 'package:user/widgets/bottom_button.dart';

class FilterScreen extends StatefulWidget {
  final ProductFilter productFilter;
  final bool? isProductAvailable;
  const FilterScreen(this.productFilter, {super.key, this.isProductAvailable});
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int? _selectedName = 0;
  int? _selectedRating;
  int? _selectedDiscount;
  bool? _isInStock = false;
  bool? _isOutOfStock = false;
  RangeValues _currentRangeValues = const RangeValues(0, 0);

  _FilterScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.tle_filter_option,
            style: textTheme.titleLarge,
          ),
          leading: InkWell(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    widget.productFilter.maxPrice = widget.productFilter.minPrice = widget.productFilter.maxDiscount = widget.productFilter.minDiscount = widget.productFilter.minRating = widget.productFilter.maxRating = widget.productFilter.stock = widget.productFilter.byname = null;
                    Navigator.of(context).pop(widget.productFilter);
                  },
                  child: Text(
                    "${AppLocalizations.of(context)!.tle_reset} ",
                    style: textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 10),
                    child: Text(
                      AppLocalizations.of(context)!.lbl_sort_by_name,
                      style: textTheme.titleLarge,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Radio(
                      value: 1,
                      groupValue: _selectedName,
                      onChanged: (dynamic val) {
                        _selectedName = val;
                        setState(() {});
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.txt_A_Z,
                      style: _selectedName == 1 ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Radio(
                          value: 2,
                          groupValue: _selectedName,
                          onChanged: (dynamic val) {
                            _selectedName = val;
                            setState(() {});
                          }),
                    ),
                    Text(
                      AppLocalizations.of(context)!.txt_Z_A,
                      style: _selectedName == 2 ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      AppLocalizations.of(context)!.lbl_sort_by_price,
                      style: textTheme.titleLarge,
                    ),
                  ),
                ),
                RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: double.parse(widget.productFilter.maxPriceValue.toString()),
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Colors.grey[500],
                  // divisions: (productFilter.maxPriceValue.round()),
                  labels: RangeLabels(
                    _currentRangeValues.start.round().toString(),
                    _currentRangeValues.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                    });
                  },
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      AppLocalizations.of(context)!.lbl_sort_by_discount,
                      style: textTheme.titleLarge,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Radio(
                      value: 7,
                      groupValue: _selectedDiscount,
                      onChanged: (dynamic val) {
                        _selectedDiscount = val;
                        setState(() {});
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.lbl_10_25_percent,
                      style: _selectedDiscount == 7 ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Radio(
                          value: 8,
                          groupValue: _selectedDiscount,
                          onChanged: (dynamic val) {
                            _selectedDiscount = val;
                            setState(() {});
                          }),
                    ),
                    Text(
                      AppLocalizations.of(context)!.lbl_25_50_percent,
                      style: _selectedDiscount == 8 ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Radio(
                      value: 9,
                      groupValue: _selectedDiscount,
                      onChanged: (dynamic val) {
                        _selectedDiscount = val;
                        setState(() {});
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.lbl_50_75_percent,
                      style: _selectedDiscount == 9 ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Radio(
                          value: 10,
                          groupValue: _selectedDiscount,
                          onChanged: (dynamic val) {
                            _selectedDiscount = val;
                            setState(() {});
                          }),
                    ),
                    Text(
                      AppLocalizations.of(context)!.lbl_above_70_percent,
                      style: _selectedDiscount == 10 ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      AppLocalizations.of(context)!.lbl_sort_by_availability,
                      style: textTheme.titleLarge,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: _isInStock,
                        onChanged: (val) {
                          _isInStock = val;
                          setState(() {});
                        }),
                    Text(
                      AppLocalizations.of(context)!.txt_in_stock,
                      style: _isInStock! ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                    Checkbox(
                        value: _isOutOfStock,
                        onChanged: (val) {
                          _isOutOfStock = val;
                          setState(() {});
                        }),
                    Text(
                      AppLocalizations.of(context)!.txt_out_of_stock,
                      style: _isOutOfStock! ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BottomButton(
            loadingState: false,
            disabledState: false,
            onPressed: () {
              _apply();
            },
            child: Text(AppLocalizations.of(context)!.btn_apply_filter),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _apply() {
    try {
      if (_selectedName != null) {
        if (_selectedName == 1) {
          widget.productFilter.byname = 'ASC';
        } else if (_selectedName == 2) {
          widget.productFilter.byname = 'DESC';
        } else {
          widget.productFilter.byname = null;
        }
      }
      if (_selectedRating != null) {
        if (_selectedRating == 3) {
          widget.productFilter.minRating = 1;
          widget.productFilter.maxRating = 2;
        } else if (_selectedRating == 4) {
          widget.productFilter.minRating = 2;
          widget.productFilter.maxRating = 3;
        } else if (_selectedRating == 5) {
          widget.productFilter.minRating = 3;
          widget.productFilter.maxRating = 4;
        } else if (_selectedRating == 6) {
          widget.productFilter.minRating = 4;
          widget.productFilter.maxRating = 5;
        }
      }
      if (_selectedDiscount != null) {
        if (_selectedDiscount == 7) {
          widget.productFilter.minDiscount = 10;
          widget.productFilter.maxDiscount = 25;
        } else if (_selectedDiscount == 8) {
          widget.productFilter.minDiscount = 25;
          widget.productFilter.maxDiscount = 50;
        } else if (_selectedDiscount == 9) {
          widget.productFilter.minDiscount = 50;
          widget.productFilter.maxDiscount = 70;
        } else if (_selectedDiscount == 10) {
          widget.productFilter.minDiscount = 70;
          widget.productFilter.maxDiscount = 100;
        }
      }

      if (_isInStock != null && _isInStock == true && _isOutOfStock != null && _isOutOfStock == true) {
        widget.productFilter.stock = 'all';
      } else if (_isInStock != null && _isInStock!) {
        widget.productFilter.stock = 'in';
      } else if (_isOutOfStock != null && _isOutOfStock!) {
        widget.productFilter.stock = 'out';
      }
      widget.productFilter.minPrice = _currentRangeValues.start.round();
      widget.productFilter.maxPrice = _currentRangeValues.end.round();
      Navigator.of(context).pop(widget.productFilter);
    } catch (e) {
      debugPrint("Exception - filter_screen.dart - _apply():$e");
    }
  }

  _init() {
    try {
      if (widget.productFilter.byname != null) {
        if (widget.productFilter.byname == 'ASC') {
          _selectedName = 1;
        } else if (widget.productFilter.byname == 'DESC') {
          _selectedName = 2;
        } else {
          _selectedName = 0;
        }
      }
      if (widget.productFilter.minRating != null) {
        if (widget.productFilter.minRating == 1 && widget.productFilter.maxRating == 2) {
          _selectedRating = 3;
        } else if (widget.productFilter.minRating == 2 && widget.productFilter.maxRating == 3) {
          _selectedRating = 4;
        } else if (widget.productFilter.minRating == 3 && widget.productFilter.maxRating == 4) {
          _selectedRating = 5;
        } else if (widget.productFilter.minRating == 4 && widget.productFilter.maxRating == 5) {
          _selectedRating = 6;
        }
      }

      if (widget.productFilter.minDiscount != null) {
        if (widget.productFilter.minDiscount == 10 && widget.productFilter.maxDiscount == 25) {
          _selectedDiscount = 7;
        } else if (widget.productFilter.minDiscount == 25 && widget.productFilter.maxDiscount == 50) {
          _selectedDiscount = 8;
        } else if (widget.productFilter.minDiscount == 50 && widget.productFilter.maxDiscount == 70) {
          _selectedDiscount = 9;
        } else if (widget.productFilter.minDiscount == 70 && widget.productFilter.minDiscount == 100) {
          _selectedDiscount = 10;
        }
      }
      if (widget.productFilter.stock != null) {
        if (widget.productFilter.stock == 'all') {
          _isInStock = _isOutOfStock = true;
        } else if (widget.productFilter.stock == 'in') {
          _isInStock = true;
        } else if (widget.productFilter.stock == 'out') {
          _isOutOfStock = true;
        }
      }

      if (widget.isProductAvailable! && widget.productFilter.maxPriceValue != null) {
        _currentRangeValues = RangeValues(0, double.parse(widget.productFilter.maxPriceValue.toString()));
      }

      if (widget.isProductAvailable! && widget.productFilter.minPrice != null && widget.productFilter.maxPrice != null) {
        _currentRangeValues = RangeValues(
          double.parse(widget.productFilter.minPrice.toString()),
          double.parse(widget.productFilter.maxPrice.toString()),
        );
      }
    } catch (e) {
      debugPrint("Exception - filter_screen.dart - _init():$e");
    }
  }
}
