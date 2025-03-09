import 'package:cloud_firestore/cloud_firestore.dart';
import "package:collection/collection.dart";
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/message_model.dart';
import 'package:user/models/user_chat_model.dart';
import 'package:user/screens/image_view_screen.dart';
import 'package:user/utils/size_config.dart';

Future updateLastMessage(int? storeId, int? userId, String? lastMessage) async {
  List<QueryDocumentSnapshot> storeData = (await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: storeId).where('userId', isEqualTo: userId).get()).docs.toList();
  if (storeData.isNotEmpty) {
    FirebaseFirestore.instance.collection("store").doc(storeData[0].id).update({"lastMessage": lastMessage, "lastMessageTime": DateTime.now().toUtc(), "updatedAt": DateTime.now().toUtc()});
  }
}

class ChatScreen extends BaseRoute {
  const ChatScreen({super.key, super.analytics, super.observer, super.routeName = 'ChatScreen'});

  @override
  BaseRouteState createState() => _ChatScreenState();
}

class _ChatScreenState extends BaseRouteState {
  UserChat userChat = UserChat();
  bool isDone = false;
  MessagesModel messageModel = MessagesModel();
  List<MessagesModel>? messages = [];
  final TextEditingController _message = TextEditingController();
  bool isShowSticker = false;
  final DateTime _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String? chatId;
  XFile? _tImage;

  bool isAlreadyChat = false;
  GlobalKey<ScaffoldState>? _scaffoldKey;

