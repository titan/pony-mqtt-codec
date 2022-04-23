use "pony_test"
use "collections"

class _TestSubAck is UnitTest
  fun name(): String => "SUBACK"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?
    _test_mqtt5_too_large(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let reason_codes: Array[MqttSubAckReasonCode val] val = [
      MqttGrantedQoS0
      MqttGrantedQoS1
      MqttGrantedQoS2
      MqttUnspecifiedError
    ]
    let origin =
      MqttSubAck.build(
        where
        packet_identifier' = 65535,
        reason_codes' = reason_codes
      )

    let buf = MqttEncoder.suback(consume origin, 0, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttSubAck, let pkt: MqttSubAckPacket), _) =>
      h.assert_eq[U16](MqttSubAck.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttSubAck.reason_codes(pkt).size(), 4)
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(0)?(), MqttGrantedQoS0())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(1)?(), MqttGrantedQoS1())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(2)?(), MqttGrantedQoS2())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(3)?(), MqttUnspecifiedError())
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not SUBACK")
    | MqttDecodeContinue =>
      h.fail("Encoded SUBACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.suback(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttSubAck, let pkt: MqttSubAckPacket), _) =>
      h.assert_eq[U16](MqttSubAck.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttSubAck.reason_codes(pkt).size(), 4)
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(0)?(), MqttGrantedQoS0())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(1)?(), MqttGrantedQoS1())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(2)?(), MqttGrantedQoS2())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(3)?(), MqttUnspecifiedError())
      try h.assert_eq[String val]((MqttSubAck.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttSubAck.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not SUBACK")
    | MqttDecodeContinue =>
      h.fail("Encoded SUBACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.suback(origin, 35)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttSubAck, let pkt: MqttSubAckPacket), _) =>
      h.assert_eq[U16](MqttSubAck.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttSubAck.reason_codes(pkt).size(), 4)
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(0)?(), MqttGrantedQoS0())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(1)?(), MqttGrantedQoS1())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(2)?(), MqttGrantedQoS2())
      h.assert_eq[U8](MqttSubAck.reason_codes(pkt)(3)?(), MqttUnspecifiedError())
      try h.assert_eq[String val]((MqttSubAck.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttSubAck.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not SUBACK")
    | MqttDecodeContinue =>
      h.fail("Encoded SUBACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttSubAckPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    let reason_codes: Array[MqttSubAckReasonCode] val = [
      MqttGrantedQoS0
      MqttGrantedQoS1
      MqttGrantedQoS2
      MqttUnspecifiedError
    ]
    MqttSubAck.build(
      where
      packet_identifier' = 65535,
      reason_codes' = reason_codes,
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
