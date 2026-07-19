import 'package:hive_flutter/hive_flutter.dart';
import '../models/checkin.dart';

class StorageService {
  static const String boxName = 'checkins';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CheckInAdapter());
    await Hive.openBox<CheckIn>(boxName);
  }

  static Box<CheckIn> get box => Hive.box<CheckIn>(boxName);

  static Future<void> addCheckIn(CheckIn checkIn) async {
    await box.put(checkIn.id, checkIn);
  }

  static List<CheckIn> getAllCheckIns() {
    final items = box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }
}