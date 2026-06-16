import 'package:agenda/app/app_routes.dart';
import 'package:agenda/app/app_theme.dart';
import 'package:agenda/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Widget raiz da aplicação.
/// Configura tema, rotas e inicialização.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Agenda Inteligente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .light, // TODO: Mudar para system quando tiver modo escuro 100% funcional.
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      navigatorObservers: [homeRouteObserver],
    );
  }
}
