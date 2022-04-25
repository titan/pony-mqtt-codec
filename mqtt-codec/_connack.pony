use "pony_test"
use "collections"

class _TestConnAck is UnitTest
  fun name(): String => "CONNACK"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin = MqttConnAck.build(
      where
      session_present' = true,
      return_code' = MqttConnectionAccepted,
      reason_code' = MqttUnsupportedProtocolVersion
    )

    let buf = MqttEncoder.connack(consume origin, 0, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311) ?
    | (MqttDecodeDone, (MqttConnAck, let pkt: MqttConnAckPacket), _) =>
      h.assert_eq[Bool](MqttConnAck.session_present(pkt), true)
      h.assert_eq[MqttConnectReturnCode](MqttConnAck.return_code(pkt), MqttConnectionAccepted)
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not CONNACK")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()
    let buf = MqttEncoder.connack(consume origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf) ?
    | (MqttDecodeDone, (MqttConnAck, let pkt: MqttConnAckPacket), _) =>
      h.assert_eq[Bool](MqttConnAck.session_present(pkt), true)
      h.assert_eq[MqttConnectReasonCode](MqttConnAck.reason_code(pkt), MqttSuccess)
      h.assert_eq[U32](MqttConnAck.session_expiry_interval(pkt), 10)
      h.assert_eq[U16](MqttConnAck.receive_maximum(pkt), 65535)
      h.assert_eq[Bool](MqttConnAck.maximum_qos(pkt), true)
      h.assert_eq[U32](MqttConnAck.maximum_packet_size(pkt), 65535)
      try h.assert_eq[String val](MqttConnAck.assigned_client_identifier(pkt) as String, "identifier") else h.fail("Expect assigned-client-identifier to be identifier but got None") end
      h.assert_eq[U16](MqttConnAck.topic_alias_maximum(pkt), 65535)
      try h.assert_eq[String val](MqttConnAck.reason_string(pkt) as String, "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttConnAck.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
      h.assert_eq[Bool](MqttConnAck.wildcard_subscription_available(pkt), true)
      h.assert_eq[Bool](MqttConnAck.subscription_identifier_available(pkt), true)
      h.assert_eq[Bool](MqttConnAck.shared_subscription_available(pkt), true)
      h.assert_eq[U16](MqttConnAck.server_keep_alive(pkt), 65535)
      try h.assert_eq[String val](MqttConnAck.server_reference(pkt) as String, "server-reference") else h.fail("Expect server-reference to be server-reference but got None") end
      try h.assert_eq[String val](MqttConnAck.authentication_method(pkt) as String, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
      try h.assert_array_eq[U8](MqttConnAck.authentication_data(pkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not CONNACK")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()
    let maximum_packet_size: USize = 125
    let buf = MqttEncoder.connack(origin, maximum_packet_size)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf) ?
    | (MqttDecodeDone, (MqttConnAck, let pkt: MqttConnAckPacket), _) =>
      h.assert_eq[Bool](MqttConnAck.session_present(pkt), true)
      h.assert_eq[MqttConnectReasonCode](MqttConnAck.reason_code(pkt), MqttSuccess)
      h.assert_eq[U32](MqttConnAck.session_expiry_interval(pkt), 10)
      h.assert_eq[U16](MqttConnAck.receive_maximum(pkt), 65535)
      h.assert_eq[Bool](MqttConnAck.maximum_qos(pkt), true)
      h.assert_eq[U32](MqttConnAck.maximum_packet_size(pkt), 65535)
      try h.assert_eq[String val](MqttConnAck.assigned_client_identifier(pkt) as String val, "identifier") else h.fail("Expect assigned-client-identifier to be identifier but got None") end
      h.assert_eq[U16](MqttConnAck.topic_alias_maximum(pkt), 65535)
      try h.assert_eq[String val](MqttConnAck.reason_string(pkt) as String val, "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttConnAck.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar")]) else h.fail("Expect [(\"foo\", \"bar\")], but got None") end
      h.assert_eq[Bool](MqttConnAck.wildcard_subscription_available(pkt), true)
      h.assert_eq[Bool](MqttConnAck.subscription_identifier_available(pkt), true)
      h.assert_eq[Bool](MqttConnAck.shared_subscription_available(pkt), true)
      h.assert_eq[U16](MqttConnAck.server_keep_alive(pkt), 65535)
      try h.assert_eq[String val](MqttConnAck.server_reference(pkt) as String val, "server-reference") else h.fail("Expect server-reference to be server-reference but got None") end
      try h.assert_eq[String val](MqttConnAck.authentication_method(pkt) as String val, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
      try h.assert_array_eq[U8](MqttConnAck.authentication_data(pkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not CONNACK")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttConnAckPacket =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    MqttConnAck.build(
      where
      session_present' = true,
      return_code' = MqttUnacceptableProtocolVersion,
      reason_code' = MqttSuccess,
      session_expiry_interval' = 10,
      receive_maximum' = 65535,
      maximum_qos' = true,
      retain_available' = true,
      maximum_packet_size' = 65535,
      assigned_client_identifier' = "identifier",
      topic_alias_maximum' = 65535,
      reason_string' = "Unknown",
      user_properties' = consume user_properties,
      wildcard_subscription_available' = true,
      subscription_identifier_available' = true,
      shared_subscription_available' = true,
      server_keep_alive' = 65535,
      response_information' = "response-information",
      server_reference' = "server-reference",
      authentication_method' = "Plain",
      authentication_data' = [0; 1; 2; 3]
    )
