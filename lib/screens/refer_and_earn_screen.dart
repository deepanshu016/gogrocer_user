import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;

class ReferAndEarnScreen extends BaseRoute {
  const ReferAndEarnScreen({super.key, super.analytics, super.observer, super.routeName = 'ReferAndEarnScreen'});
  @override
  BaseRouteState createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends BaseRouteState {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  String? referMessage;
  _ReferAndEarnScreenState() : super();
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.tle_invite_earn,
              style: textTheme.titleLarge,
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.keyboard_arrow_left)),
          ),
          body: SafeArea(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                      ),
                      Text(
                        '${global.appInfo!.refertext}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${global.appInfo!.refertext}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Card(
                        child: InkWell(
                          customBorder: Theme.of(context).cardTheme.shape,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: "${global.currentUser!.referralCode}"));
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${global.currentUser!.referralCode}",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 25),
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.txt_tap_to_copy,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: SizedBox(
                height: 50,
                child: FilledButton(
                    onPressed: () {
                      br.inviteFriendShareMessage();
                    },
                    child: Text(AppLocalizations.of(context)!.btn_invite_friends, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold ),)),

              ),
            ),
          )),
    );
  }


  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    setState(() {});
  }
}
