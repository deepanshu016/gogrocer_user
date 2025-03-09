import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/notification_model.dart';
import 'package:user/theme/style.dart';

class NotificationScreen extends BaseRoute {
  const NotificationScreen({super.key, super.analytics, super.observer, super.routeName = 'NotificationScreen'});
  @override
  BaseRouteState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends BaseRouteState {
  final List<NotificationModel> _notificationList = [];
  bool _isDataLoaded = false;
  int page = 1;
  bool _isRecordPending = true;
  bool _isMoreDataLoaded = false;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final ScrollController _scrollController = ScrollController();
  _NotificationScreenState() : super();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
          ),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.btn_notification,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          _notificationList.isNotEmpty
              ? IconButton(
                  onPressed: () async {
                    await deleteConfirmationDialog();
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.primary,
                  ))
              : const SizedBox()
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: RefreshIndicator(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              _isDataLoaded = false;
              _isRecordPending = true;
              _notificationList.clear();
              setState(() {});
              await _init();
            },
            child: _isDataLoaded
                ? _notificationList.isNotEmpty
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _notificationList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      leading: Container(
                                          height: 50,
                                          width: 50,
                                          alignment: Alignment.center,
                                          child: _notificationList[index].image != null
                                              ? CachedNetworkImage(
                                                  imageUrl: global.appInfo!.imageUrl! + _notificationList[index].image!,
                                                  imageBuilder: (context, imageProvider) => Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(15),
                                                      color: Colors.red,
                                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) => Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(15),
                                                      image: DecorationImage(image: AssetImage(global.defaultImage), fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(15),
                                                    image: DecorationImage(image: AssetImage(global.defaultImage), fit: BoxFit.cover),
                                                  ),
                                                )),
                                      title: Text(
                                        _notificationList[index].notiTitle!,
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      subtitle: RichText(
                                        text: TextSpan(
                                          text: "${_notificationList[index].notiMessage}",
                                          style: normalCaptionStyle(context),
                                          children: [
                                            TextSpan(
                                              text: '\n${br.timeString(_notificationList[index].createdAt!)}',
                                              style: normalCaptionStyle(context).copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ),
                            _isMoreDataLoaded
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
                      )
                : _shimmerWidget(),
          ),
        ),
      ),
    );
  }

  Future deleteConfirmationDialog() async {
    try {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.lbl_delete_notification),
              content: Text(AppLocalizations.of(context)!.txt_delete_notification_desc, style: normalCaptionStyle(context)),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _deleteAllNotification();
                    },
                    child: Text(AppLocalizations.of(context)!.btn_yes)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.btn_no))
              ],
            );
          });
    } catch (e) {
      debugPrint("Exception - notification_screen.dart - deleteConfirmationDialog():$e");
      return false;
    }
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  _deleteAllNotification() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        showOnlyLoaderDialog();
        await apiHelper.deleteAllNotification().then((result) async {
          if (result != null) {
            if (result.status == "1") {
              hideLoader();
              _notificationList.clear();
              setState(() {});
            }
          }
        });
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - notification_screen.dart - _deleteAllNotification():$e");
    }
  }

  _getData() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (_isRecordPending) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          if (_notificationList.isEmpty) {
            page = 1;
          } else {
            page++;
          }
          await apiHelper.getAllNotification(page).then((result) async {
            if (result != null) {
              if (result.status == "1") {
                List<NotificationModel> tList = result.data;
                if (tList.isEmpty) {
                  _isRecordPending = false;
                }
                _notificationList.addAll(tList);
                setState(() {
                  _isMoreDataLoaded = false;
                });
              }
            }
          });
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
    } catch (e) {
      debugPrint("Exception - notification_screen.dart - _getData():$e");
    }
  }

  _init() async {
    try {
      await _getData();
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isMoreDataLoaded) {
          setState(() {
            _isMoreDataLoaded = true;
          });
          await _getData();
          setState(() {
            _isMoreDataLoaded = false;
          });
        }
      });
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - notification_screen.dart - _init():$e");
    }
  }

  Widget _shimmerWidget() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                  const Divider(),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - notification_screen.dart - _shimmerWidget():$e");
      return const SizedBox();
    }
  }
}
