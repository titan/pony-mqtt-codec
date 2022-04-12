use "pony_test"
use "buffered"
use "collections"

class _TestDecoder is UnitTest
  fun name(): String => "Decoder"

  fun apply(h: TestHelper) ? =>
    _test_empty(h) ?

  fun _test_empty(h: TestHelper) ? =>
    match MqttDecoder(recover val Array[U8 val] end) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      h.fail("Expect MqttDecodeContinue but got MqttDecodeDone")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail("Expect MqttDecodeContinue but got MqttDecodeError" + err)
    end
