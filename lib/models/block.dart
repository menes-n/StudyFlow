import 'dart:convert';

enum BlockType { pomodoro, custom }

class Block {
  final String id;
  String title;
  int durationMinutes;
  BlockType type;

  Block({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.type = BlockType.custom,
  });

  factory Block.create({
    required String title,
    required int durationMinutes,
    BlockType type = BlockType.custom,
  }) {
    return Block(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      durationMinutes: durationMinutes,
      type: type,
    );
  }

  factory Block.fromJson(Map<String, dynamic> json) => Block(
    id: json['id'] as String,
    title: json['title'] as String,
    durationMinutes: json['durationMinutes'] as int,
    type: BlockType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => BlockType.custom,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'durationMinutes': durationMinutes,
    'type': type.toString(),
  };

  static String encodeList(List<Block> list) =>
      json.encode(list.map((e) => e.toJson()).toList());

  static List<Block> decodeList(String raw) {
    final data = json.decode(raw) as List<dynamic>;
    return data.map((e) => Block.fromJson(e as Map<String, dynamic>)).toList();
  }
}
