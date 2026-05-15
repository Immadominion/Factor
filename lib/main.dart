import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:factor/src/repository.dart';
import 'package:factor/src/screens.dart';
import 'package:factor/src/view_model.dart';
import 'package:factor/view/theme/factor_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FactorApp());
}

class FactorApp extends StatelessWidget {
  const FactorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Single PreferencesService instance shared by the calculator singleton
    // and the view model so persisted state stays in sync.
    final preferences = PreferencesService();
    unawaited(ExchangeRateCalculator().bindPreferences(preferences));

    return ScreenUtilInit(
      // Design size based on iPhone 14 Pro (393 x 852)
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeController>(
              create: (_) => ThemeController(),
            ),
            ChangeNotifierProvider<ExchangeRateViewModel>(
              create: (_) {
                final viewModel = ExchangeRateViewModel(
                  preferencesService: preferences,
                );
                unawaited(viewModel.initialize());
                return viewModel;
              },
            ),
          ],
          child: Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return MaterialApp(
                title: 'Factor',
                builder: BotToastInit(),
                navigatorObservers: [BotToastNavigatorObserver()],
                debugShowCheckedModeBanner: false,
                themeMode: themeController.themeMode,
                theme: FactorTheme.light(),
                darkTheme: FactorTheme.dark(),
                home: const ExchangeRateScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
