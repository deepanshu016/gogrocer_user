import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:user/constants/image_constants.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/user_model.dart';
import 'package:user/screens/about_us_and_terms_of_services.dart';
import 'package:user/screens/all_categories_screen.dart';
import 'package:user/screens/app_setting_screen.dart';
import 'package:user/screens/chat_screen.dart';
import 'package:user/screens/choose_language_screen.dart';
import 'package:user/screens/contact_us_screen.dart';
import 'package:user/screens/coupons_screen.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/membership_screen.dart';
import 'package:user/screens/product_request_screen.dart';
import 'package:user/screens/refer_and_earn_screen.dart';
import 'package:user/screens/reward_screen.dart';
import 'package:user/screens/top_deals_screen.dart';
import 'package:user/screens/wallet_screen.dart';
import 'package:user/screens/wishlist_screen.dart';
import 'package:user/widgets/app_menu_list_tile.dart';
import 'package:user/widgets/swiper_drawer.dart';

class AppMenuScreen extends BaseRoute {
  final Function()? onBackPressed;
  final GlobalKey<SwiperDrawerState>? drawerKey;

  const AppMenuScreen({super.key, super.analytics, super.observer, super.routeName = 'AppMenuScreen', this.onBackPressed, this.drawerKey});

  @override
  BaseRouteState<AppMenuScreen> createState() => _AppMenuScreenState();
}

class _AppMenuScreenState extends BaseRouteState<AppMenuScreen> {

