import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/constants/image_constants.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/models/product_filter_model.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/filter_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/widgets/products_menu.dart';

class ProductListScreen extends BaseRoute {
  final int? screenId;
  final int? categoryId;
  final String? categoryName;
  const ProductListScreen({super.key, super.analytics, super.observer, super.routeName = 'ProductListScreen', this.screenId, this.categoryId, this.categoryName});

  @override
  BaseRouteState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends BaseRouteState<ProductListScreen> {
  final CartController cartController = Get.put(CartController());
  final List<Product> _productsList = [];
  bool _isDataLoaded = false;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;

  ProductFilter _productFilter = ProductFilter();
  final ScrollController _scrollController = ScrollController();

  int page = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _ProductListScreenState();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName!,
          style: textTheme.titleMedium,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
        actions: [
          GetBuilder<CartController>(
            init: cartController,
            builder: (value) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.add_shopping_cart_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      global.currentUser!.id == null
                          ? Get.to(LoginScreen(
                              analytics: widget.analytics,
                              observer: widget.observer,
                            ))
                          : Get.to(CartScreen(
                              analytics: widget.analytics,
                              observer: widget.observer,
                            ));
                    },
                  ),
                  global.cartCount != 0
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(global.cartCount != 0 ? '${global.cartCount}' : ''),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
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
      body: _isDataLoaded
          ? _productsList.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await _onRefresh();
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            ProductsMenu(
                              analytics: widget.analytics,
                              observer: widget.observer,
                              categoryProductList: _productsList,
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
                      )),
                )
              : Center(child: Text(AppLocalizations.of(context)!.txt_nothing_to_show))
          : _shimmer(),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _applyFilters() async {
    try {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Padding(padding: const EdgeInsets.only(top: 100), child: FilterScreen(_productFilter, isProductAvailable: _productsList.isNotEmpty ? true : false)),
      ).then((value) async {
        if (value != null) {
          _isDataLoaded = false;
          _isRecordPending = true;
          if (_productsList.isNotEmpty) {
            _productsList.clear();
          }

          setState(() {});
          _productFilter = value;
          await _init();
        }
      });
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _applyFilters():$e");
    }
  }

  _getCategoryProduct() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
          page = 1;
        } else {
          page++;
        }
        await apiHelper.getCategoryProducts(widget.categoryId, page, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Product> tList = result.data;
              if (tList.isEmpty) {
                _isRecordPending = false;
              }
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getCategoryProduct():$e");
    }
  }

  _getDealProduct() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
          page = 1;
        } else {
          page++;
        }
        await apiHelper.getDealProducts(page, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Product> tList = result.data;
              if (tList.isEmpty) {
                _isRecordPending = false;
              }
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getDealProduct():$e");
    }
  }

  _getProductList() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (widget.screenId == 0) {
          await _getCategoryProduct();
        } else if (widget.screenId == 1) {
          await _getDealProduct();
        } else if (widget.screenId == 2) {
          await _getTagProducts();
        } else if (widget.screenId == 3) {
          await _getWhatsNewProduct();
        } else if (widget.screenId == 4) {
          await _getSpotLightProduct();
        } else if (widget.screenId == 5) {
          await _getRecentSellingProduct();
        } else {
          await _getTopSellingProduct();
        }

        _productFilter.maxPriceValue = _productsList.isNotEmpty ? _productsList[0].maxprice : 0;
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getProductList():$e");
    }
  }

  _getRecentSellingProduct() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
          page = 1;
        } else {
          page++;
        }
        await apiHelper.recentSellingProduct(page, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Product> tList = result.data;
              if (tList.isEmpty) {
                _isRecordPending = false;
              }
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getRecentSellingProduct():$e");
    }
  }

  _getSpotLightProduct() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
          page = 1;
        } else {
          page++;
        }
        await apiHelper.spotLightProduct(page, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Product> tList = result.data;
              if (tList.isEmpty) {
                _isRecordPending = false;
              }
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getSpotLightProduct():$e");
    }
  }

  _getTagProducts() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
          page = 1;
        } else {
          page++;
        }
        await apiHelper.getTagProducts(widget.categoryName, page, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Product> tList = result.data;
              if (tList.isEmpty) {
                _isRecordPending = false;
              }
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getDealProduct():$e");
    }
  }

  _getTopSellingProduct() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
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
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getTopSellingProduct():$e");
    }
  }

  _getWhatsNewProduct() async {
    try {
      if (_isRecordPending) {
        setState(() {
          _isMoreDataLoaded = true;
        });
        if (_productsList.isEmpty) {
          page = 1;
        } else {
          page++;
        }
        await apiHelper.whatsnewProduct(page, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Product> tList = result.data;
              if (tList.isEmpty) {
                _isRecordPending = false;
              }
              _productsList.addAll(tList);
              setState(() {
                _isMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _getWhatsNewProduct():$e");
    }
  }

  _init() async {
    try {
      await _getProductList();
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isMoreDataLoaded) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          await _getProductList();
          setState(() {
            _isMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      _isRecordPending = true;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - productlist_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 15,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(height: 100 * MediaQuery.of(context).size.height / 830, width: MediaQuery.of(context).size.width, child: const Card());
              })),
    );
  }
}
