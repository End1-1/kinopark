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
      @HiveField(3) required String f_image}) = _DishPart2;

  factory DishPart2.fromJson(Map<String, dynamic> json) =>
      _$DishPart2FromJson(json);

  String name(String locale) {
    switch (locale) {
      case 'en':
        return f_en ?? f_name;
      case 'ru':
        return f_ru ?? f_name;
      default:
        return f_name;
    }
  }
}

class DishPart2List {
  var list = <DishPart2>[];

  List<DishPart2> get(int part1) {
    return list.where((e) => e.f_part == part1).toList();
  }
}
