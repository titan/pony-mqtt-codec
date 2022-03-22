use "pony_test"
use "buffered"
use "collections"

class _TestPublish is UnitTest
  fun name(): String => "PUBLISH"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin =
      MqttPublishPacket(
        where
        dup_flag' = true,
        qos_level' = MqttQoS1,
        packet_identifier' = 1,
        retain' = true,
        topic_name' = "",
        payload' = [0; 1; 2; 3]
      )

    let buf = MqttPublish.encode(consume origin, MqttVersion311)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttPublishPacket val =>
        h.assert_eq[Bool val](pkt.dup_flag, true)
        h.assert_eq[U8 val](pkt.qos_level(), MqttQoS1())
        h.assert_eq[U16 val](pkt.packet_identifier, 1)
        h.assert_eq[Bool val](pkt.retain, true)
        h.assert_eq[String val](pkt.topic_name, "")
        try h.assert_array_eq[U8 val](pkt.payload as Array[U8 val] val, [0; 1; 2; 3]) else h.fail("Expect payload to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not PUBLISH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String, _) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let user_properties: Map[String val, String val] iso = recover iso Map[String val, String val](2) end
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let origin =
      MqttPublishPacket(
        where
        dup_flag' = true,
        qos_level' = MqttQoS1,
        retain' = true,
        topic_name' = "",
        packet_identifier' = 1,
        payload_format_indicator' = MqttUnspecifiedBytes,
        message_expiry_interval' = 65535,
        topic_alias' = 65535,
        response_topic' = "response-topic",
        correlation_data' = [4; 5; 6; 7],
        user_properties' = consume user_properties,
        subscription_identifier' = 127,
        content_type' = "json",
        payload' = [0; 1; 2; 3]
      )
    let buf = MqttPublish.encode(consume origin)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttPublishPacket val =>
        h.assert_eq[Bool val](pkt.dup_flag, true)
        h.assert_eq[U8 val](pkt.qos_level(), MqttQoS1())
        h.assert_eq[Bool val](pkt.retain, true)
        h.assert_eq[String val](pkt.topic_name, "")
        h.assert_eq[U16 val](pkt.packet_identifier, 1)
        try h.assert_eq[U8 val]((pkt.payload_format_indicator as MqttPayloadFormatIndicatorType)(), MqttUnspecifiedBytes()) else h.fail("Expect payload-format-indicator to be MqttUnspecifiedBytes but got None") end
        h.assert_eq[U16 val](pkt.topic_alias, 65535)
        try h.assert_eq[String val](pkt.response_topic as String val, "response-topic") else h.fail("Expect response-topic to be response-topic but got None") end
        try h.assert_array_eq[U8 val](pkt.correlation_data as Array[U8 val] val, [4; 5; 6; 7]) else h.fail("Expect correlation-data to be [4, 5, 6, 7] but got None") end
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
        h.assert_eq[ULong](pkt.subscription_identifier, 127)
        try h.assert_eq[String val](pkt.content_type as String val, "json") else h.fail("Expect content-type to be json but got None") end
        try h.assert_array_eq[U8 val](pkt.payload as Array[U8 val] val, [0; 1; 2; 3]) else h.fail("Expect payload to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not PUBLISH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end
