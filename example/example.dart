import 'dart:convert';
import 'dart:io';

import 'package:string_reader/file_reader.dart';
import 'package:string_reader/string_reader.dart';
import 'package:string_reader/utf8_reader.dart';

void main(List<String> args) {
  const source = 'Hello';
  File? file;
  RandomAccessFile? fp;
  try {
    const filename = 'example/temp.txt';
    file = File(filename);
    _writeToFile(file, source);
    fp = file.openSync();
    final result = _readUsingFileReader(fp);
    print(result);
  } catch (e) {
    rethrow;
  } finally {
    if (fp != null) {
      fp.closeSync();
    }

    if (file != null) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  final stringReader = StringReader(source);
  final result = _readUsingStringReader(stringReader);
  print(result);
}

String _readUsingFileReader(RandomAccessFile fp) {
  const bufferSize = 8;
  final fileReader = FileReader(fp, bufferSize: bufferSize);
  final utf8Reader = Utf8Reader(fileReader);
  return _readUsingStringReader(utf8Reader);
}

String _readUsingStringReader(StringReader reader) {
  final charCodes = <int>[];
  var position = 0;
  while (position < reader.length) {
    final char = reader.readChar(position);
    position += reader.count;
    charCodes.add(char);
  }

  return String.fromCharCodes(charCodes);
}

void _writeToFile(File file, String string) {
  if (file.existsSync()) {
    file.deleteSync();
  }

  final bytes = Utf8Encoder().convert('Hello');
  file.writeAsBytesSync(bytes);
}
