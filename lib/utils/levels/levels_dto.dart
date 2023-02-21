import 'package:json_annotation/json_annotation.dart';
part 'levels_dto.g.dart';

@JsonSerializable()
class Item {
  Item({required this.code});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  int? code;

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class Size {
  Size(this.h, this.w);

  factory Size.fromJson(Map<String, dynamic> json) => _$SizeFromJson(json);
  final int h;
  final int w;

  Map<String, dynamic> toJson() => _$SizeToJson(this);
}

@JsonSerializable()
class LevelDto {
  LevelDto({required this.field, required this.levelId});

  factory LevelDto.fromJson(Map<String, dynamic> json) =>
      _$LevelDtoFromJson(json);

  int levelId;
  late List<List<Item?>> field;
  late Size size;

  Map<String, dynamic> toJson() => _$LevelDtoToJson(this);

  static Future<Map<int, LevelDto>> openLevels(String levelsFile) async {
    final levels = <int, LevelDto>{};

    int rowNum = 0;
    // int elementId = 0;

    final rows = levelsFile.split('\n');
    List<List<Item?>> field;
    List<Item?> fieldRow;

    int levelId = 0;
    while (levelId != 60) {
      levelId = int.parse(rows[rowNum]);
      rowNum++;
      final h = int.parse(rows[rowNum].split(' ')[1]);
      final w = int.parse(rows[rowNum].split(' ')[0]);
      rowNum++;
      field = [];
      for (var i = 0; i < h; i++) {
        fieldRow = [];
        for (int element in rows[rowNum].split(' ').map(int.parse)) {
          // elementId++;
          fieldRow.add(Item(code: element));
        }
        field.add(fieldRow);
        rowNum++;
      }
      levels[levelId] = LevelDto(
        field: field,
        levelId: levelId,
      )..size = Size(h, w);
    }
    return Future.value(levels);
  }
}
