use "pony_test"
use "collections"

class _TestPubRec is UnitTest
  fun name(): String => "PUBREC"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?
    _test_mqtt5_too_large(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let origin =
      MqttPubRec.build(
        where
        packet_identifier' = 65535
      )

    let buf = MqttEncoder.pubrec(consume origin, 0, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttPubRec, let pkt: MqttPubRecPacket), _) =>
      h.assert_eq[U16](MqttPubRec.packet_identifier(pkt), 65535)
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBREC")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBREC packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.pubrec(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttPubRec, let pkt: MqttPubRecPacket), _) =>
      h.assert_eq[U16](MqttPubRec.packet_identifier(pkt), 65535)
      h.assert_eq[U8](MqttPubRec.reason_code(pkt)(), MqttSuccess())
      try h.assert_eq[String val]((MqttPubRec.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttPubRec.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBREC")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBREC packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.pubrec(origin, 32)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttPubRec, let pkt: MqttPubRecPacket), _) =>
      h.assert_eq[U16](MqttPubRec.packet_identifier(pkt), 65535)
      h.assert_eq[U8](MqttPubRec.reason_code(pkt)(), MqttSuccess())
      try h.assert_eq[String val]((MqttPubRec.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttPubRec.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBREC")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBREC packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttPubRecPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    MqttPubRec.build(
      where
      packet_identifier' = 65535,
      reason_code' = MqttSuccess,
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
