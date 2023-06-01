import 'dart:developer';

enum DateEnum {
  janeiro,
  fevereiro,
  marco,
  abril,
  maio,
  junho,
  julho,
  agosto,
  setembro,
  outubro,
  novembro,
  dezembro,
}

DateTime? _dataTimeNull(Object? exception, StackTrace stackTrace) => null;

abstract interface class _ParseDateTime {
  DateTime? parse;
  final String? data;
  final DateTime? Function(Object? exception, StackTrace stackTrace) onException;
  _ParseDateTime({this.data, this.onException = _dataTimeNull}) {
    parseDate();
  }

  void parseDate() {
    try {
      otherParseDate();
      if (parse == null) Exception('Nao foi possivel fazer o parse');
    } on Exception catch (_, __) {
      log('Exception: ${_.toString()}', error: _, stackTrace: __);
      parse = onException.call(_, __);
    }
  }

  void otherParseDate();
}

class ParseDateTime extends _ParseDateTime {
  ParseDateTime({super.data, super.onException});

  @override
  void parseDate() {
    if (data == null) return;
    final tryparse = DateTime.tryParse(data!);
    if (tryparse != null) {
      parse = tryparse;
    } else if (data!.contains(',')) {
      final String replace = data!.replaceAll(',', '');
      final List<String> splitData = replace.split(' ');
      int mes = DateEnum.values.indexWhere((element) => element.name == splitData.first);
      if (mes == -1) {
        final now = DateTime.now();
        mes = now.month;
      }
      final int dia = int.parse(splitData.elementAt(1));
      final int ano = int.parse(splitData.elementAt(2));
      parse = DateTime(ano, mes, dia);
    } else {
      super.parseDate();
    }
  }

  @override
  void otherParseDate() {
    if (data!.contains("hora") || data!.contains("horas")) {
      final int parseHours = int.parse(data!.replaceAll(RegExp(r'[^0-9]'), ''));
      final now = DateTime.now();
      parse = now.subtract(Duration(hours: parseHours));
    } else if (data!.contains("minuto") || data!.contains("minutos")) {
      final int parseMinutes = int.parse(data!.replaceAll(RegExp(r'[^0-9]'), ''));
      final now = DateTime.now();
      parse = now.subtract(Duration(minutes: parseMinutes));
    } else if (data!.contains("segundos") || data!.contains("segundo")) {
      final int parseSeconds = int.parse(data!.replaceAll(RegExp(r'[^0-9]'), ''));
      final now = DateTime.now();
      parse = now.subtract(Duration(seconds: parseSeconds));
    } else if (data!.contains("/")) {
      final String temp = data!.split("/").reversed.join();
      final now = DateTime.now();
      parse = now.subtract(now.difference(DateTime.parse(temp)));
    } else if (data!.contains("dias") || data!.contains("dia")) {
      final int parseDays = int.parse(data!.replaceAll(RegExp(r'[^0-9]'), ''));
      final now = DateTime.now();
      parse = now.subtract(Duration(days: parseDays));
    }
  }
}
