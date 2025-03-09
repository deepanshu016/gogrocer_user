import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/user_profile_controller.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/wallet_model.dart';
import 'package:user/screens/payment_screen.dart';

class WalletScreen extends BaseRoute {
  const WalletScreen({super.key, super.analytics, super.observer, super.routeName = 'WalletScreen'});

  @override
  BaseRouteState createState() => _WalletScreenState();
}

class _WalletScreenState extends BaseRouteState {
  final ScrollController _rechargeHistoryScrollController = ScrollController();
  final ScrollController _walletSpentScrollController = ScrollController();
  final TextEditingController _cAmount = TextEditingController();
  int rechargeHistoryPage = 1;
  int walletSpentPage = 1;
  bool _isDataLoaded = false;
  bool _isRechargeHistoryPending = true;
  bool _isSpentHistoryPending = true;
  bool _isRechargeHistoryMoreDataLoaded = false;
  bool _isSpentHistoryMoreDataLoaded = false;
  final List<Wallet> _walletRechargeHistoryList = [];
  final List<Wallet> _walletSpentHistoryList = [];
  GlobalKey<ScaffoldState>? _scaffoldKey;
  APIHelper apiHelper4 = APIHelper();
  _WalletScreenState() : super();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.btn_my_wallet,
            style: textTheme.titleLarge,
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.keyboard_arrow_left)),
        ),
        body: SafeArea(
          child: _isDataLoaded
              ? Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.lbl_available_balance,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GetBuilder<UserProfileController>(init: global.userProfileController, builder: (value) => Text("${global.appInfo?.currencySign} ${global.userProfileController.currentUser?.wallet ?? '0.00'}", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 25))),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 80,
                    child: AppBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      bottom: TabBar(
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            width: 3.0,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          insets: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
                        indicatorWeight: 4,
                        unselectedLabelStyle: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400),
                        labelStyle: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorColor: const Color(0xFFEF5656),
                        tabs: [
                          Tab(
                              icon: Icon(
                                MdiIcons.wallet,
                                size: 18,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.lbl_recharge_history,
                                textAlign: TextAlign.center,
                              )),
                          Tab(
                              icon: Icon(
                                MdiIcons.walletPlus,
                                size: 18,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.lbl_wallet_recharge,
                                textAlign: TextAlign.center,
                              )),
                          Tab(
                              icon: Icon(
                                MdiIcons.currencyInr,
                                size: 18,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.lbl_spent_analysis,
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TabBarView(
                      children: [
                        _rechargeHistoryWidget(),
                        _rechargeWallet(),
                        _spentAnalysis(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
              : _shimmerWidget(),
        )
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  _getWalletRechargeHistory() async {
    try {
      if (_isRechargeHistoryPending) {
        setState(() {
          _isRechargeHistoryMoreDataLoaded = true;
        });
        if (_walletRechargeHistoryList.isEmpty) {
          rechargeHistoryPage = 1;
        } else {
          rechargeHistoryPage++;
        }
        await apiHelper4.getWalletRechargeHistory(rechargeHistoryPage).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Wallet> tList = result.data;
              if (tList.isEmpty) {
                _isRechargeHistoryPending = false;
              }
              _walletRechargeHistoryList.addAll(tList);
              setState(() {
                _isRechargeHistoryMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - wallet_screen.dart  - _getWalletRechargeHistory():$e");
    }
  }

  _getWalletSpentHistory() async {
    try {
      if (_isSpentHistoryPending) {
        setState(() {
          _isSpentHistoryMoreDataLoaded = true;
        });
        if (_walletSpentHistoryList.isEmpty) {
          walletSpentPage = 1;
        } else {
          walletSpentPage++;
        }
        await apiHelper4.getWalletSpentHistory(walletSpentPage).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              List<Wallet> tList = result.data;
              if (tList.isEmpty) {
                _isSpentHistoryPending = false;
              }
              _walletSpentHistoryList.addAll(tList);
              setState(() {
                _isSpentHistoryMoreDataLoaded = false;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - wallet_screen.dart  - _getWalletSpentHistory():$e");
    }
  }

  _init() async {
    try {
      debugPrint("token   ${global.currentUser?.token}  ${global.userProfileController.currentUser?.wallet} ${global.currentUser?.wallet}  ||||    id   ${global.currentUser?.id}");
      await _getWalletRechargeHistory();
      await _getWalletSpentHistory();
      await _getAppInfo();
      _rechargeHistoryScrollController.addListener(() async {
        if (_rechargeHistoryScrollController.position.pixels == _rechargeHistoryScrollController.position.maxScrollExtent && !_isRechargeHistoryMoreDataLoaded) {
          setState(() {
            _isRechargeHistoryMoreDataLoaded = true;
          });
          await _getWalletRechargeHistory();
          setState(() {
            _isRechargeHistoryMoreDataLoaded = false;
          });
        }
      });

      _walletSpentScrollController.addListener(() async {
        if (_walletSpentScrollController.position.pixels == _walletSpentScrollController.position.maxScrollExtent && !_isSpentHistoryMoreDataLoaded) {
          setState(() {
            _isSpentHistoryMoreDataLoaded = true;
          });
          await _getWalletSpentHistory();
          setState(() {
            _isSpentHistoryMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - wallet_screen.dart - _init():$e");
    }
  }

  _getAppInfo() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        await apiHelper4.getAppInfo(global.currentUser?.id != null ? global.currentUser!.id : null).then((result) async {
          if (result != null) {
            if (result.status == "1") {
              global.appInfo = result.data;
              global.userProfileController.currentUser!.wallet = global.appInfo!.userwallet;
              setState(() { });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Exception - wallet_screen.dart - _getAppInfo():$e");
    }
  }

  Widget _rechargeHistoryWidget() {
    return _walletRechargeHistoryList.isNotEmpty
        ? SingleChildScrollView(
            controller: _rechargeHistoryScrollController,
            child: Column(
              children: [
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _walletRechargeHistoryList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {},
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      color: Color(0xFFFFBEBE),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    child: Text(
                                      '${_walletRechargeHistoryList[index].paymentGateway}', style: const TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  Icon(
                                    MdiIcons.checkDecagram,
                                    size: 20,
                                    color: _walletRechargeHistoryList[index].rechargeStatus == 'success' ? Colors.greenAccent : Colors.red,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '${_walletRechargeHistoryList[index].rechargeStatus}',
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListTile(
                              visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                              contentPadding: const EdgeInsets.all(0),
                              minLeadingWidth: 0,
                              title: Text(
                                '${_walletRechargeHistoryList[index].dateOfRecharge}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: Text(
                                "${global.appInfo!.currencySign} ${_walletRechargeHistoryList[index].amount}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Divider(
                              color: Theme.of(context).dividerTheme.color,
                            ),
                          ],
                        ),
                      );
                    }),
                _isRechargeHistoryMoreDataLoaded
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          )
        : Center(
            child: Text(
              AppLocalizations.of(context)!.txt_nothing_to_show,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
  }

  Widget _rechargeWallet() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0.0))),
            child: TextFormField(
              controller: _cAmount,
              cursorColor: Theme.of(context).colorScheme.primary,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.hnt_enter_amount,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '${global.appInfo!.currencySign}',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                  ),
                ),
                contentPadding: const EdgeInsets.only(top: 10),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: FilledButton(
                onPressed: () async {
                  if (_cAmount.text.trim().isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PaymentGatewayScreen(
                          screenId: 3,
                          totalAmount: double.parse(_cAmount.text.trim()),
                          analytics: widget.analytics,
                          observer: widget.observer,
                        ),
                      ),
                    );
                  } else {
                    showSnackBar(key: _scaffoldKey, snackBarMessage: AppLocalizations.of(context)!.txt_enter_amount);
                  }
                },
                child: Text(AppLocalizations.of(context)!.btn_make_payment)),
          )
        ],
      ),
    );
  }

  Widget _shimmerWidget() {
    try {
      return Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0, top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: const Card(),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width / 3 - 20,
                        child: const Card(),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                      width: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width / 3 - 20,
                        child: const Card(),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                      width: 20,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width / 3 - 20,
                        child: const Card(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: 10,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: SizedBox(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            child: const Card(),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ));
    } catch (e) {
      debugPrint("Exception - wallet_screen.dart - _shimmerWidget():$e");
      return const SizedBox();
    }
  }

  Widget _spentAnalysis() {
    return _walletSpentHistoryList.isNotEmpty
        ? SingleChildScrollView(
            controller: _walletSpentScrollController,
            child: Column(
              children: [
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _walletSpentHistoryList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      color: Color(0xFFFFBEBE),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    child: Text(
                                      '#${_walletSpentHistoryList[index].cartId}',
                                      style: const TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    '${_walletSpentHistoryList[index].deliveryDate}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                  )
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                "${global.appInfo!.currencySign} ${_walletSpentHistoryList[index].paidbywallet}",
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                            ],
                          ),
                          Divider(
                            color: Theme.of(context).dividerTheme.color,
                          ),
                        ],
                      );
                    }),
                _isRechargeHistoryMoreDataLoaded
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          )
        : Center(
            child: Text(
              AppLocalizations.of(context)!.txt_nothing_to_show,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
  }
}
