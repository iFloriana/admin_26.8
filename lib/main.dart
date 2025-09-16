import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/commen_items/sharePrafrence.dart';
import 'package:flutter_template/route/app_page.dart';
import 'package:flutter_template/route/app_route.dart';
import 'package:flutter_template/utils/colors.dart';
import 'package:get/get.dart';
import 'network/dio.dart';

FlutterSecureStorage? storage;
final dioClient = DioClient();
final SharedPreferenceManager prefs = SharedPreferenceManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: primaryColor,
    statusBarColor: primaryColor,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ScreenUtil.defaultSize,
      child: GetMaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: lightbg,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: primaryColor,
            selectionColor: secondaryColor,
            selectionHandleColor: primaryColor,
          ),
        ),
        debugShowCheckedModeBanner: false,
        title: 'iFloriana_Super_Admin',
        initialRoute: Routes.splashScreen,
        getPages: AppPages.routes,
      ),
    );
  }
}
