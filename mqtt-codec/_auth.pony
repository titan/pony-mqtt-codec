use "pony_test"
use "collections"

class _TestAuth is UnitTest
  fun name(): String => "AUTH"

  fun apply(h: TestHelper)? =>
    _test_mqtt5(h)?
    _test_mqtt5_too_large(h)?
    _test_mqtt5_empty(h)?

  fun _test_mqtt5(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.auth(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?] else [0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttAuth, let pkt: MqttAuthPacket), _) =>
      h.assert_eq[U8](MqttAuth.reason_code(pkt)(), MqttSuccess())
      try h.assert_eq[String val]((MqttAuth.authentication_method(pkt) as String val), "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
      try h.assert_array_eq[U8]((MqttAuth.authentication_data(pkt) as Array[U8] val), [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
      try h.assert_eq[String val]((MqttAuth.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttAuth.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not AUTH")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.auth(origin, 45)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttAuth, let pkt: MqttAuthPacket), _) =>
      h.assert_eq[U8](MqttAuth.reason_code(pkt)(), MqttSuccess())
      try h.assert_eq[String val]((MqttAuth.authentication_method(pkt) as String val), "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
      try h.assert_array_eq[U8]((MqttAuth.authentication_data(pkt) as Array[U8] val), [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
      try h.assert_eq[String val]((MqttAuth.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttAuth.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not AUTH")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_empty(h: TestHelper)? =>
    let origin =
      MqttAuth.build(
        where
        reason_code' = MqttSuccess
      )

    let buf = MqttEncoder.auth(consume origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttAuth, let pkt: MqttAuthPacket), _) =>
      h.assert_eq[U8](MqttAuth.reason_code(pkt)(), MqttSuccess())
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not AUTH")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded AUTH packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttAuthPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    MqttAuth.build(
      where
      reason_code' = MqttSuccess,
      authentication_method' = "Plain",
      authentication_data' = [0; 1; 2; 3],
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
