use "pony_test"
use "collections"

class _TestDecoder is UnitTest
  fun name(): String => "Decoder"

  fun apply(h: TestHelper) ? =>
    _test_empty(h) ?

  fun _test_empty(h: TestHelper) ? =>
    match MqttDecoder(recover iso Array[U8 val] end) ?
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Expect MqttDecodeContinue but got MqttDecodeDone")
    | (MqttDecodeError, let err: String val) =>
      h.fail("Expect MqttDecodeContinue but got MqttDecodeError" + err)
    end
