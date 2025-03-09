import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/controllers/user_profile_controller.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/user_model.dart';
import 'package:user/screens/add_address_screen.dart';
import 'package:user/screens/address_list_screen.dart';
import 'package:user/screens/change_password_screen.dart';
import 'package:user/screens/profile_edit_screen.dart';
import 'package:user/widgets/profile_picture.dart';

class UserInfoTile extends StatefulWidget {
  final String? value;
  final Widget? leadingIcon;
  final String heading;
  final Function? onPressed;

  const UserInfoTile(
      {super.key, required this.heading,
      this.value,
      this.leadingIcon,
      this.onPressed,
      });

  @override
  State<UserInfoTile> createState() => _UserInfoTileState();
}

class UserOrdersDashboardBox extends StatefulWidget {
  final String heading;
  final String? value;

  const UserOrdersDashboardBox({super.key, required this.heading, this.value});

  @override
  State<UserOrdersDashboardBox> createState() =>
      _UserOrdersDashboardBoxState();
}

class UserProfileScreen extends BaseRoute {
  const UserProfileScreen({super.key, super.analytics, super.observer, super.routeName = 'UserProfileScreen'});

  @override
  BaseRouteState createState() => _UserProfileScreenState();
}

class _UserInfoTileState extends State<UserInfoTile> {

  _UserInfoTileState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => widget.onPressed!(),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widget.leadingIcon ?? Container(),
                  widget.leadingIcon == null ? Container() : const SizedBox(width: 8),
                  Text(
                    widget.heading,
                    style: textTheme.bodyLarge!.copyWith(
                        fontWeight:
                        widget.value == null ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              widget.value == null
                  ? Container()
                  : Text(
                widget.value!,
                      style: textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
              widget.value == null ? Container() : const SizedBox(height: 8),
              const Divider(
                thickness: 2.0,
              ),
            ],
          ),
          widget.onPressed == null
              ? Container()
              : Positioned(
                  bottom: 24,
                  right: global.isRTL ? null : 0,
                  left: global.isRTL ? 0 : null,
                  child: const Icon(
                    Icons.chevron_right,
                  ),
                ),
        ],
      ),
    );
  }
}

class _UserOrdersDashboardBoxState extends State<UserOrdersDashboardBox> {
  Widget? leadingIcon;
  Function? onPressed;

  _UserOrdersDashboardBoxState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          widget.heading,
          style: textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.value!,
          style: textTheme.titleMedium,
        )
      ],
    );
  }
}

class _UserProfileScreenState extends BaseRouteState {
  bool _isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.txt_user_profile,
            style: textTheme.titleLarge,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => ProfileEditScreen(
                        analytics: widget.analytics,
                        observer: widget.observer,
                      ));
                },
                icon: const Icon(Icons.edit))
          ],
        ),
        body: _isDataLoaded
            ? GetBuilder<UserProfileController>(
                init: global.userProfileController,
                builder: (value) => RefreshIndicator(
                      onRefresh: () async {
                        _isDataLoaded = false;
                        global.userProfileController.currentUser = CurrentUser();
                        setState(() {});
                        await _getMyProfile();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: ProfilePicture(
                                    isShow: false,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  global.userProfileController.currentUser
                                                  ?.name !=
                                              null &&
                                      (global.userProfileController
                                                  .currentUser?.name?.isNotEmpty ?? false)
                                      ? global.userProfileController
                                          .currentUser?.name ?? ''
                                      : 'User',
                                  style: textTheme.titleLarge,
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(vertical: 32.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       UserOrdersDashboardBox(
                              //         heading: "${AppLocalizations.of(context).lbl_order}",
                              //         value: global.userProfileController.currentUser.totalOrders.toString(),
                              //       ),
                              //       UserOrdersDashboardBox(
                              //         value: '${global.appInfo.currencySign} ${global.userProfileController.currentUser.totalSaved}',
                              //         heading: "${AppLocalizations.of(context).lbl_saved}",
                              //       ),
                              //       UserOrdersDashboardBox(
                              //         value: '${global.appInfo.currencySign} ${global.userProfileController.currentUser.totalSpend}',
                              //         heading: "${AppLocalizations.of(context).lbl_spent}",
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              UserInfoTile(
                                  heading:
                                      AppLocalizations.of(context)!.lbl_phone_number,
                                  value: global.userProfileController
                                      .currentUser?.userPhone),
                              const SizedBox(height: 8),
                              UserInfoTile(
                                key: UniqueKey(),
                                heading:
                                    AppLocalizations.of(context)!.txt_address,
                                onPressed: () {
                                  global.userProfileController
                                                  .addressList.isNotEmpty
                                      ? Get.to(() => AddressListScreen(
                                                analytics: widget.analytics,
                                                observer: widget.observer,
                                              ))
                                      : Get.to(() => AddAddressScreen(
                                                Address(),
                                                analytics: widget.analytics,
                                                observer: widget.observer,
                                              ));
                                },
                                value: global.userProfileController
                                                .addressList.isNotEmpty
                                    ? global.userProfileController
                                        .addressList[0].houseNo
                                    : AppLocalizations.of(context)!.txt_nothing_to_show,
                              ),
                              const SizedBox(height: 8),
                              UserInfoTile(
                                heading:
                                    AppLocalizations.of(context)!.lbl_email,
                                value: global
                                    .userProfileController.currentUser?.email,
                              ),
                              const SizedBox(height: 16),
                              UserInfoTile(
                                heading:
                                    AppLocalizations.of(context)!.lbl_reset_password,
                                onPressed: () {
                                  Get.to(() => ChangePasswordScreen(
                                        analytics: widget.analytics,
                                        observer: widget.observer,
                                      ));
                                },
                                leadingIcon: const Icon(
                                  Icons.lock_outline,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ))
            : _shimmer());
  }

  @override
  void initState() {
    super.initState();
    if (global.currentUser!.id != null) {
      _getMyProfile();
    }
  }

  _getMyProfile() async {
    try {
      await global.userProfileController.getMyProfile();

      if (global.userProfileController.isDataLoaded.value == true) {
        _isDataLoaded = true;
      } else {
        _isDataLoaded = false;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Exception - UserProfileScreen.dart - _getMyProfile():$e");
    }
  }

  _shimmer() {
    try {
      return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Card(),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 60,
                        child: const Card()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 80,
                          width: (MediaQuery.of(context).size.width - 30) / 3,
                          child: const Card()),
                      SizedBox(
                          height: 80,
                          width: (MediaQuery.of(context).size.width - 30) / 3,
                          child: const Card()),
                      SizedBox(
                          height: 80,
                          width: (MediaQuery.of(context).size.width - 30) / 3,
                          child: const Card()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                  child: SizedBox(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: const Card()),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                  child: SizedBox(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: const Card()),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                  child: SizedBox(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: const Card()),
                ),
              ],
            ),
          ));
    } catch (e) {
      debugPrint("Exception - UserProfileScreen.dart - _shimmer():$e");
    }
  }
}
