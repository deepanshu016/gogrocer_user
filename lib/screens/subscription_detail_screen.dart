import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/membership_model.dart';
import 'package:user/screens/payment_screen.dart';
import 'package:user/widgets/my_chip.dart';

class SubscriptionDetailScreen extends BaseRoute {
  final MembershipModel membershipModel;
  const SubscriptionDetailScreen(this.membershipModel, {super.key, super.analytics, super.observer, super.routeName = 'SubscriptionDetailScreen'});
  @override
  BaseRouteState createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends BaseRouteState<SubscriptionDetailScreen> {
  bool isloading = true;

  _SubscriptionDetailScreenState() : super();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          AppLocalizations.of(context)!.lbl_platinum_pro,
          style: textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 20),
            child: Text(AppLocalizations.of(context)!.lbl_subscription_plan, style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                      contentPadding: const EdgeInsets.all(4),
                      title: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        runSpacing: 0,
                        spacing: 10,
                        children: _wrapWidgetList(),
                      )),
                  const Divider(),
                  ListTile(
                    contentPadding: const EdgeInsets.all(4),
                    title: Html(
                      data: "${widget.membershipModel.planDescription}",
                      style: {
                        "body": Style(color: Theme.of(context).textTheme.bodyLarge!.color, fontFamily: Theme.of(context).textTheme.displayMedium!.fontFamily, fontSize: FontSize(Theme.of(context).textTheme.bodyLarge!.fontSize!), fontWeight: Theme.of(context).textTheme.bodyLarge!.fontWeight),
                      },
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: const EdgeInsets.all(10.0),
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentGatewayScreen(
                        screenId: 2,
                        membershipModel: widget.membershipModel,
                        totalAmount: widget.membershipModel.price,
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.btn_subscribe_this_plan,
                )),
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.transparent,
            ),
            margin: const EdgeInsets.all(8.0),
            height: 40,
            width: MediaQuery.of(context).size.width,
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.btn_explore_other_plan,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w400),
                )),
          ),
        ],
      ),
    );
  }



  List<Widget> _wrapWidgetList() {
    List<Widget> widgetList = [];
    try {
      if (widget.membershipModel.freeDelivery != null && widget.membershipModel.freeDelivery! > 0) {
        widgetList.add(
          const MyChip(
            label: 'Free Delivery',
            isSelected: false,
          ),
        );
      }

      if (widget.membershipModel.instantDelivery != null && widget.membershipModel.instantDelivery! > 0) {
        widgetList.add(
          const MyChip(
            label: 'Instant Delivery',
            isSelected: false,
          ),
        );
      }

      if (widget.membershipModel.days != null && widget.membershipModel.days! > 0) {
        widgetList.add(
          MyChip(
            label: '${widget.membershipModel.days} Days',
            isSelected: false,
          ),
        );
      }

      if (widget.membershipModel.reward != null && widget.membershipModel.reward! > 0) {
        widgetList.add(
          MyChip(
            label: '${widget.membershipModel.reward}x Reward Points',
            isSelected: false,
          ),
        );
      }
      if (widget.membershipModel.price != null && widget.membershipModel.price! > 0) {
        widgetList.add(
          MyChip(
            label: '${widget.membershipModel.price} ${global.appInfo!.currencySign}',
            isSelected: false,
          ),
        );
      }
      return widgetList;
    } catch (e) {
      debugPrint("Exception - subscription_detail_screen.dart - _wrapWidgetList():   $e");
      widgetList.add(const SizedBox());
      return widgetList;
    }
  }
}