  bottomChatBar() {
    return SizedBox(
      height: SizeConfig.blockSizeVertical * 4,
      width: SizeConfig.screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 16,
            child: IconButton(
              icon: Image.asset("assets/images/upload_image_icon.png"),
              iconSize: 40,
              onPressed: () async {
                _showCupertinoModalSheet();
              },
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: _message,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(2),
                labelText: "${AppLocalizations.of(context)!.txt_type_here} ",
                hintStyle: TextStyle(fontSize: 12, color: const Color(0xFF1F1F1F).withOpacity(0.4)),
                border: InputBorder.none,
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: IconButton(
                    icon: Image.asset("assets/images/sendbtn.png"),
                    onPressed: () async {
                      await sendMessage();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    TextTheme textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          if (messages != null && messages!.isNotEmpty && messages!.first.message != null && messages!.first.message!.isNotEmpty) {
            await updateLastMessage(global.nearStoreModel!.id, global.currentUser!.id, messages!.first.message);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: customAppBar(textTheme),
        body: LayoutBuilder(
          builder: (context, constraints) => Scrollbar(
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: StreamBuilder<List<MessagesModel>>(
                      stream: apiHelper.getChatMessages(chatId, global.currentUser!.id.toString()),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          default:
                            if (snapshot.hasError) {
                              return buildText('${AppLocalizations.of(context)!.txt_something_went_wrong} ');
                            } else {
                              messages = snapshot.data;
                              messages ??= [];

                              return messages!.isEmpty
                                  ? buildText(AppLocalizations.of(context)!.txt_sayHI)
                                  : Padding(
                                      padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 12),
                                      child: ListView.builder(
                                        reverse: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: messages!.length,
                                        itemBuilder: (context, index) {
                                          var groupDate = groupBy(messages!, (dynamic a) => a.createdAt.toString().substring(0, 10));
                                          groupDate.forEach((key, value) {
                                            MessagesModel m = value.lastWhere((e) => e.createdAt.toString().substring(0, 10) == key.toString());
                                            messages![messages!.indexOf(m)].isShowDate = true;
                                            isDone = true;
                                          });
                                          final message = messages![index];
                                          return _buildMessage(
                                            message,
                                            message.userId1 == global.currentUser!.id.toString(),
                                          );
                                        },
                                      ),
                                    );
                            }
                        }
                      }),
                )
              ],
            ),
          ),
        ),
        bottomSheet: SizedBox(
          height: SizeConfig.blockSizeVertical * 12,
          child: bottomChatBar(),
        ),
      ),
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24),
        ),
      );

  Future<void> checkChatStoreExist() async {
    try {
      EmailExist result;
      result = await apiHelper.checkStoreExist(global.nearStoreModel!.id, global.currentUser!.id);
      String? token = await FirebaseMessaging.instance.getToken();
      await apiHelper.updateFirebaseUserFcmToken(global.currentUser!.id, token);
      chatId = result.id;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - ChatScreen.dart - checkChatStoreExist():$e");
    }
  }

  customAppBar(TextTheme textTheme) {
    return PreferredSize(
        preferredSize: Size.fromHeight(SizeConfig.blockSizeVertical * 10),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () async {
                  if (messages != null && messages!.isNotEmpty && messages!.first.message != null && messages!.first.message!.isNotEmpty) {
                    await updateLastMessage(global.nearStoreModel!.id, global.currentUser!.id, messages!.first.message);
                  }

                  Get.back();
                },
                child: const Icon(
                  Icons.keyboard_arrow_left,
                  size: 30,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.txt_cust_support,
                      style: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    AppLocalizations.of(context)!.txt_ask_any_questions,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              global.nearStoreModel!.phoneNumber != null
                  ? InkWell(
                      onTap: () {
                        launchCaller(global.nearStoreModel!.phoneNumber);
                      },
                      child: Transform.scale(
                          scale: 1.3,
                          child: Image.asset(
                            'assets/images/call_btn.png',
                          )))
                  : const SizedBox(),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  launchCaller(String? phone) async {
    String url = "tel:$phone";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> sendMessage() async {
    try {
      if (chatId != null) {
        isDone = false;
        if (_message.text.trim() != '') {
          messageModel.message = _message.text;
          messageModel.isActive = true;
          messageModel.isDelete = false;
          messageModel.createdAt = DateTime.now();
          messageModel.updatedAt = DateTime.now();
          messageModel.isRead = true;
          messageModel.userId1 = global.currentUser!.id.toString();
          messageModel.userId2 = "${global.nearStoreModel!.id}";
          messageModel.url = "";
          _message.clear();
          await apiHelper.uploadMessage(chatId, '${global.nearStoreModel!.id}', messageModel, isAlreadyChat, '');

          setState(() {
            isAlreadyChat = true;
          });
          if(!mounted) return;
          final localization = AppLocalizations.of(context);
          await apiHelper.callOnFcmApiSendPushNotifications(userToken: [global.nearStoreModel!.deviceId], title: "${localization!.txt_new_msg} ${global.currentUser!.name}", body: "${messageModel.message}", route: "chatlist_screen", chatId: chatId, firstName: global.currentUser!.name, lastName: global.currentUser!.name, userId: global.currentUser!.id.toString(), imageUrl: '', storeId: global.nearStoreModel!.id.toString(), globalUserToken: await FirebaseMessaging.instance.getToken());
        }
      } else {
        showSnackBar(key: _scaffoldKey, snackBarMessage: '${AppLocalizations.of(context)!.txt_something_went_wrong} ');
      }
    } catch (e) {
      debugPrint("Exception - ChatScreen.dart - sendMessage():$e");
    }
  }

  _buildMessage(MessagesModel message, bool isMe) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle timeStampStyle = textTheme.bodySmall!.copyWith(color: Colors.grey[400], fontSize: 12);
    DateTime indexTime = DateTime(message.createdAt!.year, message.createdAt!.month, message.createdAt!.day);
    return Column(
      children: [
        message.isShowDate
            ? Padding(
                padding: const EdgeInsets.only(top: 45, bottom: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 0.6,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Text(
                        _today.difference(indexTime).inDays == 0 ? '${AppLocalizations.of(context)!.txt_today} ' : _today.difference(indexTime).inDays == 1 ? '${AppLocalizations.of(context)!.txt_yesterday} ' : DateFormat('MMM dd, yyyy').format(message.createdAt!),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 0.6,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        isMe
            ? Padding(
                padding: const EdgeInsets.only(right: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                        child: GestureDetector(
                      onTap: () {
                        if (message.url != '') {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, animation1, animation2) => ImageViewScreen(
                                    url: message.url,
                                    analytics: widget.analytics,
                                    observer: widget.observer,
                                  )));
                        }
                      },
                      child: Container(
                        height: message.message == global.imageUploadMessageKey ? 200 : null,
                        width: message.message == global.imageUploadMessageKey ? 200 : null,
                        margin: isMe ? const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 50.0) : const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 80.0),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, image: message.url != "" ? DecorationImage(image: NetworkImage(message.url!), fit: BoxFit.cover) : null, border: message.message == global.imageUploadMessageKey ? Border.all(color: Colors.white, width: 2) : null, borderRadius: isMe ? const BorderRadius.only(topLeft: Radius.circular(25.0), bottomLeft: Radius.circular(25.0), topRight: Radius.circular(15.0)) : const BorderRadius.only(bottomRight: Radius.circular(15.0), topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))),
                        child: message.message == global.imageUploadMessageKey && message.url == ""
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : (message.message != "" && message.message != global.imageUploadMessageKey)
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(3),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: const BoxDecoration(
                                          // color: const Color(0xffF4F4F4),
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                        ),
                                        child: Text(
                                          message.message!,
                                          style: textTheme.bodyLarge,
                                        ),
                                      ),
                                      Text(
                                        DateFormat().add_jm().format(message.createdAt!),
                                        style: timeStampStyle,
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                      ),
                    )),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.person),
                    Flexible(
                        child: Container(
                      height: message.message == global.imageUploadMessageKey ? 200 : null,
                      width: message.message == global.imageUploadMessageKey ? 200 : null,
                      margin: isMe ? const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 50.0) : const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 80.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, image: message.url != "" ? DecorationImage(image: NetworkImage(message.url!), fit: BoxFit.cover) : null, border: message.message == global.imageUploadMessageKey ? Border.all(color: Colors.white, width: 2) : null, borderRadius: isMe ? const BorderRadius.only(topLeft: Radius.circular(25.0), bottomLeft: Radius.circular(25.0), topRight: Radius.circular(15.0)) : const BorderRadius.only(bottomRight: Radius.circular(15.0), topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))),
                      child: message.message == global.imageUploadMessageKey && message.url == ""
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : (message.message != "" && message.message != global.imageUploadMessageKey)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(3),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: const BoxDecoration(
                                        // color: const Color(0xffF4F4F4),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                      ),
                                      child: Text(
                                        message.message!,
                                        style: textTheme.bodyLarge,
                                      ),
                                    ),
                                    Text(
                                      DateFormat().add_jm().format(message.createdAt!),
                                      style: timeStampStyle,
                                    )
                                  ],
                                )
                              : const SizedBox(),
                    )),
                  ],
                ),
              )
      ],
    );
  }

  Future _init() async {
    try {
      await checkChatStoreExist();
    } catch (e) {
      debugPrint('Exception - chat_screen.dart - _init():$e');
    }
  }

  _showCupertinoModalSheet() {
    try {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text('${AppLocalizations.of(context)!.lbl_actions} '),
          actions: [
            CupertinoActionSheetAction(
              key: _scaffoldKey,
              child: Text(
                '${AppLocalizations.of(context)!.lbl_take_picture} ',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                _tImage = await br.openCamera();
                if (_tImage != null) {
                  messageModel.message = global.imageUploadMessageKey;
                  messageModel.isActive = true;
                  messageModel.isDelete = false;
                  messageModel.createdAt = DateTime.now();
                  messageModel.updatedAt = DateTime.now();
                  messageModel.isRead = true;
                  messageModel.userId1 = global.currentUser!.id.toString();
                  messageModel.userId2 = "${global.nearStoreModel!.id}";
                  messageModel.url = "";
                  await apiHelper.uploadImageToStorage(_tImage!, chatId, global.nearStoreModel!.id.toString(), messageModel);

                  setState(() {});
                }
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                '${AppLocalizations.of(context)!.txt_upload_image_desc} ',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
                _tImage = await br.selectImageFromGallery();
                if (_tImage != null) {
                  messageModel.message = global.imageUploadMessageKey;
                  messageModel.isActive = true;
                  messageModel.isDelete = false;
                  messageModel.createdAt = DateTime.now();
                  messageModel.updatedAt = DateTime.now();
                  messageModel.isRead = true;
                  messageModel.userId1 = global.currentUser!.id.toString();
                  messageModel.userId2 = "${global.nearStoreModel!.id}";
                  messageModel.url = "";
                  await apiHelper.uploadImageToStorage(_tImage!, chatId, global.nearStoreModel!.id.toString(), messageModel);

                  setState(() {});
                }
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context)!.lbl_cancel, style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Exception - chat_screen.dart - _showCupertinoModalSheet():$e");
    }
  }
}
