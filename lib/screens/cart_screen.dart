import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/screens/checkout_screen.dart';
import 'package:user/controllers/home_controller.dart';
import 'package:user/utils/navigation_utils.dart';
import 'package:user/widgets/cart_menu.dart';
import 'package:user/widgets/cart_screen_bottom_sheet.dart';

class CartScreen extends BaseRoute {
  const CartScreen({super.key, 
    super.analytics,
    super.observer,
    super.routeName = 'CartScreen'
  });

  @override
  BaseRouteState createState() => _CartScreenState();
}

class _CartScreenState extends BaseRouteState {
  final CartController cartController = Get.put(CartController());
  final HomeController homeController = Get.find();
  bool _isDataLoaded = false;
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: GetBuilder<CartController>(
          init: cartController,
          builder: (value) => Scaffold(
                appBar: AppBar(
                  title: Text(
                    AppLocalizations.of(context)!.txt_cart,
                    style: textTheme.titleLarge,
                  ),
                  leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.keyboard_arrow_left)),
                  actions: [
                    global.nearStoreModel != null
                        ? Padding(
                            padding: global.isRTL ? const EdgeInsets.only(left: 8.0) : const EdgeInsets.only(right: 8.0),
                            child: Center(
                              child: GetBuilder<CartController>(
                                init: cartController,
                                builder: (value) => Text(
                                  "${global.cartCount} ${AppLocalizations.of(context)!.lbl_items}",
                                  style: textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
                body: global.nearStoreModel != null
                    ? _isDataLoaded
                        ? cartController.cartItemsList != null && cartController.cartItemsList!.cartList.isNotEmpty
                            ? RefreshIndicator(
                                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                                onRefresh: () async {
                                  await _onRefresh();
                                },
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 16.0,
                                          left: 16,
                                          right: 16,
                                          bottom: 0,
                                        ),
                                        child: CartMenu(
                                          cartController: cartController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _emptyCartWidget()
                        : _shimmer()
                    : Center(
                        child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(global.locationMessage!),
                      )),
                bottomNavigationBar: global.nearStoreModel != null
                    ? _isDataLoaded
                        ? cartController.cartItemsList != null && cartController.cartItemsList!.cartList.isNotEmpty
                            ? GetBuilder<CartController>(
                                init: cartController,
                                builder: (value) => SafeArea(
                                  child: CartScreenBottomSheet(
                                    cartController: cartController,
                                    onButtonPressed: () => Navigator.of(context).push(
                                      NavigationUtils.createAnimatedRoute(
                                        1.0,
                                        CheckoutScreen(cartController: cartController, analytics: widget.analytics, observer: widget.observer),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox()
                        : _shimmer1()
                    : const SizedBox(),
              )),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCartList();
    debugPrint('TOKEN:${global.appDeviceId}');
  }

  _emptyCartWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              "assets/images/empty_cart.png",
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 18,
            ),
            Center(
              child: FilledButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromWidth(350.0),
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  homeController.navigateToHome();
                  Get.back();
                },
                child: Text(
                  AppLocalizations.of(context)!.lbl_let_shop,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  _getCartList() async {
    try {
      await cartController.getCartList();
      if (cartController.isDataLoaded.value == true) {
        _isDataLoaded = true;
      } else {
        _isDataLoaded = false;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Exception -  cart_screen.dart - _getCartList():$e");
    }
  }

  _onRefresh() async {
    try {
      _isDataLoaded = false;
      setState(() {});
      await _getCartList();
    } catch (e) {
      debugPrint("Exception -  cart_screen.dart - _onRefresh():$e");
    }
  }

  _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 100 * MediaQuery.of(context).size.height / 830, width: MediaQuery.of(context).size.width, child: const Card());
                    }),
              ),
            ],
          )),
    );
  }

  _shimmer1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: Card(elevation: 0),
                  ),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: Card(elevation: 0),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: Card(elevation: 0),
                  ),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: Card(elevation: 0),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: Card(elevation: 0),
                  ),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: Card(elevation: 0),
                  ),
                ],
              ),
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: const Card(elevation: 0),
              ),
            ],
          )),
    );
  }
}
