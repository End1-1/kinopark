import 'dart:convert';
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
import 'package:kinopark/tools/app_cubit.dart';
import 'package:kinopark/tools/http_dio.dart';
import 'package:kinopark/tools/tools.dart';
import 'package:kinopark/widgets/pin_form.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationSupportDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(DishPart1Adapter());
  Hive.registerAdapter(DishPart2Adapter());
  Hive.registerAdapter(DishAdapter());
  final locale = await Hive.openBox('locale');
  Tools.locale = locale.get('locale', defaultValue: 'hy');
  runApp(MultiBlocProvider(providers: [
    BlocProvider<HttpBloc>(create: (_) => HttpBloc(HttpState(0, const {}))),
    BlocProvider<Page1Bloc>(create: (_) => Page1Bloc(const Page1State(0))),
    BlocProvider<BasketBloc>(create: (_) => BasketBloc(const BasketState(0))),
    BlocProvider<LocaleBloc>(
        create: (_) => LocaleBloc(LocaleState(0, Tools.locale))),
    BlocProvider<AppErrorBloc>(
        create: (_) => AppErrorBloc(const AppErrorState(0, ''))),
    BlocProvider<AppQuestionBloc>(
        create: (_) => AppQuestionBloc(AppQuestionState(0, '', () {}, null))),
    BlocProvider<AppLoadingBloc>(
        create: (_) => AppLoadingBloc(LoadingState(0, false))),
    BlocProvider<AppMenuCubit>(create: (_) => AppMenuCubit()),
    BlocProvider<AppSearchTitleCubit>(create: (_) => AppSearchTitleCubit(''))
  ], child: KinoparkApp()));
}

class KinoparkApp extends StatelessWidget {
  KinoparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(builder: (builder, state) {
      navigatorKey = GlobalKey<NavigatorState>();
      return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Picasso',
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
          home: AppPage());
    });
  }
}

class AppPage extends StatefulWidget {
  final model = AppModel();

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
                if (snapshot.error
                    .toString()
                    .toLowerCase()
                    .contains('invalid session key')) {
                  return _authWidget();
                }
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
                        builder: (builder) => HomePage(widget.model)));
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
    final packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    //String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    tools.setString('app_version', '$version.$buildNumber');
    widget.model.init();
    if ((tools.getString('sessionkey') ?? '').isEmpty) {
      return Future.value({'needauth': true});
    }
    var r1 = await HttpDio().post('login.php', inData: {'method': 3});
    final userinfo = r1['data']['user'];
    tools.setString('last', userinfo['f_last']);
    tools.setString('first', userinfo['f_first']);
    r1 = r1['data']['config']['f_config'];
    tools.setInt('hall', r1['hall']);
    tools.setInt('table', r1['table']);
    tools.setInt('chatoperatoruserid', r1['chatoperatoruserid'] ?? 0);
    tools.setDouble('servicefee', r1['servicefactor'] ?? 0.0);
    tools.setBool('debugmode', r1['debugmode'] ?? false);
    tools.setBool('denylogout', r1['denylogout'] ?? false);
    final oldConfig = tools.getInt('menuversion') ?? 0;
    widget.model.part1.list.clear();
    int newConfig = int.tryParse(r1['menuversion']) ?? 0;
    if (oldConfig != newConfig) {
      await Hive.deleteBoxFromDisk('basket');
      var r2 = await HttpDio().post('kinopark/loadapp.php', inData: {});
      for (final e in r2['part1']) {
        final part1 = DishPart1.fromJson(e);
        widget.model.part1.list.add(part1);
      }
      final boxDishSpecial = await Hive.openBox('dishspecial');
      widget.model.dishSpecial.addAll(r2['dishspecial']);
      boxDishSpecial.put('dishspecial', jsonEncode(r2['dishspecial']));
      boxDishSpecial.close();
      final boxPart1 = await Hive.openBox<List>('part1');
      await boxPart1.put('part1list', widget.model.part1.list);
      boxPart1.close();
      widget.model.part2.list.clear();
      for (final e in r2['part2']) {
        final part2 = DishPart2.fromJson(e);
        widget.model.part2.list.add(part2);
      }
      final boxPart2 = await Hive.openBox<List>('part2');
      await boxPart2.put('part2list', widget.model.part2.list);
      boxPart2.close();
      widget.model.dishes.list.clear();
      for (final e in r2['menu']) {
        final dish = Dish.fromJson(e);
        widget.model.dishes.list.add(dish);
      }
      final boxDishes = await Hive.openBox<List>('dish');
      await boxDishes.put('dish', widget.model.dishes.list);
      boxDishes.close();
      tools.setInt('menuversion', newConfig);
    } else {
      try {
        final boxDishSpecial = await Hive.openBox('dishspecial');
        final boxPart1 = await Hive.openBox<List>('part1');
        final boxPart2 = await Hive.openBox<List>('part2');
        final boxDishes = await Hive.openBox<List>('dish');
        widget.model.part1.list =
            boxPart1.get('part1list', defaultValue: [])?.cast<DishPart1>() ??
                [];
        widget.model.part2.list =
            boxPart2.get('part2list', defaultValue: [])?.cast<DishPart2>() ??
                [];
        widget.model.dishes.list =
            boxDishes.get('dish', defaultValue: [])?.cast<Dish>() ?? [];
        widget.model.dishSpecial.addAll(
            jsonDecode(boxDishSpecial.get('dishspecial')));
      } catch (e) {
        final directory = await getApplicationSupportDirectory();
        final hiveDir = Directory(directory.path);
        await hiveDir.delete(recursive: true);
        tools.setInt('menuversion', -1);
        return await _loadApp();
      }
    }
    if (widget.model.dishSpecial.isNotEmpty) {
      for (final e in widget.model.dishSpecial) {
        final m = jsonDecode(e['d']);
        widget.model.dishSpecialMap[m['dish']] = m['comments'];
      }
    }
    final basketBox = await Hive.openBox<List>('basket');
    widget.model.basket
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
