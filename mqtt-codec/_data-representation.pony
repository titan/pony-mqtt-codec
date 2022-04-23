use "pony_test"
use "collections"

class _TestUtf8String is UnitTest
  fun name(): String => "Utf8 String"

  fun apply(h: TestHelper) ? =>
    _test_string(h, "") ?
    _test_string(h, "hello world") ?

  fun _test_string(h: TestHelper, str: String val) ? =>
    var buf: Array[U8] iso = recover iso Array[U8](_MqttUtf8String.size(str)) end
    buf = _MqttUtf8String.encode(consume buf, str)
    (let result, _) = _MqttUtf8String.decode(consume buf, 0) ?
    h.assert_eq[String val](consume result, str)

class _TestUtf8StringPair is UnitTest
  fun name(): String => "Utf8 String Pair"

  fun apply(h: TestHelper) ? =>
    _test_string_pair(h, ("", "")) ?
    _test_string_pair(h, ("hello world", "")) ?
    _test_string_pair(h, ("", "hello world")) ?
    _test_string_pair(h, ("hello", "world")) ?

  fun _test_string_pair(h: TestHelper, pair: (String val, String val)) ? =>
    var buf: Array[U8] iso = recover iso Array[U8](_MqttUtf8StringPair.size(pair)) end
    buf = _MqttUtf8StringPair.encode(consume buf, pair)
    (let result, _) = _MqttUtf8StringPair.decode(consume buf, 0) ?
    (let key, let value) = consume result
    h.assert_eq[String val](consume key, pair._1)
    h.assert_eq[String val](consume value, pair._2)

class _TestTwoByteInteger is UnitTest
  fun name(): String => "Two Byte Integer"

  fun apply(h: TestHelper) ? =>
    _test_two_byte_integer(h, 0) ?
    _test_two_byte_integer(h, 1_024) ?
    _test_two_byte_integer(h, 65_535) ?

  fun _test_two_byte_integer(h: TestHelper, data: U16) ? =>
    var buf: Array[U8] iso = recover iso Array[U8](_MqttTwoByteInteger.size(data)) end
    buf = _MqttTwoByteInteger.encode(consume buf, data)
    (let result, _) = _MqttTwoByteInteger.decode(consume buf, 0) ?
    h.assert_eq[U16](consume result, data)

class _TestFourByteInteger is UnitTest
  fun name(): String => "Four Byte Integer"

  fun apply(h: TestHelper) ? =>
    _test_four_byte_integer(h, 0) ?
    _test_four_byte_integer(h, 1_024) ?
    _test_four_byte_integer(h, 65_535) ?
    _test_four_byte_integer(h, 16_777_215) ?

  fun _test_four_byte_integer(h: TestHelper, data: U32) ? =>
    var buf: Array[U8] iso = recover iso Array[U8](_MqttFourByteInteger.size(data)) end
    buf = _MqttFourByteInteger.encode(consume buf, data)
    (let result, _) = _MqttFourByteInteger.decode(consume buf, 0) ?
    h.assert_eq[U32](consume result, data)

class _TestVariableByteInteger is UnitTest
  fun name(): String => "Variable Byte Integer"

  fun apply(h: TestHelper) ? =>
    _test_array(h, 0) ?
    _test_array(h, 128) ?
    _test_array(h, 16384) ?
    _test_array(h, 2097152) ?
    _test_direct(h, [10; 0xD7; 0x01; 0; 4], 1, 0xD7) ?
    _test_direct(h, [10; 0x39; 0; 4], 1, 0x39) ?

  fun _test_array(h: TestHelper, data: ULong) ? =>
    var buf: Array[U8] iso = recover iso Array[U8](_MqttVariableByteInteger.size(data)) end
    buf = _MqttVariableByteInteger.encode(consume buf, data)
    (let result: ULong, _) = _MqttVariableByteInteger.decode(consume buf, 0) ?
    h.assert_eq[ULong](consume result, data)

  fun _test_direct(h: TestHelper, buf: Array[U8] val, offset: USize, expected: ULong) ? =>
    (let result, _) = _MqttVariableByteInteger.decode(buf, offset) ?
    h.assert_eq[ULong](consume result, expected)

class _TestBinaryData is UnitTest
  fun name(): String => "Binary Data"

  fun apply(h: TestHelper) ? =>
    _test_binary_data(h, []) ?
    _test_binary_data(h, [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]) ?

  fun _test_binary_data(h: TestHelper, data: Array[U8] val) ? =>
    let len = _MqttBinaryData.size(data)
    var buf: Array[U8] iso = recover iso Array[U8](len) end
    buf = _MqttBinaryData.encode(consume buf, data)
    (let result, _) = _MqttBinaryData.decode(consume buf, 0) ?
    h.assert_array_eq[U8](consume result, data)
