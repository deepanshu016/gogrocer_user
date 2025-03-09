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

class PopularProductsMenuItem extends StatefulWidget {
  final int? callId;
  final Product product;
  final dynamic analytics;
  final dynamic observer;
  const PopularProductsMenuItem({super.key, required this.product, this.analytics, this.observer, this.callId});

  @override
  State<PopularProductsMenuItem> createState() => _PopularProductsMenuItemState();
}

class ProductsMenu extends StatefulWidget {
  final dynamic analytics;
  final dynamic observer;
  final int? callId;
  final List<Product>? categoryProductList;
  const ProductsMenu({super.key, this.analytics, this.observer, this.categoryProductList, this.callId});

  @override
  State<ProductsMenu> createState() => _ProductsMenuState();
}

class _PopularProductsMenuItemState extends State<PopularProductsMenuItem> {
  APIHelper apiHelper = APIHelper();
  final CartController cartController = Get.put(CartController());
  int? _qty;

  _PopularProductsMenuItemState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 120,
      child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6, top: 10),
            child: GetBuilder<CartController>(
              init: cartController,
              builder: (value) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 56,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              widget.product.discount != null && widget.product.discount! > 0 ?
                              Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  "${widget.product.discount}% OFF",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ):const SizedBox.shrink(),
                              CachedNetworkImage(
                                imageUrl: global.appInfo!.imageUrl! + widget.product.productImage!,
                                imageBuilder: (context, imageProvider) => Container(
                                  color: const Color(0xffF7F7F7),
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(color: const Color(0xffF7F7F7), image: DecorationImage(image: imageProvider, fit: BoxFit.contain)),
                                    child: Visibility(
                                      visible: widget.product.stock! > 0 ? false : true,
                                      child: Container(
                                        width: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(5)),
                                        padding: const EdgeInsets.all(5),
                                        child: Center(
                                          child: Transform.rotate(
                                            angle: 12,
                                            child: Text(
                                              AppLocalizations.of(context)!.txt_out_of_stock,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => SizedBox(
                                  height: 80,
                                  width: 60,
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.productName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    widget.product.type != null && widget.product.type != '' ? widget.product.type! : '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: normalCaptionStyle(context),
                                  ),
                                ),
                                Text(
                                  widget.product.description != null && widget.product.description != '' ? widget.product.description! : '',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: normalCaptionStyle(context),
                                ),
                                widget.product.rating != null && widget.product.rating! > 0
                                    ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
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
                                          text: "${widget.product.rating} ",
                                          style: Theme.of(context).textTheme.bodySmall,
                                          children: [
                                            TextSpan(
                                              text: '|',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                            TextSpan(
                                              text: ' ${widget.product.ratingCount} ${AppLocalizations.of(context)!.txt_ratings}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: InkWell(
                                onTap: () async {
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
                                    showOnlyLoaderDialog();
                                    await addRemoveWishList(widget.product.varientId, widget.product);
                                    if(!context.mounted) return;
                                    Navigator.pop(context);
                                    setState(() {});
                                  }
                                },
                                child: widget.product.isFavourite
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
                              ),
                            ),
                            Text(
                              "${global.appInfo!.currencySign} ${widget.product.price}",
                              style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            widget.product.price == widget.product.mrp
                                ? const SizedBox()
                                : Text(
                              "${global.appInfo!.currencySign} ${widget.product.mrp}",
                              style: textTheme.labelSmall!.copyWith(decoration: TextDecoration.lineThrough, fontSize: 12),
                            ),
                            const Spacer(),
                            widget.product.stock! > 0
                                ? widget.callId == 0
                                ? widget.product.cartQty == null || widget.product.cartQty == 0
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
                                  isSuccess = await value.addToCart(widget.product, _qty, false, varientId: widget.product.varientId, callId: 0);
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
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                child: Icon(
                                  Icons.add,
                                  size: 15.0,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                                      if (widget.product.cartQty != null && widget.product.cartQty == 1) {
                                        _qty = 0;
                                      } else {
                                        _qty = widget.product.cartQty! - 1;
                                      }

                                      showOnlyLoaderDialog();
                                      ATCMS? isSuccess;
                                      isSuccess = await value.addToCart(widget.product, _qty, true, varientId: widget.product.varientId, callId: 0);
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
                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                        child: widget.product.cartQty == 1
                                            ? Icon(
                                          Icons.delete,
                                          size: 17.0,
                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        )
                                            : Icon(
                                          MdiIcons.minus,
                                          size: 17.0,
                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    height: 21,
                                    width: 21,
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
                                        "${widget.product.cartQty}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      _qty = widget.product.cartQty! + 1;

                                      showOnlyLoaderDialog();
                                      ATCMS? isSuccess;
                                      isSuccess = await value.addToCart(widget.product, _qty, false, varientId: widget.product.varientId, callId: 0);
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
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        child: Icon(
                                          MdiIcons.plus,
                                          size: 17,
                                        )),
                                  )
                                ],
                              ),
                            )
                                : InkWell(
                              onTap: () async {
                                if (global.currentUser!.id == null) {
                                  Get.to(LoginScreen(
                                    analytics: widget.analytics,
                                    observer: widget.observer,
                                  ));
                                } else {
                                  _showVarientModalBottomSheet(textTheme, value);
                                }
                              },
                              child: Container(
                                height: 23,
                                width: 23,
                                alignment: Alignment.center,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                child: Icon(
                                  Icons.add,
                                  size: 17.0,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            )
                                : const SizedBox()
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future<bool> addRemoveWishList(int? varientId, Product? product) async {
    bool isAddedSuccesFully = false;
    try {
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if (result.status == "1" || result.status == "2") {
            isAddedSuccesFully = true;

            widget.product.isFavourite = !widget.product.isFavourite;

            if (result.status == "2") {
              if (widget.callId == 0) {
                // product
                // categoryProductList.removeWhere((e) => e.varientId == varientId);
              }
            }

            setState(() {});
          } else {
            isAddedSuccesFully = false;

            setState(() {});
            if(!mounted) return;
            showSnackBar(snackBarMessage: AppLocalizations.of(context)!.txt_please_try_again_after_sometime);
          }
        }
      });
      return isAddedSuccesFully;
    } catch (e) {
      debugPrint("Exception - products_menu.dart - addRemoveWishList():$e");
      return isAddedSuccesFully;
    }
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
        isScrollControlled: false,
        builder: (BuildContext context) {
          return GetBuilder<CartController>(
            init: cartController,
            builder: (value) => StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: 300,
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
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.product.varient.length,
                        itemBuilder: (BuildContext context, int i) {
                          return ListTile(
                            title: ReadMoreText(
                              '${widget.product.varient[i].description}',
                              trimLines: 2,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                              lessStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                              moreStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                            ),
                            subtitle: Text('${widget.product.varient[i].quantity} ${widget.product.varient[i].unit} / ${global.appInfo!.currencySign} ${widget.product.varient[i].price}', style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15)),
                            trailing: widget.product.varient[i].cartQty == null || widget.product.varient[i].cartQty == 0
                                ? InkWell(
                                    onTap: () async {
                                      if (global.currentUser!.id == null) {
                                        Get.to(LoginScreen(
                                          analytics: widget.analytics,
                                          observer: widget.observer,
                                        ));
                                      } else {
                                        showOnlyLoaderDialog();
                                        ATCMS? isSuccess;
                                        _qty = 1;
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
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                      child: Icon(
                                        Icons.add,
                                        size: 17.0,
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                                              color: Theme.of(context).colorScheme.tertiaryContainer,
                                              child: widget.product.varient[i].cartQty == 1
                                                  ? Icon(
                                                      Icons.delete,
                                                      size: 17.0,
                                                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                                                    )
                                                  : Icon(
                                                      MdiIcons.minus,
                                                      size: 17.0,
                                                      color: Theme.of(context).colorScheme.onTertiaryContainer,
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
                                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                            ),
                                            borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                                ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${widget.product.varient[i].cartQty}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                                color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
}

class _ProductsMenuState extends State<ProductsMenu> {
  APIHelper apiHelper = APIHelper();

  _ProductsMenuState();

  Future<bool> addRemoveWishList(int varientId, int index) async {
    bool isAddedSuccesFully = false;
    try {
      await apiHelper.addRemoveWishList(varientId).then((result) async {
        if (result != null) {
          if (result.status == "1" || result.status == "2") {
            isAddedSuccesFully = true;

            widget.categoryProductList![index].isFavourite = !widget.categoryProductList![index].isFavourite;

            if (result.status == "2") {
              if (widget.callId == 0) {
                widget.categoryProductList!.removeWhere((e) => e.varientId == varientId);
              }
            }

            setState(() {});
          } else {
            isAddedSuccesFully = false;

            setState(() {});
            if(!mounted) return;
            showSnackBar(snackBarMessage: AppLocalizations.of(context)!.txt_please_try_again_after_sometime);
          }
        }
      });
      return isAddedSuccesFully;
    } catch (e) {
      debugPrint("Exception - products_menu.dart - addRemoveWishList():$e");
      return isAddedSuccesFully;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.categoryProductList!.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => Get.to(() => ProductDescriptionScreen(analytics: widget.analytics, observer: widget.observer, productId: widget.categoryProductList![index].productId)),
            child: PopularProductsMenuItem(
              key: Key('${widget.categoryProductList!.length}'),
              product: widget.categoryProductList![index],
              analytics: widget.analytics,
              observer: widget.observer,
              callId: widget.callId,
            ),
          ),
        );
      },
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