  _AppMenuScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
            ),
            onPressed: () => widget.onBackPressed!()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (global.currentUser!.id == null) {
                  Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                } else {
                  widget.drawerKey!.currentState!.closeDrawer();
                }
              },
              child: UserInfoTile(
                textTheme: textTheme,
              ),
            ),
            Container(
              height: 20,
            ),
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      global.nearStoreModel != null
                          ? AppMenuListTile(
                        label: AppLocalizations.of(context)!.tle_all_category,
                        leadingIconUrl: ImageConstants.allCategoriesLogoUrl,
                        onPressed: () => Get.to(() => AllCategoriesScreen(
                          analytics: widget.analytics,
                          observer: widget.observer,
                        )),
                      )
                          : const SizedBox(),
                      const SizedBox(height: 8.0),
                      global.nearStoreModel != null
                          ? AppMenuListTile(
                        label: "${AppLocalizations.of(context)!.lbl_deal_products}  ",
                        leadingIconUrl: ImageConstants.topDealsLogoUrl,
                        onPressed: () => Get.to(() => TopDealsScreen(analytics: widget.analytics, observer: widget.observer)),
                      )
                          : const SizedBox(),
                      const SizedBox(height: 8.0),
                      global.nearStoreModel != null
                          ? AppMenuListTile(
                          label: AppLocalizations.of(context)!.lbl_make_product_request,
                          leadingIconUrl: ImageConstants.productRequestLogoUrl,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              Get.to(() => ProductRequestScreen(analytics: widget.analytics, observer: widget.observer));
                            }
                          })
                          : const SizedBox(),
                      const SizedBox(height: 8.0),
                      global.nearStoreModel != null
                          ? AppMenuListTile(
                        label: "${AppLocalizations.of(context)!.btn_wishlist}  ",
                        leadingIconUrl: ImageConstants.trackOrderLogoUrl,
                        onPressed: () {
                          if (global.currentUser!.id == null) {
                            Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                          } else {
                            Get.to(() => WishListScreen(
                              analytics: widget.analytics,
                              observer: widget.observer,
                            ));
                          }
                        },
                      )
                          : const SizedBox(),
                      const SizedBox(height: 8.0),
                      global.nearStoreModel != null
                          ? AppMenuListTile(
                        label: "${AppLocalizations.of(context)!.lbl_coupons}  ",
                        leadingIconUrl: ImageConstants.couponsLogoUrl,
                        onPressed: () => Get.to(() => CouponsScreen(analytics: widget.analytics, observer: widget.observer)),
                      )
                          : const SizedBox(),
                      // SizedBox(height: 8.0),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.btn_membership}  ",
                          icon: Icons.card_membership_sharp,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              Get.to(() => MemberShipScreen(analytics: widget.analytics, observer: widget.observer));
                            }
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.lbl_reward}  ",
                          icon: Icons.wallet_giftcard_sharp,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              Get.to(() => RewardScreen(analytics: widget.analytics, observer: widget.observer));
                            }
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.btn_my_wallet}  ",
                          icon: Icons.account_balance_wallet_outlined,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              Get.to(() => WalletScreen(analytics: widget.analytics, observer: widget.observer));
                            }
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.btn_refer_earn}  ",
                          icon: MdiIcons.giftOutline,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              Get.to(() => ReferAndEarnScreen(analytics: widget.analytics, observer: widget.observer));
                            }
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                        label: "${AppLocalizations.of(context)!.btn_app_setting}  ",
                        icon: Icons.settings_outlined,
                        onPressed: () => Get.to(() => SettingScreen(analytics: widget.analytics, observer: widget.observer)),
                      ),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                        label: "${AppLocalizations.of(context)!.lbl_select_language}  ",
                        icon: Icons.translate_outlined,
                        onPressed: () => Get.to(() => ChooseLanguageScreen(analytics: widget.analytics, observer: widget.observer)),
                      ),
                      const SizedBox(height: 8.0),
                      global.nearStoreModel != null && global.nearStoreModel!.id != null && global.appInfo!.liveChat != null && global.appInfo!.liveChat == 1
                          ? AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.txt_live_chat}  ",
                          leadingIconUrl: ImageConstants.liveChatLogoUrl,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              if (global.nearStoreModel != null) {
                                Get.to(() => ChatScreen(analytics: widget.analytics, observer: widget.observer));
                              }
                            }
                          })
                          : const SizedBox(),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.tle_contact_us}  ",
                          icon: Icons.contact_page_outlined,
                          onPressed: () {
                            if (global.currentUser!.id == null) {
                              Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                            } else {
                              Get.to(() => ContactUsScreen(analytics: widget.analytics, observer: widget.observer));
                            }
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.tle_about_us}  ",
                          icon: Icons.info_outline,
                          onPressed: () {
                            Get.to(() => AboutUsAndTermsOfServiceScreen(true, analytics: widget.analytics, observer: widget.observer));
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                          label: "${AppLocalizations.of(context)!.tle_term_of_service}  ",
                          icon: Icons.design_services_outlined,
                          onPressed: () {
                            Get.to(() => AboutUsAndTermsOfServiceScreen(false, analytics: widget.analytics, observer: widget.observer));
                          }),
                      const SizedBox(height: 8.0),
                      AppMenuListTile(
                        label: global.currentUser?.id == null ? '${AppLocalizations.of(context)!.btn_signup}  ' : "${AppLocalizations.of(context)!.btn_logout} ",
                        leadingIconUrl: ImageConstants.logoutLogoUrl,
                        onPressed: () {
                          if (global.currentUser!.id == null) {
                            Get.to(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
                          } else {
                            _signOutDialog();
                          }
                        },
                      ),
                      const SizedBox(height: 32)
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  _signOutDialog() async {
    try {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: Text(
            '${AppLocalizations.of(context)!.btn_logout}  ',
          ),
          content: Text(
            '${AppLocalizations.of(context)!.txt_logout_app_msg}  ',
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.lbl_cancel),
              onPressed: () {
                return Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.btn_logout, style: const TextStyle(color: Colors.red)),
              onPressed: () async {
                global.sp!.remove("currentUser");
                global.currentUser= CurrentUser();
                Get.offAll(() => LoginScreen(analytics: widget.analytics, observer: widget.observer));
              },
            ),
          ],
        )
      );
    } catch (e) {
      debugPrint('Exception - app_menu_screen.dart - exitAppDialog(): $e');
    }
  }
}

class UserInfoTile extends StatefulWidget {
  final TextTheme textTheme;

  const UserInfoTile({super.key, 
    required this.textTheme,
  });

  @override
  State<UserInfoTile> createState() => _UserInfoTileState();
}

class _UserInfoTileState extends State<UserInfoTile> {

  _UserInfoTileState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          global.currentUser!.id != null && global.currentUser!.userImage != null
              ? UserImage(url: global.appInfo!.imageUrl! + global.currentUser!.userImage!)
              : CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
          const SizedBox(width: 16),
          global.currentUser!.id != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      global.currentUser!.name!,
                      style: widget.textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      global.currentUser!.userPhone!,
                      style: widget.textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                )
              : Text(AppLocalizations.of(context)!.txt_Login_SignUp,
                  style: widget.textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  )
                ),
        ],
      ),
    );
  }
}

class UserImage extends StatelessWidget {
  final String imageUrl;

  const UserImage({super.key, required String url}): imageUrl = url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 25,
        backgroundImage: imageProvider,
        backgroundColor: Colors.white,
      ),
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => CircleAvatar(
          backgroundColor: Colors.white,
          radius: 25,
          child: Icon(
            Icons.person,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          )
      ),
    );
  }

}