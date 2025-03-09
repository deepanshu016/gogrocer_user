import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/constants/image_constants.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/models/product_filter_model.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/filter_screen.dart';
import 'package:user/widgets/products_menu.dart';

class WishListScreen extends BaseRoute {
  const WishListScreen({super.key, super.analytics, super.observer, super.routeName = 'WishListScreen'});
  @override
  BaseRouteState createState() => _WishListScreenState();
}

class _WishListScreenState extends BaseRouteState {
  bool _isDataLoaded = false;
  int page = 1;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;
  ProductFilter _productFilter = ProductFilter();
  final List<Product> _wishListProductList = [];
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final CartController cartController = Get.put(CartController());
  final ScrollController _scrollController = ScrollController();

  _WishListScreenState() : super();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.btn_wishlist,
            style: textTheme.titleLarge,
          ),
          leading: IconButton(
              onPressed: () {
                global.isNavigate = true;
                setState(() {});
                Get.back();
              },
              icon: const Icon(Icons.keyboard_arrow_left)),
          actions: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: InkWell(
                onTap: () async {
                  await _applyFilters();
                },
                child: SvgPicture.asset(
                  ImageConstants.filterSearchLogoUrl,
                  height: 23,
                ),
              ),
            )
          ],
        ),
        body: GetBuilder<CartController>(
          init: cartController,
          builder: (value) => RefreshIndicator(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              _isDataLoaded = false;
              _isRecordPending = true;
              _wishListProductList.clear();
              setState(() {});
              await _init();
            },
            child: _isDataLoaded
                ? global.nearStoreModel!.id != null
                    ? _wishListProductList.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  ProductsMenu(
                                    analytics: widget.analytics,
                                    observer: widget.observer,
                                    categoryProductList: _wishListProductList,
                                    callId: 0,
                                  ),
                                  _isMoreDataLoaded
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            ))
                        : Center(
                            child: Text(
                              AppLocalizations.of(context)!.txt_nothing_to_show,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                    : Center(
                        child: Text(
                          "${global.locationMessage}",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                : _productShimmer(),
          ),
        ),
        bottomNavigationBar: _isDataLoaded && _wishListProductList.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        await _addAllProductToCart();
                      },
                      child: Text(AppLocalizations.of(context)!.txt_add_all_to_cart)),
                ),
              )
            : null,
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  _addAllProductToCart() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.addWishListToCart().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.cartCount = global.cartCount + _wishListProductList.length;
              _wishListProductList.clear();
              hideLoader();
              if(!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartScreen(analytics: widget.analytics, observer: widget.observer),
                ),
              );
            } else {
              hideLoader();
              if(!mounted) return;
              showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_try_again_after_sometime);
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - wishlist_screen.dart - _addAllProductToCart():$e");
    }
  }

  _applyFilters() async {
    try {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Padding(
            padding: const EdgeInsets.only(top: 100),
            child: FilterScreen(
              _productFilter,
              isProductAvailable: _wishListProductList.isNotEmpty ? true : false,
            )),
      ).then((value) async {
        if (value != null) {
          _isDataLoaded = false;
          if (_wishListProductList.isNotEmpty) {
            _wishListProductList.clear();
          }

          setState(() {});
          _productFilter = value;
          await _init();
        }
      });
    } catch (e) {
      debugPrint("Exception - wishlist_screen.dart - _applyFilters():$e");
    }
  }

  _getWishListProduct() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_isRecordPending) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          if (_wishListProductList.isEmpty) {
            page = 1;
          } else {
            page++;
          }
          await apiHelper.getWishListProduct(page, _productFilter).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                List<Product> tList = result.data;
                if (tList.isEmpty) {
                  _isRecordPending = false;
                }
                _wishListProductList.addAll(tList);
                setState(() {
                  _isMoreDataLoaded = false;
                });
              }
            }
          });
        }
        _productFilter.maxPriceValue = _wishListProductList.isNotEmpty ? _wishListProductList[0].maxprice : 0;
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - wishlist_screen.dart - _getWishListProduct():$e");
    }
  }

  _init() async {
    try {
      if (global.nearStoreModel!.id != null) {
        await _getWishListProduct();
        _scrollController.addListener(() async {
          if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isMoreDataLoaded) {
            setState(() {
              _isMoreDataLoaded = true;
            });
            await _getWishListProduct();
            setState(() {
              _isMoreDataLoaded = false;
            });
          }
        });
      }

      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - wishlist_screen.dart - _init():$e");
    }
  }

  Widget _productShimmer() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  SizedBox(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - wishlist_screen.dart - _productShimmer():$e");
      return const SizedBox();
    }
  }
}
