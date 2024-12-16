import 'package:freezed_annotation/freezed_annotation.dart';


part 'dish_search_result.freezed.dart';

part 'dish_search_result.g.dart';

@freezed
class DishSearchStruct with _$DishSearchStruct {
  const factory DishSearchStruct({
    required int id,
    required int mode,
    required String name
  }) = _DishSearchStruct;

  factory DishSearchStruct.fromJson(Map<String, dynamic> json) =>
      _$DishSearchStructFromJson(json);
}