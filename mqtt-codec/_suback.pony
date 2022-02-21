use "ponytest"
use "buffered"
use "collections"

class _TestSubAck is UnitTest
  fun name(): String => "SUBACK"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let reason_codes: Array[MqttSubAckReasonCode] = [
      MqttGrantedQoS0
      MqttGrantedQoS1
      MqttGrantedQoS2
      MqttUnspecifiedError
    ]
    let origin = MqttSubAckPacket(
      where
      packet_identifier' = 65535,
      reason_codes' = reason_codes
    )

    let buf = MqttSubAck.encode(origin, None, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttSubAckPacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.reason_codes.size(), 4)
        h.assert_eq[U8](pkt.reason_codes(0)?(), MqttGrantedQoS0())
        h.assert_eq[U8](pkt.reason_codes(1)?(), MqttGrantedQoS1())
        h.assert_eq[U8](pkt.reason_codes(2)?(), MqttGrantedQoS2())
        h.assert_eq[U8](pkt.reason_codes(3)?(), MqttUnspecifiedError())
      else
        h.fail("Encoded packet is not SUBACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBACK packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttSubAck.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttSubAckPacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.reason_codes.size(), 4)
        h.assert_eq[U8](pkt.reason_codes(0)?(), MqttGrantedQoS0())
        h.assert_eq[U8](pkt.reason_codes(1)?(), MqttGrantedQoS1())
        h.assert_eq[U8](pkt.reason_codes(2)?(), MqttGrantedQoS2())
        h.assert_eq[U8](pkt.reason_codes(3)?(), MqttUnspecifiedError())
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not SUBACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBACK packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttSubAck.encode(origin, 35)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttSubAckPacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.reason_codes.size(), 4)
        h.assert_eq[U8](pkt.reason_codes(0)?(), MqttGrantedQoS0())
        h.assert_eq[U8](pkt.reason_codes(1)?(), MqttGrantedQoS1())
        h.assert_eq[U8](pkt.reason_codes(2)?(), MqttGrantedQoS2())
        h.assert_eq[U8](pkt.reason_codes(3)?(), MqttUnspecifiedError())
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
      else
        h.fail("Encoded packet is not SUBACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBACK packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttSubAckPacket =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let reason_codes: Array[MqttSubAckReasonCode] = [
      MqttGrantedQoS0
      MqttGrantedQoS1
      MqttGrantedQoS2
      MqttUnspecifiedError
    ]
    MqttSubAckPacket(
      where
      packet_identifier' = 65535,
      reason_codes' = reason_codes,
      reason_string' = "Unknown",
      user_properties' = user_properties
    )
