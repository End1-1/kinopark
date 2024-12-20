import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'dishpart2.freezed.dart';

part 'dishpart2.g.dart';

@HiveType(typeId: 2)
@freezed
class DishPart2 with _$DishPart2 {
  DishPart2._();

  factory DishPart2(
      {@HiveField(0) required int f_id,
      @HiveField(1) required int f_part,
      @HiveField(2) required String f_name,
      @HiveField(11) required String? f_en,
      @HiveField(12) required String? f_ru,
      @HiveField(3) required String f_image,
      @HiveField(4) required String? f_parentnamehy,
      @HiveField(5) required String? f_parentnameru,
      @HiveField(6) required String? f_parentnameen}) = _DishPart2;

  factory DishPart2.fromJson(Map<String, dynamic> json) =>
      _$DishPart2FromJson(json);

  String name(String locale) {
    switch (locale) {
      case 'en':
        return (f_en == null || f_en!.isEmpty) ? f_name : f_en !;
      case 'ru':
        return (f_ru == null || f_ru!.isEmpty) ? f_name : f_ru!;
      default:
        return f_name;
    }


  }

  String parentname(String locale) {
    switch (locale) {
      case 'en':
        return (f_parentnameen == null || f_parentnameen!.isEmpty) ? (f_parentnamehy ?? '') : f_parentnameen ?? '';
      case 'ru':
        return (f_parentnameru ==null || f_parentnameru!.isEmpty) ? (f_parentnamehy ?? '') : f_parentnameru ?? '';
      default:
        return f_parentnamehy ?? '';
    }
  }
}

class DishPart2List {
  var list = <DishPart2>[];

  List<DishPart2> get(int part1) {
    return list.where((e) => e.f_part == part1).toList();
  }
}
