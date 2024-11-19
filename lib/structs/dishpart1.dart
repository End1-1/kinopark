import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'dishpart1.freezed.dart';
part 'dishpart1.g.dart';

@HiveType(typeId: 1)
@freezed
class DishPart1 extends HiveObject with _$DishPart1 {
  DishPart1._();
  factory DishPart1(
      {@HiveField(0) required int f_id,
      @HiveField(1) required String f_name,
      @HiveField(2) required String f_image}) = _DishPart1;

  factory DishPart1.fromJson(Map<String, dynamic> json) =>
      _$DishPart1FromJson(json);
}

class DishPart1List {
  var  list = <DishPart1>[];
}
