// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual Hive adapter for OfflineFlashCardDeck

part of 'offline_flash_card_deck.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineFlashCardDeckAdapter extends TypeAdapter<OfflineFlashCardDeck> {
  @override
  final int typeId = 1;

  @override
  OfflineFlashCardDeck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineFlashCardDeck(
      deckId: fields[0] as String,
      name: fields[1] as String,
      cardsJson: fields[2] as String,
      cardCount: fields[3] as int,
      version: fields[4] as String,
      downloadedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineFlashCardDeck obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.deckId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cardsJson)
      ..writeByte(3)
      ..write(obj.cardCount)
      ..writeByte(4)
      ..write(obj.version)
      ..writeByte(5)
      ..write(obj.downloadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineFlashCardDeckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
