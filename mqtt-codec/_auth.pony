use "pony_test"
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
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttAuthPacket val =>
        h.assert_eq[U8 val](pkt.reason_code(), MqttSuccess())
        try h.assert_eq[String val]((pkt.authentication_method as String val), "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8 val]((pkt.authentication_data as Array[U8 val] val), [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
        try h.assert_eq[String val]((pkt.reason_string as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not AUTH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttAuth.encode(origin, 45)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttAuthPacket val =>
        h.assert_eq[U8 val](pkt.reason_code(), MqttSuccess())
        try h.assert_eq[String val]((pkt.authentication_method as String val), "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8 val]((pkt.authentication_data as Array[U8 val] val), [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
        try h.assert_eq[String val]((pkt.reason_string as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
      else
        h.fail("Encoded packet is not AUTH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5_empty(h: TestHelper) ? =>
    let origin =
      MqttAuthPacket(
        where
        reason_code' = MqttSuccess
      )

    let buf = MqttAuth.encode(consume origin)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttAuthPacket val =>
        h.assert_eq[U8 val](pkt.reason_code(), MqttSuccess())
      else
        h.fail("Encoded packet is not AUTH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttAuthPacket =>
    let user_properties: Map[String val, String val] iso = recover iso Map[String val, String val](2) end
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    MqttAuthPacket(
      where
      reason_code' = MqttSuccess,
      authentication_method' = "Plain",
      authentication_data' = [0; 1; 2; 3],
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
