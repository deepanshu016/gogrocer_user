import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:user/constants/image_constants.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/category_product_model.dart';
import 'package:user/models/product_filter_model.dart';
import 'package:user/screens/filter_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/cart_item_count_button.dart';
import 'package:user/widgets/products_menu.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultsScreen extends BaseRoute {
  String? searchParams;

  SearchResultsScreen({super.key, super.analytics, super.observer, super.routeName = 'SearchResultsScreen', this.searchParams});

  @override
  BaseRouteState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends BaseRouteState<SearchResultsScreen> {
  List<Product>? _productSearchResult = [];
  ProductFilter _productFilter = ProductFilter();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDataLoaded = false;
  final TextEditingController _cSearch = TextEditingController();
  int page = 1;
  final CartController cartController = Get.put(CartController());

  _SearchResultsScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _onRefresh();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GetBuilder<CartController>(
                    init: cartController,
                    builder: (value) => SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: Icon(
                                      Icons.keyboard_arrow_left,
                                      color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      cursorColor: Colors.grey[800],
                                      autofocus: false,
                                      controller: _cSearch,
                                      style: textFieldHintStyle(context),
                                      keyboardType: TextInputType.text,
                                      textCapitalization: TextCapitalization.none,
                                      obscureText: false,
                                      readOnly: false,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.secondary, style: BorderStyle.none),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.secondary, style: BorderStyle.none),
                                        ),
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            _cSearch.clear();
                                          },
                                          child: Icon(
                                            Icons.cancel,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search_outlined,
                                          color: Colors.grey[800],
                                        ),
                                        hintText: AppLocalizations.of(context)!.hnt_search_product,
                                        hintStyle: textFieldHintStyle(context),
                                        contentPadding: const EdgeInsets.only(bottom: 12.0),
                                      ),
                                      onFieldSubmitted: (val) async {
                                        if (val != '') {
                                          setState(() {
                                            _productSearchResult!.clear();
                                            _isDataLoaded = false;
                                            widget.searchParams = val;
                                            _onRefresh();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Center(
                                    child: InkWell(
                                      onTap: () async {
                                        await _applyFilters();
                                      },
                                      child: SvgPicture.asset(
                                        ImageConstants.filterSearchLogoUrl,
                                        height: 25,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _isDataLoaded
                                ? Text(
                                    _productSearchResult != null && _productSearchResult!.isNotEmpty ? "${_productSearchResult!.length} Items Found" : "",
                                    style: textTheme.titleLarge,
                                  )
                                : const SizedBox(),
                          ),
                          _isDataLoaded
                              ? _productSearchResult != null && _productSearchResult!.isNotEmpty
                                  ? ProductsMenu(
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                      categoryProductList: _productSearchResult,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 200, bottom: 200),
                                      child: Center(child: Text(AppLocalizations.of(context)!.txt_nothing_to_show)),
                                    )
                              : _shimmer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    );
  }

  @override
  void initState() {
    super.initState();
    _cSearch.text = widget.searchParams!;
    _init();
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
              isProductAvailable: _productSearchResult != null && _productSearchResult!.isNotEmpty ? true : false,
            )),
      ).then((value) async {
        if (value != null) {
          _isDataLoaded = false;
          if (_productSearchResult != null && _productSearchResult!.isNotEmpty) {
            _productSearchResult!.clear();
          }

          setState(() {});
          _productFilter = value;
          await _init();
        }
      });
    } catch (e) {
      debugPrint("Exception - search_results_screen.dart - _applyFilters():$e");
    }
  }

  _getProductSearchResult() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getproductSearchResult(widget.searchParams, _productFilter).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _productSearchResult = result.data;
            } else {
              _productSearchResult = null;
            }
          }
        });
        _productFilter.maxPriceValue = _productSearchResult != null && _productSearchResult!.isNotEmpty ? _productSearchResult![0].maxprice : 0;
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - search_results_screen.dart - _getProductSearchResult():$e");
    }
  }

  _init() async {
    try {
      await _getProductSearchResult();
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - search_results_screen.dart - _init():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      setState(() {});
      await _init();
    } catch (e) {
      debugPrint("Exception - search_results_screen.dart - _onRefresh():$e");
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
              itemCount: 8,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                    height: 100 * MediaQuery.of(context).size.height / 830,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(
                      elevation: 0,
                    ));
              })),
    );
  }
}
