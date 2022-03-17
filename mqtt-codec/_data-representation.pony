use "pony_test"
use "buffered"
use "collections"

class _TestUtf8String is UnitTest
  fun name(): String => "Utf8 String"

  fun apply(h: TestHelper) ? =>
    _test_string(h, "") ?
    _test_string(h, "hello world") ?

  fun _test_string(h: TestHelper, str: String) ? =>
    let buf: Array[U8 val] = Array[U8 val](MqttUtf8String.size(str))
    MqttUtf8String.encode(buf, str)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    let reader: Reader ref = Reader
    reader.append(buf')
    (let result, _) = MqttUtf8String.decode(reader) ?
    h.assert_eq[String](result, str)

class _TestUtf8StringPair is UnitTest
  fun name(): String => "Utf8 String Pair"

  fun apply(h: TestHelper) ? =>
    _test_string_pair(h, ("", "")) ?
    _test_string_pair(h, ("hello world", "")) ?
    _test_string_pair(h, ("", "hello world")) ?
    _test_string_pair(h, ("hello", "world")) ?

  fun _test_string_pair(h: TestHelper, pair: (String, String)) ? =>
    let buf: Array[U8 val] = Array[U8 val](MqttUtf8StringPair.size(pair))
    MqttUtf8StringPair.encode(buf, pair)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    let reader: Reader ref = Reader
    reader.append(buf')
    (let result, _) = MqttUtf8StringPair.decode(reader) ?
    h.assert_eq[String](result._1, pair._1)
    h.assert_eq[String](result._2, pair._2)

class _TestTwoByteInteger is UnitTest
  fun name(): String => "Two Byte Integer"

  fun apply(h: TestHelper) ? =>
    _test_two_byte_integer(h, 0) ?
    _test_two_byte_integer(h, 1_024) ?
    _test_two_byte_integer(h, 65_535) ?

  fun _test_two_byte_integer(h: TestHelper, data: U16) ? =>
    let buf: Array[U8 val] = Array[U8 val](MqttTwoByteInteger.size(data))
    MqttTwoByteInteger.encode(buf, data)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    let reader: Reader ref = Reader
    reader.append(buf')
    (let result, _) = MqttTwoByteInteger.decode(reader) ?
    h.assert_eq[U16](result, data)

class _TestFourByteInteger is UnitTest
  fun name(): String => "Four Byte Integer"

  fun apply(h: TestHelper) ? =>
    _test_four_byte_integer(h, 0) ?
    _test_four_byte_integer(h, 1_024) ?
    _test_four_byte_integer(h, 65_535) ?
    _test_four_byte_integer(h, 16_777_215) ?

  fun _test_four_byte_integer(h: TestHelper, data: U32) ? =>
    let buf: Array[U8 val] = Array[U8 val](MqttFourByteInteger.size(data))
    MqttFourByteInteger.encode(buf, data)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    let reader: Reader ref = Reader
    reader.append(consume buf')
    (let result, _) = MqttFourByteInteger.decode(reader) ?
    h.assert_eq[U32](result, data)

class _TestVariableByteInteger is UnitTest
  fun name(): String => "Variable Byte Integer"

  fun apply(h: TestHelper) ? =>
    _test_array(h, 0) ?
    _test_array(h, 128) ?
    _test_array(h, 16384) ?
    _test_array(h, 2097152) ?
    _test_reader(h, 0) ?
    _test_reader(h, 128) ?
    _test_reader(h, 16384) ?
    _test_reader(h, 2097152) ?
    _test_direct(h, [10; 0xD7; 0x01; 0; 4], 1, 0xD7) ?
    _test_direct(h, [10; 0x39; 0; 4], 1, 0x39) ?

  fun _test_array(h: TestHelper, data: ULong) ? =>
    let buf: Array[U8 val] = Array[U8 val](MqttVariableByteInteger.size(data))
    MqttVariableByteInteger.encode(buf, data)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    (let result, _) = MqttVariableByteInteger.decode_array(consume buf', 0) ?
    h.assert_eq[ULong](result, data)

  fun _test_reader(h: TestHelper, data: ULong) ? =>
    let buf: Array[U8 val] = Array[U8 val](MqttVariableByteInteger.size(data))
    MqttVariableByteInteger.encode(buf, data)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    let reader: Reader ref = Reader
    reader.append(consume buf')
    (let result, _) = MqttVariableByteInteger.decode_reader(reader) ?
    h.assert_eq[ULong](result, data)

  fun _test_direct(h: TestHelper, buf: Array[U8] val, offset: USize, expected: ULong) ? =>
    (let result, _) = MqttVariableByteInteger.decode_array(buf, offset) ?
    h.assert_eq[ULong](result, expected)

class _TestBinaryData is UnitTest
  fun name(): String => "Binary Data"

  fun apply(h: TestHelper) ? =>
    _test_binary_data(h, []) ?
    _test_binary_data(h, [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]) ?

  fun _test_binary_data(h: TestHelper, data: Array[U8] box) ? =>
    let len = MqttBinaryData.size(data)
    let buf: Array[U8 val] = Array[U8 val](len)
    MqttBinaryData.encode(buf, data)
    let buf': Array[U8 val] val = U8ArrayClone(buf)
    let reader: Reader ref = Reader
    reader.append(consume buf')
    (let result, _) = MqttBinaryData.decode(reader) ?
    h.assert_array_eq[U8 val](result, data)
