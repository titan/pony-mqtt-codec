use "pony_test"
use "collections"

class _TestUnSubAck is UnitTest
  fun name(): String => "UNSUBACK"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?
    _test_mqtt5_too_large(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let origin =
      MqttUnSubAck.build(
        where
        packet_identifier' = 65535
      )

    let buf = MqttEncoder.unsuback(consume origin, 0, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttUnSubAck, let pkt: MqttUnSubAckPacket), _) =>
      h.assert_eq[U16](MqttUnSubAck.packet_identifier(pkt), 65535)
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not UNSUBACK")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.unsuback(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttUnSubAck, let pkt: MqttUnSubAckPacket), _) =>
      h.assert_eq[U16](MqttUnSubAck.packet_identifier(pkt), 65535)
      try h.assert_eq[USize]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val).size(), 4) else h.fail("Expect 4 items in reason-codes but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(0)?(), MqttSuccess()) else h.fail("Expect 1st reason-code to be MqttSuccess but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(1)?(), MqttNoSubscriptionExisted()) else h.fail("Expect 2nd reason-code to be MqttNoSubscriptionExisted but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(2)?(), MqttImplementationSpecificError()) else h.fail("Expect 3rd reason-code to be MqttImplementationSpecificError but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(3)?(), MqttUnspecifiedError()) else h.fail("Expect 4th reason-code to be MqttUnspecifiedError but got None") end
      try h.assert_eq[String val]((MqttUnSubAck.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttUnSubAck.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not UNSUBACK")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper)? =>
    let origin = _mqtt5_packet()

    let buf = MqttEncoder.unsuback(origin, 35)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttUnSubAck, let pkt: MqttUnSubAckPacket), _) =>
      h.assert_eq[U16](MqttUnSubAck.packet_identifier(pkt), 65535)
      try h.assert_eq[USize]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val).size(), 4) else h.fail("Expect 4 items in reason-codes but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(0)?(), MqttSuccess()) else h.fail("Expect 1st reason-code to be MqttSuccess but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(1)?(), MqttNoSubscriptionExisted()) else h.fail("Expect 2nd reason-code to be MqttNoSubscriptionExisted but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(2)?(), MqttImplementationSpecificError()) else h.fail("Expect 3rd reason-code to be MqttImplementationSpecificError but got None") end
      try h.assert_eq[U8]((MqttUnSubAck.reason_codes(pkt) as Array[MqttUnSubAckReasonCode val] val)(3)?(), MqttUnspecifiedError()) else h.fail("Expect 4th reason-code to be MqttUnspecifiedError but got None") end
      try h.assert_eq[String val]((MqttUnSubAck.reason_string(pkt) as String val), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttUnSubAck.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not UNSUBACK")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttUnSubAckPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    let reason_codes: Array[MqttUnSubAckReasonCode val] val = [
      MqttSuccess
      MqttNoSubscriptionExisted
      MqttImplementationSpecificError
      MqttUnspecifiedError
    ]
    MqttUnSubAck.build(
      where
      packet_identifier' = 65535,
      reason_codes' = reason_codes,
      reason_string' = "Unknown",
      user_properties' = consume user_properties
    )
