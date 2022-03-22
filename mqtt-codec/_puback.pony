use "pony_test"
use "buffered"
use "collections"

class _TestPubAck is UnitTest
  fun name(): String => "PUBACK"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin =
      MqttPubAckPacket(
        where
        packet_identifier' = 65535
      )

    let buf = MqttPubAck.encode(consume origin, 0, MqttVersion311)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttPubAckPacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
      else
        h.fail("Encoded packet is not PUBACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBACK packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttPubAck.encode(origin)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttPubAckPacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
        h.assert_eq[U8 val](pkt.reason_code(), MqttSuccess())
        try h.assert_eq[String val]((pkt.reason_string as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not PUBACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBACK packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttPubAck.encode(origin, 32)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttPubAckPacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
        h.assert_eq[U8 val](pkt.reason_code(), MqttSuccess())
        try h.assert_eq[String val]((pkt.reason_string as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
      else
        h.fail("Encoded packet is not PUBACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBACK packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttPubAckPacket =>
    let user_properties: Map[String val, String val] iso = recover iso Map[String val, String val](2) end
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    MqttPubAckPacket(
      where
      packet_identifier' = 65535,
      reason_code' = MqttSuccess,
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
