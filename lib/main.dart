import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'views/home_view.dart';
import 'controllers/app_controller.dart';
import 'controllers/vault_controller.dart';
import 'controllers/astrology_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(KundaliLockApp());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Same as scaffold/app bar background
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

class KundaliLockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppController()),
        ChangeNotifierProvider(create: (_) => VaultController()),
        ChangeNotifierProvider(create: (_) => AstrologyController()),
      ],
      child: MaterialApp(
        title: 'Kundali Viewer',

        //
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        home: HomeView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
