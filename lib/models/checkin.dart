import 'package:hive/hive.dart';

class CheckIn extends HiveObject {
  String id;
  String note;
  String photoPath;
  double latitude;
  double longitude;
  double accuracy;
  DateTime createdAt;

  CheckIn({
    required this.id,
    required this.note,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });
}

class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 0;

  @override
  CheckIn read(BinaryReader reader) {
    return CheckIn(
      id: reader.readString(),
      note: reader.readString(),
      photoPath: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
      accuracy: reader.readDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.note);
    writer.writeString(obj.photoPath);
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
    writer.writeDouble(obj.accuracy);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}