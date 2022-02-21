use "ponytest"
use "buffered"
use "collections"

class _TestAuth is UnitTest
  fun name(): String => "AUTH"

  fun apply(h: TestHelper) ? =>
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?
    _test_mqtt5_empty(h) ?

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttAuth.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttAuthPacket =>
        try h.assert_eq[U8]((pkt.reason_code as MqttAuthReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be MqttSuccess but got None") end
        try h.assert_eq[String]((pkt.authentication_method as String), "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8]((pkt.authentication_data as Array[U8]), [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not AUTH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttAuth.encode(origin, 45)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttAuthPacket =>
        try h.assert_eq[U8]((pkt.reason_code as MqttAuthReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be MqttSuccess but got None") end
        try h.assert_eq[String]((pkt.authentication_method as String), "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8]((pkt.authentication_data as Array[U8]), [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
      else
        h.fail("Encoded packet is not AUTH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_empty(h: TestHelper) ? =>
    let origin =
      MqttAuthPacket(
        where
        reason_code' = MqttSuccess
      )

    let buf = MqttAuth.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttAuthPacket =>
        try h.assert_eq[U8]((pkt.reason_code as MqttAuthReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be MqttSuccess but got None") end
      else
        h.fail("Encoded packet is not AUTH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttAuthPacket =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    MqttAuthPacket(
      where
      reason_code' = MqttSuccess,
      authentication_method' = "Plain",
      authentication_data' = [0; 1; 2; 3],
      reason_string' = "Unknown",
      user_properties' = user_properties
    )
