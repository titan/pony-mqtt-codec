use "ponytest"
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

    let buf = MqttConnAck.encode(origin, None, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttConnAckPacket =>
        h.assert_eq[Bool](pkt.session_present, true)
        try h.assert_eq[U8]((pkt.return_code as MqttConnectReturnCode)(), MqttConnectionAccepted()) else h.fail("Expect return-code to be 0 but got None") end
      else
        h.fail("Encoded packet is not CONNACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()
    let buf = MqttConnAck.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttConnAckPacket =>
        h.assert_eq[Bool](pkt.session_present, true)
        try h.assert_eq[U8]((pkt.reason_code as MqttConnectReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be 0 but got None") end
        try h.assert_eq[U32](pkt.session_expiry_interval as U32, 10) else h.fail("Expect session_expiry_interval to be 10 but got None") end
        try h.assert_eq[U16](pkt.receive_maximum as U16, 65535) else h.fail("Expect receive-maximum to be 65535 but got None") end
        try h.assert_eq[Bool](pkt.maximum_qos as Bool, true) else h.fail("Expect maximum-qos to be true") end
        try h.assert_eq[U32](pkt.maximum_packet_size as U32, 65535) else h.fail("Expect maximum-packet-size to be 65535 but got None") end
        try h.assert_eq[String](pkt.assigned_client_identifier as String, "identifier") else h.fail("Expect assigned-client-identifier to be identifier but got None") end
        try h.assert_eq[U16](pkt.topic_alias_maximum as U16, 65535) else h.fail("Expect topic-alias-maximum to be 65535 but got None") end
        try h.assert_eq[String](pkt.reason_string as String, "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
        try h.assert_eq[Bool](pkt.wildcard_subscription_available as Bool, true) else h.fail("Expect wildcard-subscription-available to be true") end
        try h.assert_eq[Bool](pkt.subscription_identifier_available as Bool, true) else h.fail("Expect subscription-identifier-available to be true") end
        try h.assert_eq[Bool](pkt.shared_subscription_available as Bool, true) else h.fail("Expect shared-subscription-available to be true") end
        try h.assert_eq[U16](pkt.server_keep_alive as U16, 65535) else h.fail("Expect server-keep-alive to be 65535 but got None") end
        try h.assert_eq[String](pkt.server_reference as String, "server-reference") else h.fail("Expect server-reference to be server-reference but got None") end
        try h.assert_eq[String](pkt.authentication_method as String, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8](pkt.authentication_data as Array[U8], [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not CONNACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()
    let maximum_packet_size: USize = 125
    let buf = MqttConnAck.encode(origin, maximum_packet_size)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttConnAckPacket =>
        h.assert_eq[Bool](pkt.session_present, true)
        try h.assert_eq[U8]((pkt.reason_code as MqttConnectReasonCode)(), MqttSuccess()) else h.fail("Expect reason-code to be 0 but got None") end
        try h.assert_eq[U32](pkt.session_expiry_interval as U32, 10) else h.fail("Expect session_expiry_interval to be 10 but got None") end
        try h.assert_eq[U16](pkt.receive_maximum as U16, 65535) else h.fail("Expect receive-maximum to be 65535 but got None") end
        try h.assert_eq[Bool](pkt.maximum_qos as Bool, true) else h.fail("Expect maximum-qos to be true") end
        try h.assert_eq[U32](pkt.maximum_packet_size as U32, 65535) else h.fail("Expect maximum-packet-size to be 65535 but got None") end
        try h.assert_eq[String](pkt.assigned_client_identifier as String, "identifier") else h.fail("Expect assigned-client-identifier to be identifier but got None") end
        try h.assert_eq[U16](pkt.topic_alias_maximum as U16, 65535) else h.fail("Expect topic-alias-maximum to be 65535 but got None") end
        try h.assert_eq[String](pkt.reason_string as String, "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[Bool](pkt.wildcard_subscription_available as Bool, true) else h.fail("Expect wildcard-subscription-available to be true") end
        try h.assert_eq[Bool](pkt.subscription_identifier_available as Bool, true) else h.fail("Expect subscription-identifier-available to be true") end
        try h.assert_eq[Bool](pkt.shared_subscription_available as Bool, true) else h.fail("Expect shared-subscription-available to be true") end
        try h.assert_eq[U16](pkt.server_keep_alive as U16, 65535) else h.fail("Expect server-keep-alive to be 65535 but got None") end
        try h.assert_eq[String](pkt.server_reference as String, "server-reference") else h.fail("Expect server-reference to be server-reference but got None") end
        try h.assert_eq[String](pkt.authentication_method as String, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8](pkt.authentication_data as Array[U8], [0; 1; 2; 3]) else h.fail("Expect authentication-data to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not CONNACK")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNACK packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttConnAckPacket =>
    let user_properties: Map[String, String] = Map[String, String]()
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
      user_properties' = user_properties,
      wildcard_subscription_available' = true,
      subscription_identifier_available' = true,
      shared_subscription_available' = true,
      server_keep_alive' = 65535,
      response_information' = "response-information",
      server_reference' = "server-reference",
      authentication_method' = "Plain",
      authentication_data' = [0; 1; 2; 3]
    )
