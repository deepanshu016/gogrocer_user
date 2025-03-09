import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/addtocartmessagestatus.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/product_detail_model.dart';
import 'package:user/screens/cart_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/productlist_screen.dart';
import 'package:user/screens/rating_list_screen.dart';
import 'package:user/widgets/bottom_button.dart';
import 'package:user/widgets/cart_quantity_widget.dart';
import 'package:user/widgets/my_chip.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/widgets/toastfile.dart';

class AppBarActionButton extends StatefulWidget {
  final Function? onPressed;
  final CartController cartController;

  const AppBarActionButton(this.cartController, {super.key, this.onPressed});

  @override
  State<AppBarActionButton> createState() => _AppBarActionButtonState();
}

class ProductDescriptionScreen extends BaseRoute {
  int? productId;
  final ProductDetail? productDetail;
  final int? screenId;

  ProductDescriptionScreen({super.key, super.analytics, super.observer, super.routeName = 'ProductDescriptionScreen', this.productId, this.screenId, this.productDetail});

  @override
  BaseRouteState createState() =>
      _ProductDescriptionScreenState();
}

class _AppBarActionButtonState extends State<AppBarActionButton> {

  _AppBarActionButtonState();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      init: widget.cartController,
      builder: (value) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_shopping_cart_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => widget.onPressed!(),
            ),
            global.cartCount != 0
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                          global.cartCount != 0
                              ? '${global.cartCount}'
                              : '', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class _ProductDescriptionScreenState extends BaseRouteState<ProductDescriptionScreen> {
  ProductDetail? _productDetail;
  bool _isDataLoaded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CartController cartController = Get.put(CartController());
  int _qty = 0;
  int? _selectedIndex;

  _ProductDescriptionScreenState();

  // check if add to cart button is pressed once

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isDataLoaded
              ? _productDetail!.productDetail!.productName!
              : AppLocalizations.of(context)!.tle_product_details,
          style: textTheme.titleLarge,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
        actions: [
          AppBarActionButton(
            cartController,
            onPressed: () => global.currentUser!.id == null
                ? Get.to(LoginScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                  ))
                : Get.to(CartScreen(
                    analytics: widget.analytics,
                    observer: widget.observer,
                  )),
          ),
        ],
      ),
      body: _isDataLoaded
          ? GetBuilder<CartController>(
              init: cartController,
              builder: (value) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                            onTap: () async {
                              if (global.currentUser?.id == null) {
                                Future.delayed(Duration.zero, () {
                                  if(!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen(
                                              analytics: widget.analytics,
                                              observer: widget.observer,
                                            )),
                                  );
                                });
                              } else {
                                bool isAdded = await addRemoveWishList(
                                    _productDetail!.productDetail!.varientId);
                                if (isAdded) {
                                  _productDetail!.productDetail!.isFavourite =
                                      !_productDetail!.productDetail!.isFavourite;
                                }

                                setState(() {});
                              }
                            },
                            child: _productDetail!.productDetail!.isFavourite
                                ? Icon(
                                    MdiIcons.heart,
                                    size: 20,
                                    color: Colors.red,
                                  )
                                : Icon(
                                    MdiIcons.heartOutline,
                                    size: 20,
                                    color: Colors.red,
                                  )),
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      height: 260,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      )),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          _productDetail!.productDetail!.images.isNotEmpty
                              ? PhotoViewGallery.builder(
                                  scrollDirection: Axis.horizontal,
                                  reverse: true,
                                  loadingBuilder: (BuildContext context, _) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  itemCount: _productDetail!
                                      .productDetail!.images.length,
                                  builder: (BuildContext context, int index) {
                                    return PhotoViewGalleryPageOptions(
                                        imageProvider: _productDetail!.productDetail!
                                                        .images.isNotEmpty
                                            ? CachedNetworkImageProvider(
                                                global.appInfo!.imageUrl! +
                                                    _productDetail!.productDetail!
                                                        .images[index].image!,
                                              )
                                            : _productDetail!.productDetail!
                                                        .productImage !=
                                                    null
                                                ? CachedNetworkImageProvider(
                                                    global.appInfo!.imageUrl! +
                                                        _productDetail!
                                                            .productDetail!
                                                            .productImage!,
                                                  )
                                                : SizedBox(
                                                    width: screenWidth,
                                                    height: 260,
                                                    child: Image.asset(
                                                        'assets/images/icon.png')) as ImageProvider<Object>?);
                                  },
                                  backgroundDecoration: const BoxDecoration(
                                      // color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40),
                                      )),
                                )
                              : PhotoView(
                                  imageProvider: _productDetail!
                                              .productDetail!.productImage !=
                                          null
                                      ? CachedNetworkImageProvider(
                                          global.appInfo!.imageUrl! +
                                              _productDetail!
                                                  .productDetail!.productImage!,
                                        )
                                      : SizedBox(
                                          width: screenWidth,
                                          height: 260,
                                          child: Image.asset(
                                              'assets/images/icon.png')) as ImageProvider<Object>?,
                                  backgroundDecoration: const BoxDecoration(
                                      // color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40),
                                      )),
                                  loadingBuilder: (BuildContext context, _) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                ),
                          _productDetail!.productDetail!.images.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.zoom_out_map,
                                    color: textTheme.bodyLarge!.color,
                                  ),
                                  onPressed: () {
                                    dialogToOpenImage(
                                        _productDetail!
                                            .productDetail!.productName,
                                        _productDetail!.productDetail!.images,
                                        0);
                                  },
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    _productNameAndPrice(textTheme),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _productDetail!.productDetail!.varient.length,
                      itemBuilder: (BuildContext context, int i) {
                        debugPrint('${_productDetail!.productDetail!.varient[i].stock}');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _productWeightAndQuantity(
                              textTheme, cartController, i),
                        );
                      },
                    ),
                    _subHeading(textTheme, "Description"),
                    _productDescription(textTheme),
                    _productDetail!.productDetail!.rating != null &&
                            _productDetail!.productDetail!.rating! > 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16, left: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RatingListScreen(
                                        _productDetail!.productDetail!.varientId,
                                        analytics: widget.analytics,
                                        observer: widget.observer),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 13,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text:
                                          "${_productDetail!.productDetail!.rating} ",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      children: [
                                        TextSpan(
                                          text: '|',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        TextSpan(
                                          text:
                                              ' ${_productDetail!.productDetail!.ratingCount} ${AppLocalizations.of(context)!.txt_ratings}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    _subHeading(textTheme, "Related Products"),
                    _relatedProducts(textTheme),
                    _productDetail!.productDetail!.tags.isNotEmpty
                        ? _subHeading(textTheme, "Tags")
                        : const SizedBox(),
                    _productDetail!.productDetail!.tags.isNotEmpty
                        ? _tags(textTheme)
                        : const SizedBox(),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 32,
                        ),
                        child: BottomButton(
                            key: UniqueKey(),
                            loadingState: false,
                            disabledState: false,
                            onPressed: () {
                              if (global.currentUser!.id == null) {
                                Get.to(LoginScreen(
                                  analytics: widget.analytics,
                                  observer: widget.observer,
                                ));
                              } else {
                                if (_productDetail!.productDetail!.stock! > 0) {
                                  if (_productDetail!.productDetail!.varient
                                          .where((e) => e.cartQty! > 0)
                                          .toList().isNotEmpty) {
                                    //go to cart
                                    Get.to(() => CartScreen(
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                        ));
                                  } else {
                                    // add to cart
                                    _showVariantModalBottomSheet(
                                        textTheme, cartController);
                                  }
                                }
                              }
                            },
                            child: _productDetail!.productDetail!.stock! > 0
                                ? _productDetail!.productDetail!.varient
                                            .where((e) => e.cartQty! > 0)
                                            .toList().isNotEmpty
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              AppLocalizations.of(context)!.btn_go_to_cart),
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.shopping_cart_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.btn_add_cart)
                                : Text(
                                    AppLocalizations.of(context)!.txt_out_of_stock)))
                  ],
                ),
              ),
            )
          : _shimmer(),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _getBannerProductDetail() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getBannerProductDetail(widget.productId).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _productDetail = result.data;
            } else {
              _productDetail = null;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint(
          "Exception -  product_description_screen.dart - _getBannerProductDetail():$e");
    }
  }

  _getProductDetail() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper.getProductDetail(widget.productId).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              _productDetail = result.data;
            } else {
              _productDetail = null;
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint(
          "Exception -  product_description_screen.dart - _getProductDetail():$e");
    }
  }

  _init() async {
    try {
      if (widget.screenId == 0) {
        await _getBannerProductDetail();
      } else if (widget.productDetail != null) {
        _productDetail = widget.productDetail;
      } else {
        await _getProductDetail();
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception -  product_description_screen.dart - _init():$e");
    }
  }

  Widget _productDescription(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        _productDetail!.productDetail!.description != null &&
                _productDetail!.productDetail!.description != ''
            ? _productDetail!.productDetail!.description!
            : _productDetail!.productDetail!.type!,
        style: textTheme.bodyLarge!.copyWith(
          height: 1.3,
        ),
      ),
    );
  }

  Widget _productNameAndPrice(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _productDetail!.productDetail!.productName!,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: textTheme.titleLarge,
            ),
            _productDetail!.productDetail!.discount != null &&
                    _productDetail!.productDetail!.discount! > 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${_productDetail!.productDetail!.discount}% OFF",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _productWeightAndQuantity(
      TextTheme textTheme, CartController value, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '${_productDetail!.productDetail!.varient[i].quantity} ${_productDetail!.productDetail!.varient[i].unit} / ${global.appInfo!.currencySign} ${_productDetail!.productDetail!.varient[i].price}',
            style: textTheme.bodySmall!.copyWith(fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${global.appInfo!.currencySign} ${_productDetail!.productDetail!.varient[i].mrp}',
              style: textTheme.bodySmall!
                  .copyWith(decoration: TextDecoration.lineThrough),
            ),
          ),
          const Spacer(),
          _productDetail!.productDetail!.varient[i].stock! > 0
              ?
                CartQuantityWidget(
                    quantity: _productDetail!.productDetail!.varient[i].cartQty,
                    addTapped: () async {
                      if (global.currentUser!.id == null) {
                        Get.to(LoginScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ));
                      } else {
                        _qty = 1;
                        showOnlyLoaderDialog();
                        ATCMS? isSuccess = await value.addToCart(
                            _productDetail?.productDetail, _qty, false,
                            varient: _productDetail?.productDetail?.varient[i]);
                        if (isSuccess?.isSuccess != null && mounted) {
                          Navigator.of(context).pop();
                        }
                        showToast(isSuccess?.message ??
                            'Something went wrong adding product to cart');
                        setState(() {});
                      }
                    },
                    deleteTapped: () async {
                      if (_productDetail!
                          .productDetail!.varient[i].cartQty !=
                          null &&
                          _productDetail!
                              .productDetail!.varient[i].cartQty ==
                              1) {
                        _qty = 0;
                      } else {
                        _qty = _productDetail!
                            .productDetail!.varient[i].cartQty! - 1;
                      }

                      showOnlyLoaderDialog();
                      ATCMS? isSuccess = await value.addToCart(
                          _productDetail?.productDetail, _qty, true,
                          varient:
                          _productDetail?.productDetail?.varient[i]);
                      if (isSuccess?.isSuccess != null) {
                        if(!mounted) return;
                        Navigator.of(context).pop();
                      }
                      showToast(isSuccess?.message ?? 'Something went wrong trying to remove the product to the cart. Please try again later');
                      setState(() {});
                    }
                )
              : Text(
                  AppLocalizations.of(context)!.txt_out_of_stock,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                )
        ],
      ),
    );
  }

  Widget _relatedProducts(TextTheme textTheme) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 100,
          child: ListView.builder(
            itemCount: _productDetail!.similarProductList.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  _isDataLoaded = false;
                  widget.productId = _productDetail!.similarProductList[index].productId;

                  _init();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedNetworkImage(
                        imageUrl: global.appInfo!.imageUrl! +
                            _productDetail!
                                .similarProductList[index].productImage!,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(image: imageProvider)),
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => SizedBox(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: Text(
                          _productDetail!.similarProductList[index].productName!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }

  _shimmer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 260,
                    child: const Card(
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: const Card(elevation: 0),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: const Card(elevation: 0),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: const Card(elevation: 0),
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: const Card(elevation: 0),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: SizedBox(
                              width: 70,
                              child: Card(
                                elevation: 0,
                              )),
                        );
                      }),
                ),
              ],
            ),
          )),
    );
  }

  _showVariantModalBottomSheet(TextTheme textTheme, CartController value) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return GetBuilder<CartController>(
            init: cartController,
            builder: (value) => SizedBox(
              height: (_productDetail!.productDetail!.varient.length < 2)
                  ? 200
                  : 400,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _productDetail!.productDetail!.productName!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                        itemCount: _productDetail!.productDetail!.varient.length,
                        itemBuilder: (BuildContext context, int i) {
                          return ListTile(
                            title: ReadMoreText(
                              '${_productDetail!.productDetail!.varient[i].description}',
                              trimLines: 2,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16),
                              lessStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16),
                              moreStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16),
                            ),
                            subtitle: Text(
                                '${_productDetail!.productDetail!.varient[i].quantity} ${_productDetail!.productDetail!.varient[i].unit} / ${global.appInfo!.currencySign} ${_productDetail!.productDetail!.varient[i].price}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontSize: 15)),
                            trailing: _productDetail!
                                .productDetail!.varient[i].stock! > 0
                                ?
                                  CartQuantityWidget(
                                      quantity: _productDetail!.productDetail!.varient[i].cartQty,
                                      addTapped: () async {
                                        if (_productDetail!.productDetail!
                                            .varient[i].cartQty ==
                                            null) {
                                          _productDetail!.productDetail!
                                              .varient[i].cartQty = 0;
                                        }
                                        if (_productDetail!.productDetail!
                                            .varient[i].stock! >=
                                            _productDetail!.productDetail!
                                                .varient[i].cartQty!) {
                                          _qty = _productDetail!.productDetail!
                                              .varient[i].cartQty! +
                                              1;

                                          showOnlyLoaderDialog();
                                          ATCMS? isSuccess =
                                          await value.addToCart(
                                              _productDetail!
                                                  .productDetail,
                                              _qty,
                                              false,
                                              varient: _productDetail!
                                                  .productDetail!
                                                  .varient[i]);
                                          if (isSuccess?.isSuccess != null && context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                          showToast(isSuccess?.message ?? '');
                                        }
                                        else {
                                          showToast(
                                              'No more stock available for this variant');
                                        }

                                        setState(() {});
                                      },
                                      deleteTapped: () async {
                                        if (_productDetail!.productDetail!
                                            .varient[i].cartQty !=
                                            null &&
                                            _productDetail!.productDetail!
                                                .varient[i].cartQty ==
                                                1) {
                                          _qty = 0;
                                        } else {
                                          _qty = _productDetail!
                                              .productDetail!
                                              .varient[i]
                                              .cartQty! -
                                              1;
                                        }

                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess =
                                        await value.addToCart(
                                            _productDetail!
                                                .productDetail,
                                            _qty,
                                            true,
                                            varient: _productDetail!
                                                .productDetail!
                                                .varient[i]);
                                        if (isSuccess?.isSuccess != null && context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                        showToast(isSuccess?.message ?? '');

                                        setState(() {});
                                      }
                                  )
                                : Text(
                              AppLocalizations.of(context)!.txt_out_of_stock,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _subHeading(TextTheme textTheme, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        value,
        style: textTheme.titleMedium!.copyWith(
          // color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tags(TextTheme textTheme) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
            height: 100,
            child: Wrap(
              children: _tagsList(),
            )));
  }

  List<Widget> _tagsList() {
    List<Widget> list = [];
    for (int i = 0; i < _productDetail!.productDetail!.tags.length; i++) {
      list.add(Padding(
        padding: const EdgeInsets.only(right: 2),
        child: MyChip(
          isSelected: _productDetail!.productDetail!.tags[i].isSelected,
          onPressed: () {
            setState(() {
              _productDetail!.productDetail!.tags
                  .map((e) => e.isSelected = false)
                  .toList();
              _selectedIndex = i;
              if (_selectedIndex == i) {
                _productDetail!.productDetail!.tags[i].isSelected = true;
              }
            });
            Get.to(() => ProductListScreen(
                  analytics: widget.analytics,
                  observer: widget.observer,
                  screenId: 2,
                  categoryName: _productDetail!.productDetail!.tags[i].tag,
                ));
          },
          label: _productDetail!.productDetail!.tags[i].tag != null
              ? '#${_productDetail!.productDetail!.tags[i].tag}'
              : '',
        ),
      ));
    }
    return list;
  }
}
