// import 'package:fe/screens/chat/chat.room.screen.dart';
// import 'dart:async';

import 'dart:async';

import 'package:extended/extended.dart';
import 'package:fe/screens/admin/admin.screen.dart';
import 'package:fe/screens/admin/category.screen.dart';
import 'package:fe/screens/admin/report.post.management.screen.dart';
import 'package:fe/screens/admin/report.screen.dart';
import 'package:fe/screens/forum/post.list.screen.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/setting/notification.setting.dart';
import 'package:fe/service/app.service.dart';
import 'package:fe/service/global.keys.dart';
import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/chat/chat.rooms.blocked.screen.dart';
import 'package:fe/screens/chat/chat.rooms.screen.dart';
import 'package:fe/screens/email_verification/email_verification.screen.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/screens/help/help.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in/sms_code.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/sms_code_ui.screen.dart';
import 'package:fe/screens/profile/profile.screen.dart';
import 'package:fe/screens/reminder/reminder.edit.screen.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

typedef RouteFunction = Widget Function(BuildContext, Map);
final Map<String, RouteFunction> routes = {
  HomeScreen.routeName: (context, arguments) => const HomeScreen(),
  SignInWidget.routeName: (context, arguments) => const SignInWidget(),
  PhoneSignInScreen.routeName: (context, arguments) => const PhoneSignInScreen(),
  SmsCodeScreen.routeName: (context, arguments) => const SmsCodeScreen(),
  PhoneSignInUIScreen.routeName: (context, arguments) => const PhoneSignInUIScreen(),
  SmsCodeUIScreen.routeName: (context, arguments) => const SmsCodeUIScreen(),
  HelpScreen.routeName: (context, arguments) => HelpScreen(arguments: arguments),
  ProfileScreen.routeName: (context, arguments) => ProfileScreen(key: profileScreenKey),
  PostListScreen.routeName: (context, arguments) => PostListScreen(arguments: arguments),
  PostFormScreen.routeName: (context, arguments) => PostFormScreen(arguments: arguments),
  AdminScreen.routeName: (context, arguments) => AdminScreen(),
  NotificationSettingScreen.routeName: (context, arguments) => NotificationSettingScreen(),
  ReportPostManagementScreen.routeName: (context, arguments) =>
      ReportPostManagementScreen(arguments: arguments),
  CategoryScreen.routeName: (context, arguments) => CategoryScreen(),
  ChatRoomScreen.routeName: (context, arguments) => ChatRoomScreen(arguments: arguments),
  ChatRoomsScreen.routeName: (context, arguments) => ChatRoomsScreen(),
  ChatRoomsBlockedScreen.routeName: (context, arguments) => ChatRoomsBlockedScreen(),
  FriendMapScreen.routeName: (context, arguments) => FriendMapScreen(arguments: arguments),
  ReminderEditScreen.routeName: (context, arguments) => ReminderEditScreen(),
  ReportScreen.routeName: (context, arguments) => ReportScreen(arguments: arguments),
  EmailVerificationScreen.routeName: (context, arguments) => EmailVerificationScreen(),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MainApp(
    initialLink: await DynamicLinkService.instance.initialLink,
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({required this.initialLink, Key? key}) : super(key: key);
  final PendingDynamicLinkData? initialLink;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    /// Instantiate UserService & see debug print message
    if (UserService.instance.user.isAdmin) {
      print('The user is admin...');
    }

    PresenceService.instance.activate(
      onError: (e) => debugPrint('--> Presence error: $e'),
    );

    ExtendedService.instance.navigatorKey = globalNavigatorKey;

    // Timer(const Duration(milliseconds: 200), () => Get.toNamed('/email-verify'));
    // Timer(const Duration(milliseconds: 200), AppController.of.openCategory);
    // Timer(const Duration(milliseconds: 200),
    //     () => AppController.of.openPostList(category: 'qna'));

    // Open qna & open first post
    // Timer(const Duration(milliseconds: 100), () async {
    //   AppController.of.openPostList(category: 'qna');

    //   /// wait
    //   await Future.delayed(Duration(milliseconds: 200));
    // });

    /// Dynamic links for terminated app.
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      // Example of using the dynamic link to push the user to a different screen

      /// If you do alert too early, it may not appear on screen.
      WidgetsBinding.instance?.addPostFrameCallback((dr) {
        alert('Terminated app',
            'Got dynamic link event. deepLink.path; ${deepLink.path},  ${deepLink.queryParametersAll}');
        // Get.toNamed(deepLink.path, arguments: deepLink.queryParameters);
      });
    }

    ///
    DynamicLinkService.instance.listen((Uri? deepLink) {
      alert('Background 2',
          'Dyanmic Link Event on background(or foreground). deepLink.path; ${deepLink?.path}, ${deepLink?.queryParametersAll}');
    });

    /// Listen to FriendMap
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        /// Re-init for listening the login user (when account changed)
        InformService.instance.init(callback: (data) {
          if (data['type'] == 'FriendMap') {
            /// If it's a freind map request, then open friend map screen.
            AppService.instance.open(FriendMapScreen.routeName, arguments: {
              'latitude': data['latitude'],
              'longitude': data['longitude'],
            });
          }
        });
      } else {
        InformService.instance.dispose();
      }
    });

    /// Listen to reminder
    ///
    /// Delay 3 seconds. This is just to display the reminder dialog 3 seconds
    /// after the app boots. No big deal here.
    Timer(const Duration(seconds: 3), () {
      /// Listen to the reminder update event.
      ReminderService.instance.init(onReminder: (reminder) {
        /// Display the reminder using default dialog UI. You may copy the code
        /// and customize by yourself.
        ReminderService.instance.display(
          context: globalNavigatorKey.currentContext!,
          data: reminder,
          onLinkPressed: (page, arguments) {
            /// TODO: post view 스크린을 만들고, 글을 보여주어야 겠다.
            AppService.instance.open(page, arguments: arguments);
          },
        );
      });
    });

    MessagingService.instance.init(
      // while the app is close and notification arrive you can use this to do small work
      // example are changing the badge count or informing backend.
      onBackgroundMessage: _firebaseMessagingBackgroundHandler,
      onForegroundMessage: (message) {
        // this will triggered while the app is opened
        // If the message has data, then do some extra work based on the data.
        print(message);
        onMessageOpenedShowMessage(message);
      },
      onMessageOpenedFromTermiated: (message) {
        // this will triggered when the notification on tray was tap while the app is closed
        onMessageOpenedShowMessage(message);
      },
      onMessageOpenedFromBackground: (message) {
        // this will triggered when the notification on tray was tap while the app is open but in background state.
        onMessageOpenedShowMessage(message);
      },
      onNotificationPermissionDenied: () {
        print('onNotificationPermissionDenied()');
      },
      onNotificationPermissionNotDetermined: () {
        print('onNotificationPermissionNotDetermined()');
      },
      onTokenUpdated: (token) {
        // print('##########onTokenUpdated###########');
        // print(token);
      },
    );
  }

  onMessageOpenedShowMessage(message) {
    // Handle the message here
    // print(message);
    showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (c) => AlertDialog(
        title: Text(message.notification!.title ?? ''),
        content: Text(message.notification!.body ?? ''),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    PresenceService.instance.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (c) => routes[settings.name]!(c, (settings.arguments ?? {}) as Map),
        );
      },
      // routes: {
      //   HomeScreen.routeName: (context) => const HomeScreen(),
      //   SignInWidget.routeName: (context) => const SignInWidget(),
      //   // '/sign-in-screen': (context) => SignInScreen(),
      //   PhoneSignInScreen.routeName: (context) => const PhoneSignInScreen(),
      //   SmsCodeScreen.routeName: (context) => const SmsCodeScreen(),
      //   PhoneSignInUIScreen.routeName: (context) => const PhoneSignInUIScreen(),
      //   SmsCodeUIScreen.routeName: (context) => const SmsCodeUIScreen(),
      //   HelpScreen.routeName: (context) => const HelpScreen(),
      //   ProfileScreen.routeName: (context) => ProfileScreen(key: profileScreenKey),
      //   PostListScreen.routeName: (context) => PostListScreen(),
      //   PostFormScreen.routeName: (context) => PostFormScreen(),
      //   AdminScreen.routeName: (context) => AdminScreen(),
      //   NotificationSettingScreen.routeName: (context) => NotificationSettingScreen(),
      //   ReportPostManagementScreen.routeName: (context) => ReportPostManagementScreen(),
      //   CategoryScreen.routeName: (context) => CategoryScreen(),
      //   ChatRoomScreen.routeName: (context) => ChatRoomScreen(),
      //   ChatRoomsScreen.routeName: (context) => ChatRoomsScreen(),
      //   ChatRoomsBlockedScreen.routeName: (context) => ChatRoomsBlockedScreen(),
      //   FriendMapScreen.routeName: (context) => FriendMapScreen(),
      //   ReminderEditScreen.routeName: (context) => ReminderEditScreen(),
      //   ReportScreen.routeName: (context) => ReportScreen(),
      //   EmailVerificationScreen.routeName: (context) => EmailVerificationScreen(),
      // }

      // getPages: [
      //   GetPage(name: RouteNames.home, page: () => const HomeScreen()),
      //   GetPage(
      //     name: '/sign-in',
      //     page: () => const SignInWidget(),
      //   ),
      //   GetPage(name: '/phone-sign-in', page: () => const PhoneSignInScreen()),
      //   GetPage(name: '/sms-code', page: () => const SmsCodeScreen()),
      //   GetPage(name: '/phone-sign-in-ui', page: () => const PhoneSignInUIScreen()),
      //   GetPage(name: '/sms-code-ui', page: () => const SmsCodeUIScreen()),
      //   GetPage(name: '/help', page: () => const HelpScreen()),
      //   GetPage(
      //     name: RouteNames.profile,
      //     page: () => ProfileScreen(
      //       key: profileScreenKey,
      //     ),
      //   ),
      //   GetPage(name: RouteNames.postList, page: () => PostListScreen()),
      //   GetPage(name: RouteNames.postForm, page: () => PostFormScreen()),
      //   GetPage(name: RouteNames.admin, page: () => AdminScreen()),
      //   GetPage(name: RouteNames.notificationSetting, page: () => NotificationSettingScreen()),
      //   GetPage(
      //     name: RouteNames.reportForumManagement,
      //     page: () => ReportPostManagementScreen(),
      //   ),
      //   GetPage(name: RouteNames.category, page: () => CategoryScreen()),
      //   GetPage(name: '/chat-room-screen', page: () => const ChatRoomScreen()),
      //   GetPage(
      //     name: '/chat-rooms-screen',
      //     page: () => const ChatRoomsScreen(),
      //   ),
      //   GetPage(
      //     name: '/chat-rooms-blocked-screen',
      //     page: () => const ChatRoomsBlockedScreen(),
      //   ),
      //   GetPage(name: '/friend-map', page: () => const FriendMapScreen()),
      //   GetPage(name: '/reminder-edit', page: () => ReminderEditScreen()),
      //   GetPage(name: RouteNames.report, page: () => ReportScreen()),
      //   GetPage(name: '/email-verify', page: () => const EmailVerificationScreen())
      // ],
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  // print("---> Handling a background message: ${message.messageId}");
  if (message.data['type'] == 'chat' && message.data['badge'] != null) {
    FlutterAppBadger.updateBadgeCount(int.parse(message.data['badge']));
  }
}
