use "pony_test"
use "collections"

class _TestPublish is UnitTest
  fun name(): String => "PUBLISH"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let origin =
      MqttPublish.build(
        where
        dup_flag' = true,
        qos_level' = MqttQoS1,
        packet_identifier' = 1,
        retain' = true,
        topic_name' = "",
        payload' = [0; 1; 2; 3]
      )

    let buf = MqttEncoder.publish(origin, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttPublish, let pkt: MqttPublishPacket), _) =>
      h.assert_eq[Bool](MqttPublish.dup_flag(pkt), true)
      h.assert_eq[MqttQoS val](MqttPublish.qos_level(pkt), MqttQoS1)
      h.assert_eq[U16](MqttPublish.packet_identifier(pkt), 1)
      h.assert_eq[Bool](MqttPublish.retain(pkt), true)
      h.assert_eq[String val](MqttPublish.topic_name(pkt), "")
      try h.assert_array_eq[U8](MqttPublish.payload(pkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect payload to be [0, 1, 2, 3] but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBLISH")
    | MqttDecodeContinue =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    let origin =
      MqttPublish.build(
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
    let buf = MqttEncoder.publish(origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttPublish, let pkt: MqttPublishPacket), _) =>
      h.assert_eq[Bool](MqttPublish.dup_flag(pkt), true)
      h.assert_eq[MqttQoS val](MqttPublish.qos_level(pkt), MqttQoS1)
      h.assert_eq[Bool](MqttPublish.retain(pkt), true)
      h.assert_eq[String val](MqttPublish.topic_name(pkt), "")
      h.assert_eq[U16](MqttPublish.packet_identifier(pkt), 1)
      h.assert_eq[U8](MqttPublish.payload_format_indicator(pkt)(), MqttUnspecifiedBytes())
      h.assert_eq[U16](MqttPublish.topic_alias(pkt), 65535)
      try h.assert_eq[String val](MqttPublish.response_topic(pkt) as String val, "response-topic") else h.fail("Expect response-topic to be response-topic but got None") end
      try h.assert_array_eq[U8](MqttPublish.correlation_data(pkt) as Array[U8] val, [4; 5; 6; 7]) else h.fail("Expect correlation-data to be [4, 5, 6, 7] but got None") end
      try _TestUtils.assert_user_properties_eq(h, (MqttPublish.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
      h.assert_eq[ULong](MqttPublish.subscription_identifier(pkt), 127)
      try h.assert_eq[String val](MqttPublish.content_type(pkt) as String val, "json") else h.fail("Expect content-type to be json but got None") end
      try h.assert_array_eq[U8](MqttPublish.payload(pkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect payload to be [0, 1, 2, 3] but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBLISH")
    | MqttDecodeContinue =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end
