use "pony_test"
use "collections"

class _TestDisconnect is UnitTest
  fun name(): String => "DISCONNECT"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?
    _test_mqtt5_too_large(h)?
    _test_mqtt5_empty(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let origin = MqttDisconnect.build()

    let buf = MqttEncoder.disconnect(consume origin, 0, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttDisconnect, let pkt: MqttDisconnectPacket), _) =>
      None
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not DISCONNECT")
    | MqttDecodeContinue =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.disconnect(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttDisconnect, let pkt: MqttDisconnectPacket), _) =>
      h.assert_eq[U8](MqttDisconnect.reason_code(pkt)(), MqttNormalDisconnection())
      h.assert_eq[U32](MqttDisconnect.session_expiry_interval(pkt), 65535)
      try h.assert_eq[String val]((MqttDisconnect.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttDisconnect.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
      try h.assert_eq[String val]((MqttDisconnect.server_reference(pkt) as String val), "Unknown") else h.fail("Expect server-reference to be Unknown but got None") end
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not DISCONNECT")
    | MqttDecodeContinue =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.disconnect(origin, 45)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttDisconnect, let pkt: MqttDisconnectPacket), _) =>
      h.assert_eq[U8](MqttDisconnect.reason_code(pkt)(), MqttNormalDisconnection())
      h.assert_eq[U32](MqttDisconnect.session_expiry_interval(pkt), 65535)
      try h.assert_eq[String val]((MqttDisconnect.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttDisconnect.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
      try h.assert_eq[String val]((MqttDisconnect.server_reference(pkt) as String val), "Unknown") else h.fail("Expect server-reference to be Unknown but got None") end
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not DISCONNECT")
    | MqttDecodeContinue =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_empty(h: TestHelper)? =>
    let origin =
      MqttDisconnect.build(
        where
        reason_code' = MqttNormalDisconnection
      )

    let buf = MqttEncoder.disconnect(consume origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?] else [0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttDisconnect, let pkt: MqttDisconnectPacket), _) =>
      h.assert_eq[U8](MqttDisconnect.reason_code(pkt)(), MqttNormalDisconnection())
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not DISCONNECT")
    | MqttDecodeContinue =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttDisconnectPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    MqttDisconnect.build(
      where
      reason_code' = MqttNormalDisconnection,
      session_expiry_interval' = 65535,
      reason_string' = "Unknown",
      user_properties' = consume user_properties,
      server_reference' = "Unknown"
    )
