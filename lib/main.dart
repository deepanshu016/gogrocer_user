import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:user/l10n/l10n.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/local_notification_model.dart';
import 'package:user/provider/local_provider.dart';
import 'package:user/screens/splash_screen.dart';
import 'package:user/theme/style.dart';

import 'networking/my_http_client.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      // To generate your app configuration follows step 1 and 2 at the
      // following link: https://firebase.google.com/docs/flutter/setup?platform=ios
      options: DefaultFirebaseOptions.currentPlatform
    );
  } catch (e) {
    debugPrint(e.toString());
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
}

AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    importance: Importance.high,
    description: 'Channel Description',
    playSound: true);

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('Handling a background message ${message.messageId}');
  } catch (e) {
    debugPrint('Exception - main.dart - _firebaseMessagingBackgroundHandler(): $e');
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final String routeName = "main";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          return GetMaterialApp(
              navigatorObservers: <NavigatorObserver>[observer],
              debugShowCheckedModeBanner: false,
              title: "Go Grocer",
              locale: Get.deviceLocale,
              supportedLocales: L10n.all,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              home: SplashScreen(
                analytics: analytics,
                observer: observer,
              ),
              theme: ThemeUtils.defaultAppThemeData,
              darkTheme: ThemeUtils.darkAppThemData,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    setupNotifications();
  }

  void setupNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        LocalNotification notificationModel =
            LocalNotification.fromJson(message.data);
        global.localNotificationModel = notificationModel;
        global.isChatNotTapped = false;

        if (message.notification != null) {
          Future<String> downloadAndSaveFile(
              String url, String fileName) async {
            final Directory directory =
                await getApplicationDocumentsDirectory();
            final String filePath = '${directory.path}/$fileName';
            final http.Response response = await http.get(Uri.parse(url));
            final File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            return filePath;
          }

          if (Platform.isAndroid) {
            String bigPicturePath;
            AndroidNotificationDetails androidPlatformChannelSpecifics;
            if (message.notification?.android?.imageUrl != null &&
                '${message.notification?.android?.imageUrl}' != 'N/A') {
              debugPrint('in Image');
              debugPrint('${message.notification?.android?.imageUrl}');
              bigPicturePath = await downloadAndSaveFile(
                  message.notification?.android?.imageUrl != null
                      ? message.notification!.android!.imageUrl!
                      : 'https://picsum.photos/200/300',
                  'bigPicture');
              final BigPictureStyleInformation bigPictureStyleInformation =
                  BigPictureStyleInformation(
                FilePathAndroidBitmap(bigPicturePath),
              );
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  channel.id, channel.name,
                  channelDescription: channel.description,
                  icon: 'ic_notification',
                  styleInformation: bigPictureStyleInformation,
                  playSound: true);
            } else {
              debugPrint('in No Image');
              androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  channel.id, channel.name,
                  channelDescription: channel.description,
                  icon: 'ic_notification',
                  styleInformation:
                      BigTextStyleInformation(message.notification!.body!),
                  playSound: true);
            }
            // final AndroidNotificationDetails androidPlatformChannelSpecifics2 =
            final NotificationDetails platformChannelSpecifics =
                NotificationDetails(android: androidPlatformChannelSpecifics);
            flutterLocalNotificationsPlugin.show(1, message.notification!.title,
                message.notification!.body, platformChannelSpecifics);
          } else if (Platform.isIOS) {
            final String bigPicturePath = await downloadAndSaveFile(
                message.notification?.apple?.imageUrl != null
                    ? message.notification!.apple!.imageUrl!
                    : 'https://picsum.photos/200/300',
                'bigPicture.jpg');
            final DarwinNotificationDetails iOSPlatformChannelSpecifics =
                DarwinNotificationDetails(attachments: <DarwinNotificationAttachment>[
              DarwinNotificationAttachment(bigPicturePath)
            ], presentSound: true);
            const DarwinNotificationDetails iOSPlatformChannelSpecifics2 =
                DarwinNotificationDetails(presentSound: true);
            final NotificationDetails notificationDetails = NotificationDetails(
              iOS: message.notification?.apple?.imageUrl != null
                  ? iOSPlatformChannelSpecifics
                  : iOSPlatformChannelSpecifics2,
            );
            await flutterLocalNotificationsPlugin.show(
                1,
                message.notification!.title,
                message.notification!.body,
                notificationDetails);
          }
        }
      } catch (e) {
        debugPrint('Exception - main.dart - onMessage.listen(): $e');
      }
    });
  }
}
