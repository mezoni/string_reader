/// The [ByteReader] is intended to implement a byte reading interface.
abstract interface class ByteReader {
  /// Returns the length of the input data in bytes.
  int get length;

  /// Reads a byte at the specified [offset] and returns that byte.
  int readByte(int offset);
}
