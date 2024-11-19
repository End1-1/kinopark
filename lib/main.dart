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
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.initFlutter();
  Hive.registerAdapter(DishPart1Adapter());
  Hive.registerAdapter(DishPart2Adapter());
  Hive.registerAdapter(DishAdapter());
  runApp(MultiBlocProvider(providers: [
    BlocProvider<AppBloc>(create: (_) => AppBloc(HttpState(0, const {}))),
    BlocProvider<Page1Bloc>(create: (_) => Page1Bloc(Page1State(0))),
    BlocProvider<BasketBloc>(create: (_) => BasketBloc(BasketState(0))),
  ], child: const KinoparkApp()));
}

class KinoparkApp extends StatelessWidget {
  const KinoparkApp({super.key});

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
  final _model = AppModel();
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
                Navigator.pushReplacement(tools.context(),
                    MaterialPageRoute(builder: (builder) => HomePage(_model)));
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
    if ((tools.getString('sessionkey') ?? '').isEmpty) {
      return Future.value({'needauth': true});
    }
    var r1 = await HttpDio().post('login.php', inData: {'method': 3});
    r1 = r1['data']['config']['f_config'];
    final oldConfig = tools.getInt('menuversion') ?? 0;
    _model.part1.list.clear();
    int newConfig = int.tryParse(r1['menuversion']) ?? 0;
    if (oldConfig != newConfig) {
      var r2 = await HttpDio().post('kinopark/loadapp.php', inData: {});
      for (final e in r2['part1']) {
        final part1 = DishPart1.fromJson(e);
        _model.part1.list.add(part1);
      }
      final boxPart1 = await Hive.openBox<List>('part1');
      await boxPart1.put('part1list', _model.part1.list);
      _model.part2.list.clear();
      for (final e in r2['part2']) {
        final part2 = DishPart2.fromJson(e);
        _model.part2.list.add(part2);
      }
      final boxPart2 = await Hive.openBox<List>('part2');
      await boxPart2.put('part2list', _model.part2.list);
      _model.dishes.list.clear();
      for (final e in r2['menu']) {
        final dish = Dish.fromJson(e);
        _model.dishes.list.add(dish);
      }
      final boxDishes = await Hive.openBox<List>('dish');
      await boxDishes.put('dish', _model.dishes.list);
      tools.setInt('menuversion', newConfig);
    } else {
      final boxPart1 = await Hive.openBox<List>('part1');
      final boxPart2 = await Hive.openBox<List>('part2');
      final boxDishes = await Hive.openBox<List>('dish');
      _model.part1.list =
          boxPart1.get('part1list', defaultValue: [])?.cast<DishPart1>() ?? [];
      _model.part2.list =
          boxPart2.get('part2list', defaultValue: [])?.cast<DishPart2>() ?? [];
      _model.dishes.list =
          boxDishes.get('dish', defaultValue: [])?.cast<Dish>() ?? [];
    }
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
