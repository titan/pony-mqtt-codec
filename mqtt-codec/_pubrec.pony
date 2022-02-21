use "ponytest"
use "buffered"
use "collections"

class _TestPubRec is UnitTest
  fun name(): String => "PUBREC"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin = MqttPubRecPacket(
      where
      packet_identifier' = 65535
    )

    let buf = MqttPubRec.encode(origin, None, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttPubRecPacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
      else
        h.fail("Encoded packet is not PUBREC")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBREC packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttPubRec.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttPubRecPacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        try h.assert_eq[U8]((pkt.reason_code as MqttPubRecReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be MqttSuccess but got None") end
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not PUBREC")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBREC packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttPubRec.encode(origin, 32)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttPubRecPacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        try h.assert_eq[U8]((pkt.reason_code as MqttPubRecReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be MqttSuccess but got None") end
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
      else
        h.fail("Encoded packet is not PUBREC")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBREC packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttPubRecPacket =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    MqttPubRecPacket(
      where
      packet_identifier' = 65535,
      reason_code' = MqttSuccess,
      reason_string' = "Unknown",
      user_properties' = user_properties
    )
