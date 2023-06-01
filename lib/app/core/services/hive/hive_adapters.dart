part of 'hive_service.dart';

class _FonteAdapter extends TypeAdapter<Fonte> {
  @override
  Fonte read(BinaryReader reader) {
    final int index = reader.readInt();
    return Fonte.values.elementAt(index);
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, Fonte obj) {
    writer.writeInt(obj.index);
  }
}

class _TypeEventAdapter extends TypeAdapter<TypeEvent> {
  @override
  TypeEvent read(BinaryReader reader) {
    final int index = reader.readInt();
    return TypeEvent.values.elementAt(index);
  }

  @override
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, TypeEvent obj) {
    writer.writeInt(obj.index);
  }
}

class _BookAdapter extends TypeAdapter<Book> {
  @override
  Book read(BinaryReader reader) {
    final book = Book.fromJson(reader.readMap());
    return book;
  }

  @override
  int get typeId => 3;

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.writeMap(obj.toJson());
  }
}

class _HomeSelectAdapter extends TypeAdapter<HomeSelect> {
  @override
  HomeSelect read(BinaryReader reader) {
    return HomeSelect.values.elementAt(reader.readInt());
  }

  @override
  int get typeId => 4;

  @override
  void write(BinaryWriter writer, HomeSelect obj) {
    writer.writeInt(obj.index);
  }
}

class _ModeViewAdapter extends TypeAdapter<ModeView> {
  @override
  ModeView read(BinaryReader reader) {
    return ModeView.values.elementAt(reader.readInt());
  }

  @override
  int get typeId => 5;

  @override
  void write(BinaryWriter writer, ModeView obj) {
    writer.writeInt(obj.index);
  }
}



// class _ListBookAdapter extends TypeAdapter<List<Book>> {
//   @override
//   List<Book> read(BinaryReader reader) {
//     // final books = reader.readList() as List<Book>;
//     final books = (jsonDecode(reader.readString()) as List).map((e) => Book.fromJson(e)).toList();
//     return books;
//   }

//   @override
//   int get typeId => 4;

//   @override
//   void write(BinaryWriter writer, List<Book> obj) {
//     // writer.writeList(obj);
//     writer.writeString(jsonEncode(obj.map((e) => e.toJson()).toList()));
//   }
// }
