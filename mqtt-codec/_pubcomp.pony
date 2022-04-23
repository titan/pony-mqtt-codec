use "pony_test"
use "collections"

class _TestPubComp is UnitTest
  fun name(): String => "PUBCOMP"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?
    _test_mqtt5_too_large(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let origin =
      MqttPubComp.build(
        where
        packet_identifier' = 65535
      )

    let buf = MqttEncoder.pubcomp(consume origin, 0, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttPubComp, let pkt: MqttPubCompPacket), _) =>
      h.assert_eq[U16](MqttPubComp.packet_identifier(pkt), 65535)
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBCOMP")
    | MqttDecodeContinue =>
      h.fail("Encoded PUBCOMP packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.pubcomp(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttPubComp, let pkt: MqttPubCompPacket), _) =>
      h.assert_eq[U16](MqttPubComp.packet_identifier(pkt), 65535)
      h.assert_eq[U8](MqttPubComp.reason_code(pkt)(), MqttSuccess())
      try h.assert_eq[String val]((MqttPubComp.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttPubComp.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBCOMP")
    | MqttDecodeContinue =>
      h.fail("Encoded PUBCOMP packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.pubcomp(origin, 32)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttPubComp, let pkt: MqttPubCompPacket), _) =>
      h.assert_eq[U16](MqttPubComp.packet_identifier(pkt), 65535)
      h.assert_eq[U8](MqttPubComp.reason_code(pkt)(), MqttSuccess())
      try h.assert_eq[String val]((MqttPubComp.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttPubComp.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBCOMP")
    | MqttDecodeContinue =>
      h.fail("Encoded PUBCOMP packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttPubCompPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    MqttPubComp.build(
      where
      packet_identifier' = 65535,
      reason_code' = MqttSuccess,
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
