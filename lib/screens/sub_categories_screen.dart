import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/subcategory_model.dart';
import 'package:user/screens/productlist_screen.dart';
import 'package:user/widgets/select_category_card.dart';

class SubCategoriesScreen extends BaseRoute {
  @required
  final String? screenHeading;
  @required
  final int? categoryId;

  const SubCategoriesScreen({super.key, 
    super.analytics,
    super.observer,
    super.routeName = 'SubCategoriesScreen',
    this.screenHeading,
    this.categoryId,
  });

  @override
  BaseRouteState<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends BaseRouteState<SubCategoriesScreen> {
  int _selectedIndex = 0;
  bool _isDataLoaded = false;
  int? screenId;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;
  final ScrollController _scrollController = ScrollController();
  int page = 1;
  final List<SubCategory> _subCategoryList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _SubCategoriesScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.screenHeading!,
          style: textTheme.titleLarge,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _onRefresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isDataLoaded
              ? _subCategoryList.isNotEmpty
                  ? GridView.builder(
                      controller: _scrollController,
                      itemCount: _subCategoryList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 24.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: 1/1,
                      ),
                      itemBuilder: (context, index) => SelectCategoryCard(
                        key: UniqueKey(),
                        screenId: 1,
                        subCategory: _subCategoryList[index],
                        isSelected: _subCategoryList[index].isSelected,
                        borderRadius: 0,
                        onPressed: () {
                          setState(() {
                            _subCategoryList.map((e) => e.isSelected = false).toList();
                            _selectedIndex = index;
                            if (_selectedIndex == index) {
                              _subCategoryList[index].isSelected = true;
                            }
                          });
                          Get.to(() => ProductListScreen(
                                analytics: widget.analytics,
                                observer: widget.observer,
                                screenId: 0,
                                categoryName: _subCategoryList[index].title,
                                categoryId: _subCategoryList[index].catId,
                              ));
                        },
                      ),
                    )
                  : Center(
                      child: Text(AppLocalizations.of(context)!.txt_nothing_to_show),
                    )
              : _shimmer(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _getSubCategoryList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_isRecordPending) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          if (_subCategoryList.isEmpty) {
            page = 1;
          } else {
            page++;
          }
          await apiHelper.getSubCategory(page, widget.categoryId).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                List<SubCategory> tList = result.data;
                if (tList.isEmpty) {
                  _isRecordPending = false;
                }
                _subCategoryList.addAll(tList);
                setState(() {
                  _isMoreDataLoaded = false;
                });
              } else {
                _isRecordPending = false;
                setState(() {
                  _isMoreDataLoaded = false;
                });
              }
            }
          });
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - sub_categories_screen.dart - _getSubCategoryList():$e");
    }
  }

  _init() async {
    try {
      await _getSubCategoryList();
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isMoreDataLoaded) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          await _getSubCategoryList();
          setState(() {
            _isMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - sub_categories_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      _isRecordPending = true;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - sub_categories_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: GridView.builder(
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) => const SizedBox(height: 130, width: 90, child: Card()))),
    );
  }
}
