use "pony_test"
use "buffered"
use "collections"

class _TestConnAck is UnitTest
  fun name(): String => "CONNACK"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin = MqttConnAckPacket(
      where
      session_present' = true,
      return_code' = MqttConnectionAccepted
    )

    let buf = MqttConnAck.encode(consume origin, 0, MqttVersion311)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttConnAckPacket val =>
        h.assert_eq[Bool val](pkt.session_present, true)
        try h.assert_eq[U8 val]((pkt.return_code as MqttConnectReturnCode)(), MqttConnectionAccepted()) else h.fail("Expect return-code to be 0 but got None") end
      else
        h.fail("Encoded packet is not CONNACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()
    let buf = MqttConnAck.encode(origin)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttConnAckPacket val =>
        h.assert_eq[Bool val](pkt.session_present, true)
        try h.assert_eq[U8 val]((pkt.reason_code as MqttConnectReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be 0 but got None") end
        h.assert_eq[U32 val](pkt.session_expiry_interval, 10)
        h.assert_eq[U16 val](pkt.receive_maximum, 65535)
        h.assert_eq[Bool val](pkt.maximum_qos, true)
        h.assert_eq[U32 val](pkt.maximum_packet_size, 65535)
        try h.assert_eq[String val](pkt.assigned_client_identifier as String, "identifier") else h.fail("Expect assigned-client-identifier to be identifier but got None") end
        h.assert_eq[U16 val](pkt.topic_alias_maximum, 65535)
        try h.assert_eq[String val](pkt.reason_string as String, "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
        h.assert_eq[Bool val](pkt.wildcard_subscription_available, true)
        h.assert_eq[Bool val](pkt.subscription_identifier_available, true)
        h.assert_eq[Bool val](pkt.shared_subscription_available, true)
        h.assert_eq[U16 val](pkt.server_keep_alive, 65535)
        try h.assert_eq[String val](pkt.server_reference as String, "server-reference") else h.fail("Expect server-reference to be server-reference but got None") end
        try h.assert_eq[String val](pkt.authentication_method as String, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8 val](pkt.authentication_data as Array[U8 val] val, [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not CONNACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()
    let maximum_packet_size: USize = 125
    let buf = MqttConnAck.encode(origin, maximum_packet_size)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttConnAckPacket val =>
        h.assert_eq[Bool val](pkt.session_present, true)
        try h.assert_eq[U8 val]((pkt.reason_code as MqttConnectReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be 0 but got None") end
        h.assert_eq[U32 val](pkt.session_expiry_interval, 10)
        h.assert_eq[U16 val](pkt.receive_maximum, 65535)
        h.assert_eq[Bool val](pkt.maximum_qos, true)
        h.assert_eq[U32 val](pkt.maximum_packet_size, 65535)
        try h.assert_eq[String val](pkt.assigned_client_identifier as String val, "identifier") else h.fail("Expect assigned-client-identifier to be identifier but got None") end
        h.assert_eq[U16 val](pkt.topic_alias_maximum, 65535)
        try h.assert_eq[String val](pkt.reason_string as String val, "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 1) else h.fail("Expect 1 items in user-properties") end
        h.assert_eq[Bool val](pkt.wildcard_subscription_available, true)
        h.assert_eq[Bool val](pkt.subscription_identifier_available, true)
        h.assert_eq[Bool val](pkt.shared_subscription_available, true)
        h.assert_eq[U16 val](pkt.server_keep_alive, 65535)
        try h.assert_eq[String val](pkt.server_reference as String val, "server-reference") else h.fail("Expect server-reference to be server-reference but got None") end
        try h.assert_eq[String val](pkt.authentication_method as String val, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8 val](pkt.authentication_data as Array[U8 val] val, [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not CONNACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttConnAckPacket =>
    let user_properties: Map[String val, String val] iso = recover iso Map[String val, String val](2) end
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    MqttConnAckPacket(
      where
      session_present' = true,
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
