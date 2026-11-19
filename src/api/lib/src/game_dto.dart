final class GameDto {
  const GameDto({
    required this.id,
    required this.name,
    required this.genre,
    required this.releaseDate,
  });

  final int id;
  final String name;
  final String genre;
  final DateTime releaseDate;

  factory GameDto.fromJson(Map<String, dynamic> json) => GameDto(
        id: json['id'] as int,
        name: json['name'] as String,
        genre: json['genre'] as String,
        releaseDate: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'genre': genre,
        'date': releaseDate.toIso8601String(),
      };
}
