import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kinopark/tools/http_bloc.dart';

void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider<HttpBloc>(create: (_) => HttpBloc(HttpState()))
  ], child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      locale: const Locale('hy'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('hy'), Locale('ru')],
      home: const AppPage(),
    );
  }
}

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: FutureBuilder(
            future: _loadApp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _preloadingLogo();
              }
              return Container();
            }));
  }

  Widget _preloadingLogo() {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Image.asset('assets/kinopark.png'), CircularProgressIndicator()]));
  }

  Future<bool> _loadApp() async {
    await Future.delayed(const Duration(seconds: 4));
    return true;
  }
}
