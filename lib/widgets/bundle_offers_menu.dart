import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/addtocartmessagestatus.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/product_description_screen.dart';
import 'package:user/theme/style.dart';
import 'package:user/widgets/toastfile.dart';

class BundleOffersMenu extends StatefulWidget {
  final dynamic analytics;
  final dynamic observer;
  final List<Product>? categoryProductList;
  final Function(int)? onSelected;

  const BundleOffersMenu({super.key, this.onSelected, this.categoryProductList, this.analytics, this.observer});

  @override
  State<BundleOffersMenu> createState() => _BundleOffersMenuState();
}

class BundleOffersMenuItem extends StatefulWidget {
  final Product product;

  final dynamic analytics;
  final dynamic observer;
  const BundleOffersMenuItem({super.key, required this.product, this.analytics, this.observer});

  @override
  State<BundleOffersMenuItem> createState() => _BundleOffersMenuItemState();
}

class _BundleOffersMenuItemState extends State<BundleOffersMenuItem> {
  final CartController cartController = Get.put(CartController());

  int? _qty;
  _BundleOffersMenuItemState();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.53,
      child: GetBuilder<CartController>(
          init: cartController,
          builder: (value) => Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            imageUrl: global.appInfo!.imageUrl! + widget.product.productImage!,
                            imageBuilder: (context, imageProvider) => Container(
                              width: (screenWidth * 0.53) - 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: imageProvider,
                              )),
                              child: Visibility(
                                visible: widget.product.stock! > 0 ? false : true,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(5)),
                                  padding: const EdgeInsets.all(5),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: 12,
                                      child: Text(
                                        AppLocalizations.of(context)!.txt_out_of_stock,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const SizedBox(child: Center(child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) => SizedBox(
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                widget.product.productName!,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                widget.product.type != null && widget.product.type != '' ? widget.product.type! : '',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: normalCaptionStyle(context).copyWith(fontSize: 11),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                widget.product.description != null && widget.product.description != '' ? widget.product.description! : '',
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: normalCaptionStyle(context).copyWith(fontSize: 12),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${global.appInfo!.currencySign} ${widget.product.price}",
                                      style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    widget.product.price == widget.product.mrp
                                        ? const SizedBox()
                                        : Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        "${global.appInfo!.currencySign}${widget.product.mrp}",
                                        style: textTheme.labelSmall!.copyWith(decoration: TextDecoration.lineThrough, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                widget.product.stock! > 0
                                    ? InkWell(
                                  onTap: () async {
                                    if (global.currentUser!.id == null) {
                                      Get.to(LoginScreen(
                                        analytics: widget.analytics,
                                        observer: widget.observer,
                                      ));
                                    } else {
                                      _showVarientModalBottomSheet(textTheme, cartController);
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(3),
                                    color: Theme.of(context).colorScheme.secondaryContainer,
                                    child: Icon(
                                      Icons.add,
                                      size: 15.0,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                )
                                    : const SizedBox()
                              ],
                            ),
                            widget.product.rating != null && widget.product.rating! > 0
                                ? Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "${widget.product.rating} ",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                      children: [
                                        TextSpan(
                                          text: '|',
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                        ),
                                        TextSpan(
                                          text: ' ${widget.product.ratingCount} ${AppLocalizations.of(context)!.txt_ratings}',
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
    );
  }

  showOnlyLoaderDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  _showVarientModalBottomSheet(TextTheme textTheme, CartController value) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return GetBuilder<CartController>(
            init: cartController,
            builder: (value) => SizedBox(
              height: 200,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.product.productName!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Divider(),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.product.varient.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        title: ReadMoreText(
                          '${widget.product.varient[i].description}',
                          trimLines: 2,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: AppLocalizations.of(context)!.txt_show_more,
                          trimExpandedText: AppLocalizations.of(context)!.txt_show_less,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                          lessStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                          moreStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                        ),
                        subtitle: Text('${widget.product.varient[i].quantity} ${widget.product.varient[i].unit} / ${global.appInfo!.currencySign} ${widget.product.varient[i].price}  ', style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15)),
                        trailing: widget.product.varient[i].cartQty == null || widget.product.varient[i].cartQty == 0
                            ? InkWell(
                                onTap: () async {
                                  if (global.currentUser!.id == null) {
                                    Get.to(LoginScreen(
                                      analytics: widget.analytics,
                                      observer: widget.observer,
                                    ));
                                  } else {
                                    _qty = 1;
                                    showOnlyLoaderDialog();
                                    ATCMS? isSuccess;
                                    isSuccess = await value.addToCart(widget.product, _qty, false, varient: widget.product.varient[i]);
                                    if (isSuccess!.isSuccess != null && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                    showToast(isSuccess.message!);
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  height: 23,
                                  width: 23,
                                  alignment: Alignment.center,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.add,
                                    size: 17.0,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (widget.product.varient[i].cartQty != null && widget.product.varient[i].cartQty == 1) {
                                          _qty = 0;
                                        } else {
                                          _qty = widget.product.varient[i].cartQty! - 1;
                                        }

                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess;
                                        isSuccess = await value.addToCart(widget.product, _qty, true, varient: widget.product.varient[i]);

                                        if (isSuccess!.isSuccess != null && context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                        showToast(isSuccess.message!);
                                        setState(() {});
                                      },
                                      child: Container(
                                          height: 23,
                                          width: 23,
                                          alignment: Alignment.center,
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          child: widget.product.varient[i].cartQty == 1
                                              ? Icon(
                                                  Icons.delete,
                                                  size: 17.0,
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                )
                                              : Icon(
                                                  MdiIcons.minus,
                                                  size: 17.0,
                                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                )),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      height: 23,
                                      width: 23,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1.0,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                            ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${widget.product.varient[i].cartQty}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        _qty = widget.product.varient[i].cartQty! + 1;

                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess;
                                        isSuccess = await value.addToCart(widget.product, _qty, false, varient: widget.product.varient[i]);
                                        if (isSuccess!.isSuccess != null && context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                        showToast(isSuccess.message!);
                                        setState(() {});
                                      },
                                      child: Container(
                                          height: 23,
                                          width: 23,
                                          alignment: Alignment.center,
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          child: Icon(
                                            MdiIcons.plus,
                                            size: 17,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int i) {
                      return const Divider();
                    },
                  )
                ],
              ),
            ),
          );
        });
  }
}

class _BundleOffersMenuState extends State<BundleOffersMenu> {
  APIHelper apiHelper = APIHelper();

  _BundleOffersMenuState();

  Future<bool> addRemoveWishList(int? varientId) async {
    bool isAddedSuccesFully = false;
    try {
      showOnlyLoaderDialog();
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if(!mounted) return;
          if (result.status == "1" || result.status == "2") {
            isAddedSuccesFully = true;
            Navigator.pop(context);
          } else {
            isAddedSuccesFully = false;
            Navigator.pop(context);

            showSnackBar(snackBarMessage: '${AppLocalizations.of(context)!.txt_please_try_again_after_sometime} ');
          }
        }
      });
      return isAddedSuccesFully;
    } catch (e) {
      debugPrint("Exception - bundle_offers_menu.dart - addRemoveWishList():$e");
      return isAddedSuccesFully;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width*1/2/1,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categoryProductList!.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Get.to(() => ProductDescriptionScreen(analytics: widget.analytics, observer: widget.observer, productId: widget.categoryProductList![index].productId)),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    BundleOffersMenuItem(
                      product: widget.categoryProductList![index],
                      analytics: widget.analytics,
                      observer: widget.observer,
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: widget.categoryProductList![index].discount != null && widget.categoryProductList![index].discount! > 0
                            ? Container(
                          height: 16,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            "${widget.categoryProductList![index].discount} % OFF",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        )
                            : const SizedBox(
                          height: 16,
                          width: 60,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: widget.categoryProductList![index].isFavourite
                            ? Icon(
                          MdiIcons.heart,
                          size: 20,
                          color: Colors.red,
                        )
                            : Icon(
                          MdiIcons.heartOutline,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          if (global.currentUser!.id == null) {
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
                              widget.categoryProductList![index].varientId,
                            );
                            if (isAdded) {
                              widget.categoryProductList![index].isFavourite = !widget.categoryProductList![index].isFavourite;
                            }

                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  showOnlyLoaderDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void showSnackBar({required String snackBarMessage}) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(
    //     snackBarMessage,
    //     textAlign: TextAlign.center,
    //   ),
    //   duration: Duration(seconds: 2),
    // ));
    showToast(snackBarMessage);
  }
}
