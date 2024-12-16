import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'dish.freezed.dart';

part 'dish.g.dart';

@HiveType(typeId: 3)
@freezed
class Dish extends HiveObject
    with _$Dish {
  Dish._();

  factory Dish({
    @HiveField(0) required int f_id,
    @HiveField(1) required int f_part,
    @HiveField(2) required String f_name,
    @HiveField(3) required String f_image,
    @HiveField(4) required String f_print1,
    @HiveField(5) required String f_print2,
    @HiveField(6) required double f_price,
    @HiveField(7) required double f_qty,
    @HiveField(8) required double f_netweight,
    @HiveField(9) required int f_store,
    @HiveField(10) required String? f_comment,
    @HiveField(11) required String? f_en,
    @HiveField(12) required String? f_ru,
  }) = _Dish;

  factory Dish.fromJson(Map<String, dynamic> json) => _$DishFromJson(json);

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

class DishList {
  var list = <Dish>[];
}