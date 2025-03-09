import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/order_model.dart';
import 'package:user/screens/home_screen.dart';

class RateOrderScreen extends BaseRoute {
  final Order? order;
  final int index;
  const RateOrderScreen(this.order, this.index, {super.key, super.analytics, super.observer, super.routeName = 'RateOrderScreen'});
  @override
  BaseRouteState createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends BaseRouteState<RateOrderScreen> {
  var _cComment = TextEditingController();
  double _userRating = 0;
  final _fComment = FocusNode();
  GlobalKey<ScaffoldState>? _scaffoldKey;

  _RateOrderScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.btn_rate_order,
            style: textTheme.titleLarge,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lbl_order_id,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '#${widget.order!.cartid}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lbl_number_of_items,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${widget.order!.productList.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lbl_delivered_on,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${widget.order!.deliveryDate}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lbl_total_amount,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${global.appInfo!.currencySign} ${widget.order!.remPrice}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: Color(0xFFCCD6DF),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(AppLocalizations.of(context)!.lbl_rate_overall_exp, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(
                  height: 10,
                ),
                RatingBar.builder(
                  initialRating: widget.order!.productList[widget.index].userRating != null ? double.parse(widget.order!.productList[widget.index].userRating.toString()).toDouble() : 0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 25,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  updateOnDrag: false,
                  onRatingUpdate: (rating) {
                    _userRating = rating;
                    setState(() {});
                  },
                  tapOnlyMode: true,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Divider(
                  color: Color(0xFFCCD6DF),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.only(),
                  child: TextFormField(
                    controller: _cComment,
                    focusNode: _fComment,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.hnt_comment,
                      contentPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                onPressed: () async {
                  await _submitRating();
                },
                child: Text(AppLocalizations.of(context)!.btn_submit_rating)),
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _cComment = TextEditingController(text: widget.order!.productList[widget.index].ratingDescription);
    _userRating = widget.order!.productList[widget.index].userRating!.toDouble();
  }

  _submitRating() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_userRating > 0 && _cComment.text.trim().isNotEmpty) {
          showOnlyLoaderDialog();
          await apiHelper.addProductRating(widget.order!.productList[widget.index].varientId, _userRating, _cComment.text.trim()).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                hideLoader();
                showSnackBar(key: _scaffoldKey, snackBarMessage: result.message);
                Future.delayed(const Duration(seconds: 2), () {
                  if(!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(analytics: widget.analytics, observer: widget.observer),
                    ),
                  );
                });
              } else {
                hideLoader();
                if(!mounted) return;
                showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_something_went_wrong);
              }
            }
          });
        } else if (_userRating == 0) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_please_give_ratings);
        } else if (_cComment.text.isEmpty) {
          if(!mounted) return;
          showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_enter_description);
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - rate_order_screen.dart - _submitRating():$e");
    }
  }
}
