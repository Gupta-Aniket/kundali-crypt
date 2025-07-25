import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../controllers/astrology_controller.dart';
import '../controllers/vault_controller.dart';
import '../models/birth_info.dart';
import 'birth_form_view.dart';
import 'kundali_display_view.dart';
import 'pattern_unlock_view.dart';
import 'vault_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Same as scaffold/app bar background
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Consumer<AppController>(
        builder: (context, appController, child) {
          Widget currentView;

          switch (appController.currentMode) {
            case AppMode.public:
              currentView =
                  appController.kundali == null
                      ? BirthFormView()
                      : KundaliDisplayView();
              break;
            case AppMode.pattern:
              currentView = PatternUnlockView();
              break;
            case AppMode.vault:
            case AppMode.honeypot:
              currentView = VaultView();
              break;
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: Offset(0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              );

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },

            child: currentView,
          );
        },
      ),
    );
  }
}
