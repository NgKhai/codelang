// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual Hive adapter for OfflineCourse

part of 'offline_course.dart';

class OfflineCourseAdapter extends TypeAdapter<OfflineCourse> {
  @override
  final int typeId = 0;

  @override
  OfflineCourse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineCourse(
      id: fields[0] as String,
      name: fields[1] as String,
      exercisesJson: fields[2] as String,
      version: fields[3] as String,
      downloadedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineCourse obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exercisesJson)
      ..writeByte(3)
      ..write(obj.version)
      ..writeByte(4)
      ..write(obj.downloadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineCourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
