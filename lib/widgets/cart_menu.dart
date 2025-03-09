import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:user/controllers/cart_controller.dart';
import 'package:user/models/addtocartmessagestatus.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_product_model.dart';
import 'package:user/widgets/toastfile.dart';

class CartMenu extends StatefulWidget {
  final CartController? cartController;
  const CartMenu({super.key, this.cartController});

  @override
  State<CartMenu> createState() => _CartMenuState();
}

class CartMenuItem extends StatefulWidget {
  final Product? product;
  final CartController? cartController;
  const CartMenuItem({super.key, this.product, this.cartController});

  @override
  State<CartMenuItem> createState() => _CartMenuItemState();
}

class _CartMenuItemState extends State<CartMenuItem> {
  int? _qty;

  _CartMenuItemState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
        height: 100 * screenHeight / 830,
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: global.appInfo!.imageUrl! + widget.product!.varientImage!,
                      imageBuilder: (context, imageProvider) => Container(
                        color: const Color(0xffF7F7F7),
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 80,
                          width: 40,
                          decoration: BoxDecoration(color: const Color(0xffF7F7F7), image: DecorationImage(image: imageProvider, fit: BoxFit.contain)),
                        ),
                      ),
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => SizedBox(
                        height: 80,
                        width: 40,
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            widget.product!.productName!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${global.appInfo!.currencySign} ${widget.product!.price}",
                          style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
                Positioned(
                    right: global.isRTL ? null : 0,
                    left: global.isRTL ? 0 : null,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () async {
                              showOnlyLoaderDialog();
                              if (widget.product!.cartQty != null && widget.product!.cartQty == 1) {
                                _qty = 0;
                              } else {
                                _qty = widget.product!.cartQty! - 1;
                              }
                              ATCMS? isSuccess;
                              isSuccess = await widget.cartController!.addToCart(widget.product, _qty, true, varientId: widget.product!.varientId, callId: 0);
                              if (isSuccess!.isSuccess != null && context.mounted) {
                                Navigator.of(context).pop();
                              }
                              showToast(isSuccess.message!);
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //   content: Text(
                              //     isSuccess.message,
                              //     textAlign: TextAlign.center,
                              //   ),
                              //   duration: Duration(seconds: 2),
                              // ));
                              setState(() {});
                            },
                            child: Container(
                                height: 23,
                                width: 23,
                                alignment: Alignment.center,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                child: widget.product!.cartQty != null && widget.product!.cartQty == 1
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
                            height: 23,
                            width: 23,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                  ),
                            ),
                            child: Center(
                              child: Text(
                                "${widget.product!.cartQty}",
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
                              showOnlyLoaderDialog();
                              _qty = widget.product!.cartQty! + 1;
                              ATCMS? isSuccess;
                              isSuccess = await widget.cartController!.addToCart(widget.product, _qty, false, varientId: widget.product!.varientId, callId: 0);
                              if (isSuccess!.isSuccess != null && context.mounted) {
                                Navigator.of(context).pop();
                              }
                              showToast(isSuccess.message!);
                              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //   content: Text(
                              //     isSuccess.message,
                              //     textAlign: TextAlign.center,
                              //   ),
                              //   duration: Duration(seconds: 2),
                              // ));
                              setState(() {});
                            },
                            child: Container(
                                height: 23,
                                width: 23,
                                alignment: Alignment.center,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                child: Icon(
                                  MdiIcons.plus,
                                  size: 17,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                )),
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ));
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
}

class _CartMenuState extends State<CartMenu> {

  _CartMenuState();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      shrinkWrap: true,
      itemCount: widget.cartController!.cartItemsList!.cartList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return GetBuilder<CartController>(
          init: widget.cartController,
          builder: (value) => Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              showOnlyLoaderDialog();
              ATCMS? isSuccess;
              isSuccess = await widget.cartController!.addToCart(widget.cartController!.cartItemsList!.cartList[index], 0, true, varientId: widget.cartController!.cartItemsList!.cartList[index].varientId, callId: 0);
              if (isSuccess!.isSuccess != null && context.mounted) {
                Navigator.of(context).pop();
              }
              showToast(isSuccess.message!);
              setState(() {});
            },
            background: _backgroundContainer(context, screenHeight),
            child: CartMenuItem(
              product: widget.cartController!.cartItemsList!.cartList[index],
              cartController: widget.cartController,
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

  Widget _backgroundContainer(BuildContext context, double screenHeight) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Wrap(
          children: [
            Container(
              height: 80 * screenHeight / 830,
              color: Theme.of(context).colorScheme.error,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 32),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
