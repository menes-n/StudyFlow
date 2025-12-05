import 'dart:convert';

// Günlük rutin modelini temsil et
class Routine {
  String id;
  String title;
  int durationMinutes;
  int colorValue;
  bool completed;
  int totalMinutes;
  int? lastSessionMillis;

  Routine({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.colorValue,
    this.completed = false,
    this.totalMinutes = 0,
    this.lastSessionMillis,
  });

  // Yeni rutin oluştur
  factory Routine.create({
    required String title,
    required int durationMinutes,
    required int colorValue,
  }) {
    return Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      durationMinutes: durationMinutes,
      colorValue: colorValue,
      completed: false,
    );
  }

  // JSON'dan Routine nesnesi oluştur
  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'] as String,
    title: json['title'] as String,
    durationMinutes: json['durationMinutes'] as int,
    colorValue: json['colorValue'] as int,
    completed: json['completed'] as bool? ?? false,
    totalMinutes: json['totalMinutes'] as int? ?? 0,
    lastSessionMillis: json['lastSessionMillis'] as int?,
  );

  // Routine nesnesini JSON'a çevir
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'durationMinutes': durationMinutes,
    'colorValue': colorValue,
    'completed': completed,
    'totalMinutes': totalMinutes,
    'lastSessionMillis': lastSessionMillis,
  };

  // Routine nesnesini string formatında kodla
  String encode() => json.encode(toJson());

  // String formatından Routine nesnesi oluştur
  static Routine decode(String jsonStr) =>
      Routine.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
}
