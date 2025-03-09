import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_filter.dart';
import 'package:user/models/category_list_model.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/models/product_filter_model.dart';
import 'package:user/screens/search_screen.dart';
import 'package:user/screens/sub_categories_screen.dart';
import 'package:user/widgets/bundle_offers_menu.dart';
import 'package:user/widgets/cart_item_count_button.dart';
import 'package:user/widgets/my_chip.dart';
import 'package:user/widgets/products_menu.dart';

class CategoriesListButtons extends StatefulWidget {
  final List<CategoryList>? categoriesList;
  final dynamic analytics;
  final dynamic observer;
  const CategoriesListButtons(this.categoriesList, this.analytics, this.observer, {super.key});

  @override
  State<CategoriesListButtons> createState() => _CategoriesListButtonsState();
}

class TopDealsScreen extends BaseRoute {
  const TopDealsScreen({super.key, super.analytics, super.observer, super.routeName = 'TopDealsScreen'});

  @override
  BaseRouteState createState() => _TopDealsScreenState();
}

class _CategoriesListButtonsState extends State<CategoriesListButtons> {
  int _selectedIndex = 0;

  _CategoriesListButtonsState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.categoriesList!.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            MyChip(
              key: UniqueKey(),
              isSelected: _selectedIndex == index,
              onPressed: () {
                widget.categoriesList!.map((e) => e.isSelected = false).toList();
                _selectedIndex = index;
                if (_selectedIndex == index) {
                  widget.categoriesList![index].isSelected = true;
                }

                Get.to(() => SubCategoriesScreen(
                      analytics: widget.analytics,
                      observer: widget.observer,
                      screenHeading: widget.categoriesList![index].title,
                      categoryId: widget.categoriesList![index].catId,
                    ));
              },
              label: widget.categoriesList![index].title,
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}

class _TopDealsScreenState extends BaseRouteState {
  List<Product>? _bundleOffersProductList = [];
  final List<Product> _popularProductList = [];
  List<CategoryList>? _categoriesList = [];
  bool _isDataLoaded = false;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;
  int page = 1;
  final ProductFilter _productFilter = ProductFilter();
  final ScrollController _scrollController = ScrollController();
  final CartController cartController = Get.put(CartController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.lbl_deal_products,
            style: textTheme.titleLarge,
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.keyboard_arrow_left)),
          actions: [
            IconButton(
                onPressed: () async {
                  await openBarcodeScanner(_scaffoldKey);
                },
                icon: Icon(
                  MdiIcons.barcode,
                  color: Theme.of(context).colorScheme.primary,
                )),
            IconButton(
              icon: const Icon(Icons.search_outlined),
              onPressed: () => Get.to(() => SearchScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _onRefresh();
          },
          child: global.nearStoreModel != null && global.nearStoreModel!.id != null
              ? SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: _isDataLoaded ? CategoriesListButtons(_categoriesList, widget.analytics, widget.observer) : _shimmer1(),
                      ),
                      _bundleOffersProductList != null && _bundleOffersProductList!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                AppLocalizations.of(context)!.lbl_bundle_offers,
                                style: textTheme.titleLarge,
                              ),
                            )
                          : const SizedBox(),
                      _isDataLoaded
                          ? _bundleOffersProductList != null && _bundleOffersProductList!.isNotEmpty
                              ? BundleOffersMenu(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                  categoryProductList: _bundleOffersProductList,
                                )
                              : const SizedBox()
                          : _shimmer2(),
                      _popularProductList.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                AppLocalizations.of(context)!.lbl_popular,
                                style: textTheme.titleLarge,
                              ),
                            )
                          : const SizedBox(),
                      _isDataLoaded
                          ? _popularProductList.isNotEmpty
                              ? ProductsMenu(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                  categoryProductList: _popularProductList,
                                )
                              : const SizedBox()
                          : _shimmer3(),
                      _isMoreDataLoaded
                          ? const Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: CartItemCountButton(
                            analytics: widget.analytics,
                            observer: widget.observer,
                            cartController: cartController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ) : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(global.locationMessage!),
                  ),
                ),
        ));
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _getCategoriesList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getCategoryList(CategoryFilter(), page).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _categoriesList = result.data;
            } else {
              _categoriesList = null;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - top_deals_screen.dart - _getProductList():$e");
    }
  }

  _getDealProduct() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getDealProducts(1, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _bundleOffersProductList = result.data;
            } else {
              _bundleOffersProductList = null;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - top_deals_screen.dart - _getDealProduct():$e");
    }
  }

  _getTopSellingProduct() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_isRecordPending) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          if (_popularProductList.isEmpty) {
            page = 1;
          } else {
            page++;
          }
          await apiHelper.getTopSellingProducts(page, _productFilter).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                List<Product> tList = result.data;
                if (tList.isEmpty) {
                  _isRecordPending = false;
                }
                _popularProductList.addAll(tList);
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
      debugPrint("Exception - top_deals_screen.dart - _getTopSellingProduct():$e");
    }
  }

  _init() async {
    try {
      _getCategoriesList();
      _getDealProduct();
      await _getTopSellingProduct();
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isMoreDataLoaded) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          await _getTopSellingProduct();
          setState(() {
            _isMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - top_deals_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      _isRecordPending = true;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - top_deals_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(
            height: 43,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 43,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 43,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 43,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ))
              ],
            )),
      ),
    );
  }

  _shimmer2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 264 / 796 - 20,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: 4,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(width: MediaQuery.of(context).size.width * 220 / 411, child: const Card()),
                  );
                }),
          )),
    );
  }

  _shimmer3() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 4,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(height: 100 * MediaQuery.of(context).size.height / 830, width: MediaQuery.of(context).size.width, child: const Card());
              })),
    );
  }
}
