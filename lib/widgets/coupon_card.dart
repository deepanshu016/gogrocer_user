import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/coupons_model.dart';

class CouponsCard extends StatefulWidget {
  final Coupon? coupon;
  final Function? onRedeem;
  const CouponsCard({super.key, this.coupon, this.onRedeem});

  @override
  State<CouponsCard> createState() => _CouponsCardState();
}

class _CouponsCardState extends State<CouponsCard> {
  final Color color = const Color(0xffFF0000);
  final double height = Get.height;
  final double width = Get.width;
  
  _CouponsCardState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8)
        ),
        height: height * 0.18,
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl: global.appInfo!.imageUrl! + widget.coupon!.couponImage!,
                imageBuilder: (context, imageProvider) => Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 75,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.red, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                ),
                placeholder: (context, url) => Container(margin: const EdgeInsets.only(top: 12, bottom: 12), width: 75, child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 75,
                  child: Icon(
                    Icons.image,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: width - 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: height * 0.040,
                          width: width * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: Center(
                              child: Text(
                            "${widget.coupon!.couponCode}",
                            style: const TextStyle(color: Colors.grey),
                          )),
                        ),
                        widget.coupon!.userUses == widget.coupon!.usesRestriction
                            ? const SizedBox()
                            : InkWell(
                                onTap: () => widget.onRedeem!(),
                                child: Container(
                                  height: height * 0.040,
                                  width: width * 0.2,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                    border: Border.all(color: Colors.transparent),
                                  ),
                                  child: Center(child: Text(AppLocalizations.of(context)!.btn_redeem, style: const TextStyle(color: Colors.white))),
                                ),
                              ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.coupon!.couponName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          widget.coupon!.couponDescription!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        LinearPercentIndicator(
                          width: 140,
                          lineHeight: 5.0,
                          percent: (widget.coupon!.userUses! / widget.coupon!.usesRestriction!) * 0.1,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          progressColor: const Color(0xffFF0000),
                          fillColor: Theme.of(context).colorScheme.primary,
                        ),
                        Row(
                          children: [
                            Text(
                              '   ${widget.coupon!.userUses} / ${widget.coupon!.usesRestriction} ${AppLocalizations.of(context)!.btn_uses}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
