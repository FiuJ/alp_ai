import 'package:hive/hive.dart';

part 'trash_record.g.dart'; // Generate this using: flutter pub run build_runner build

@HiveType(typeId: 0)
class TrashRecord extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final String recommendations;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? imagePath;

  TrashRecord({
    required this.category,
    required this.recommendations,
    required this.timestamp,
    this.imagePath,
  });
}