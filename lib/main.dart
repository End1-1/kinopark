import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kinopark/screens/page0_base/model.dart';
import 'package:kinopark/screens/page1_home/screen.dart';
import 'package:kinopark/structs/dish.dart';
import 'package:kinopark/structs/dishpart1.dart';
import 'package:kinopark/structs/dishpart2.dart';
import 'package:kinopark/tools/app_bloc.dart';
import 'package:kinopark/tools/http_dio.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:kinopark/widgets/pin_form.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationSupportDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(DishPart1Adapter());
  Hive.registerAdapter(DishPart2Adapter());
  Hive.registerAdapter(DishAdapter());
  final locale = await Hive.openBox('locale');
  Tools.locale = locale.get('locale', defaultValue:  'hy');
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<HttpBloc>(create: (_) => HttpBloc(HttpState(0, const {}))),
        BlocProvider<Page1Bloc>(create: (_) => Page1Bloc(const Page1State(0))),
        BlocProvider<BasketBloc>(create: (_) => BasketBloc(const BasketState(0))),
        BlocProvider<LocaleBloc>(create: (_) => LocaleBloc(const LocaleState(0))),
        BlocProvider<AppErrorBloc>(create: (_) => AppErrorBloc(const AppErrorState(0, ''))),
        BlocProvider<AppQuestionBloc>(create: (_) => AppQuestionBloc(AppQuestionState(0, '', (){}, null))),
        BlocProvider<AppLoadingBloc>(create: (_) => AppLoadingBloc(LoadingState(0, false)))
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(builder: (builder, state) {
        return KinoparkApp();
      })));
}

class KinoparkApp extends StatelessWidget {
  KinoparkApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      locale: Locale(Tools.locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('hy'), Locale('ru')],
      home: AppPage(),
    );
  }
}

class AppPage extends StatefulWidget {
  final _model = AppModel();

  AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage> {
  late Future<Object> _loadingFunc;
  String? _pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: FutureBuilder(
            future: _loadingFunc,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _preloadingLogo();
              }
              if (snapshot.hasError) {
                return _errorWidget(snapshot.error.toString());
              }
              if (snapshot.data is Map) {
                final m = snapshot.data as Map<String, dynamic>;
                if (m['needauth'] ?? false) {
                  return _authWidget();
                }
              }
              Future.microtask(() {
                Navigator.pushReplacement(
                    tools.context(),
                    MaterialPageRoute(
                        builder: (builder) => HomePage(widget._model)));
              });
              return Container();
            }));
  }

  Widget _preloadingLogo() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Image.asset('assets/kinopark.png', height: 200),
          const CircularProgressIndicator()
        ]));
  }

  Widget _errorWidget(String err) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Image.asset('assets/kinopark.png', height: 200),
          Row(children: [
            Expanded(child: Text(err, textAlign: TextAlign.center))
          ]),
          TextButton(
              onPressed: _retry,
              child:
                  Text(AppLocalizations.of(tools.context())?.retry ?? 'Retry')),
        ]));
  }

  Widget _authWidget() {
    return PinForm(pinOk: (pin) async {
      _pin = pin;
      _loadingFunc = _tryAuth();
      setState(() {});
    });
  }

  Future<Object> _loadApp() async {
    tools = await SharedPreferences.getInstance();
    widget._model.init();
    if ((tools.getString('sessionkey') ?? '').isEmpty) {
      return Future.value({'needauth': true});
    }
    var r1 = await HttpDio().post('login.php', inData: {'method': 3});
    r1 = r1['data']['config']['f_config'];
    tools.setInt('hall', r1['hall']);
    tools.setInt('table', r1['table']);
    final oldConfig = tools.getInt('menuversion') ?? 0;
    widget._model.part1.list.clear();
    int newConfig = int.tryParse(r1['menuversion']) ?? 0;
    if (oldConfig != newConfig) {
      var r2 = await HttpDio().post('kinopark/loadapp.php', inData: {});
      for (final e in r2['part1']) {
        final part1 = DishPart1.fromJson(e);
        widget._model.part1.list.add(part1);
      }
      final boxPart1 = await Hive.openBox<List>('part1');
      await boxPart1.put('part1list', widget._model.part1.list);
      boxPart1.close();
      widget._model.part2.list.clear();
      for (final e in r2['part2']) {
        final part2 = DishPart2.fromJson(e);
        widget._model.part2.list.add(part2);
      }
      final boxPart2 = await Hive.openBox<List>('part2');
      await boxPart2.put('part2list', widget._model.part2.list);
      boxPart2.close();
      widget._model.dishes.list.clear();
      for (final e in r2['menu']) {
        final dish = Dish.fromJson(e);
        widget._model.dishes.list.add(dish);
      }
      final boxDishes = await Hive.openBox<List>('dish');
      await boxDishes.put('dish', widget._model.dishes.list);
      boxDishes.close();
      tools.setInt('menuversion', newConfig);
    } else {
      try {
        final boxPart1 = await Hive.openBox<List>('part1');
        final boxPart2 = await Hive.openBox<List>('part2');
        final boxDishes = await Hive.openBox<List>('dish');
        widget._model.part1.list =
            boxPart1.get('part1list', defaultValue: [])?.cast<DishPart1>() ??
                [];
        widget._model.part2.list =
            boxPart2.get('part2list', defaultValue: [])?.cast<DishPart2>() ??
                [];
        widget._model.dishes.list =
            boxDishes.get('dish', defaultValue: [])?.cast<Dish>() ?? [];
      } catch (e) {
        final directory = await getApplicationSupportDirectory();
        final hiveDir = Directory(directory.path);
        await hiveDir.delete(recursive: true);
        tools.setInt('menuversion', -1);
        return await _loadApp();
      }
    }
    final basketBox = await Hive.openBox<List>('basket');
    widget._model.basket
        .addAll(basketBox.get('basket', defaultValue: [])?.cast<Dish>() ?? []);
    return true;
  }

  void _retry() async {
    _loadingFunc = _loadApp();
    setState(() {});
  }

  Future<Object> _tryAuth() async {
    if ((_pin ?? '').isEmpty) {
      return Future.value({'needauth': true});
    }
    final tempPin = _pin;
    _pin = '';

    var data = await HttpDio()
        .post('login.php', inData: {'pin': tempPin, 'method': 2});
    data = data['data'];
    tools.setString('sessionkey', data['sessionkey']);
    data = data['config'];
    _loadingFunc = _loadApp();
    setState(() {});
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadingFunc = _loadApp();
  }
}
