import 'dart:io';
import 'dart:typed_data';

import 'byte_reader.dart';

/// The [FileReader] implements a [ByteReader] from files, providing access to
/// input data via [RandomAccessFile].
class FileReader implements ByteReader {
  /// Buffer size of read data, in bytes.
  final int bufferSize;

  /// Random access file input data handler.
  final RandomAccessFile fp;

  final Uint8List _buffer;

  int _end = -1;

  final int _length;

  int _start = -1;

  FileReader(
    this.fp, {
    required this.bufferSize,
    bool isFixedLength = true,
  })  : _buffer = Uint8List(bufferSize > 0
            ? bufferSize
            : throw ArgumentError.value(
                bufferSize, 'bufferSize', 'Must be greater than 0')),
        _length = isFixedLength ? fp.lengthSync() : -1;

  @override
  @pragma('vm:prefer-inline')
  int get length {
    if (_length >= 0) {
      return _length;
    }

    return fp.lengthSync();
  }

  @override
  @pragma('vm:prefer-inline')
  int readByte(int offset) {
    if (offset < 0) {
      RangeError.checkNotNegative(offset, 'offset');
    }

    if (offset < _start || offset > _end) {
      _readIntoBuffer(offset);
    }

    if (offset > _end) {
      throw RangeError.range(offset, 0, _end);
    }

    return _buffer[offset - _start];
  }

  void _readIntoBuffer(int offset) {
    fp.setPositionSync(offset);
    final result = fp.readIntoSync(_buffer, 0);
    _start = offset;
    _end = offset + result - 1;
  }
}
