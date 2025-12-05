import 'dart:convert';

// Blok tipi enum'u (Pomodoro veya Özel)
enum BlockType { pomodoro, custom }

// Çalışma bloku modelini temsil et
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

  // Yeni blok oluştur
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

  // JSON'dan Block nesnesi oluştur
  factory Block.fromJson(Map<String, dynamic> json) => Block(
    id: json['id'] as String,
    title: json['title'] as String,
    durationMinutes: json['durationMinutes'] as int,
    type: BlockType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => BlockType.custom,
    ),
  );

  // Block nesnesini JSON'a çevir
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'durationMinutes': durationMinutes,
    'type': type.toString(),
  };

  // Block listesini string formatında kodla
  static String encodeList(List<Block> list) =>
      json.encode(list.map((e) => e.toJson()).toList());

  // String formatından Block listesi oluştur
  static List<Block> decodeList(String raw) {
    final data = json.decode(raw) as List<dynamic>;
    return data.map((e) => Block.fromJson(e as Map<String, dynamic>)).toList();
  }
}
