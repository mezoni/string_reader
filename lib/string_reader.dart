abstract interface class StringReader {
  factory StringReader(String source) {
    return _StringReader(source);
  }

  /// Returns the amount of data read in the specified units. The data unit
  /// depends on the reader implementation and how the data is encoded.
  int get count;

  /// Returns `true` if the source of the input data is available as a [String]
  /// value. If the source of the input data is not available, it returns
  /// `false`.
  bool get hasSource;

  /// Returns the length of the input data in the specified units. The data
  /// unit depends on the reader implementation and how the data is encoded.
  int get length;

  /// Returns the source of the input data if available as a [String] value. If
  /// the source of the input data is not available, it throws an exception, the
  /// type and meaning of which depends on the reader implementation.
  String get source;

  /// Returns the index of the starting position of the found string, otherwise
  /// returns the value `-1`.
  ///
  /// The search begins at offset [start], the value must be specified in units
  /// defined for a specific reader.
  int indexOf(String string, int start);

  /// Reads the character at the specified [offset] and returns the result of
  /// the comparison with [char].
  ///
  /// If the specified [offset] is outside the valid range, it returns `false`.
  ///
  /// The [offset] must be specified in units defined by the specific reader.
  bool matchChar(int char, int offset);

  /// Reads the character at the specified [offset] and returns that character.
  ///
  /// Throws an exception, if the specified [offset] is outside the valid range.
  ///
  /// The [offset] must be specified in units defined by the specific reader.
  int readChar(int offset);

  /// Check whether the input data starts at the specified position [index] with
  /// the specified value [string] and and returns `true` if the check is
  /// successful.
  ///
  /// The [start] must be specified in units defined by the specific reader.
  bool startsWith(String string, int index);

  /// Returns a substring of the data source starting at offset [start] and
  /// ending at offset [end].
  ///
  /// Throws an exception if the specified offsets [start] or [end] are outside
  /// the valid range.
  ///
  /// The [start] and [end] must be specified in units defined by the
  /// specific reader.
  String substring(int start, [int? end]);
}

class _StringReader implements StringReader {
  @override
  final bool hasSource = true;

  @override
  final int length;

  @override
  int count = 0;

  @override
  final String source;

  _StringReader(this.source) : length = source.length;

  @override
  int indexOf(String string, int start) {
    return source.indexOf(string, start);
  }

  @override
  @pragma('vm:prefer-inline')
  bool matchChar(int char, int offset) {
    if (offset < length) {
      final c = source.runeAt(offset);
      count = char > 0xffff ? 2 : 1;
      if (c == char) {
        return true;
      }
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  int readChar(int offset) {
    final result = source.runeAt(offset);
    count = result > 0xffff ? 2 : 1;
    return result;
  }

  @override
  @pragma('vm:prefer-inline')
  bool startsWith(String string, int index) {
    if (source.startsWith(string, index)) {
      count = string.length;
      return true;
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  String substring(int start, [int? end]) {
    final result = source.substring(start, end);
    count = result.length;
    return result;
  }

  @override
  String toString() {
    return source;
  }
}

extension StringReaderExt on String {
  @pragma('vm:prefer-inline')
  // ignore: unused_element
  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }
      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }
    return w1;
  }
}
