use "ponytest"
use "buffered"
use "collections"

class _TestPublish is UnitTest
  fun name(): String => "PUBLISH"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin = MqttPublishPacket(
      where
      dup_flag' = true,
      qos_level' = MqttQoS1,
      packet_identifier' = 0,
      retain' = true,
      topic_name' = "",
      payload' = [0; 1; 2; 3]
    )

    let buf = MqttPublish.encode(origin, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttPublishPacket =>
        h.assert_eq[Bool](pkt.dup_flag, true)
        h.assert_eq[U8](pkt.qos_level(), MqttQoS1())
        try h.assert_eq[U16](pkt.packet_identifier as U16, 0) else h.fail("Expect packet-identifier to be 0 but got None") end
        h.assert_eq[Bool](pkt.retain, true)
        h.assert_eq[String](pkt.topic_name, "")
        try h.assert_array_eq[U8](pkt.payload as Array[U8], [0; 1; 2; 3]) else h.fail("Expect payload to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not PUBLISH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let origin = MqttPublishPacket(
      where
      dup_flag' = true,
      qos_level' = MqttQoS1,
      retain' = true,
      topic_name' = "",
      packet_identifier' = 0,
      payload_format_indicator' = MqttUnspecifiedBytes,
      message_expiry_interval' = 65535,
      topic_alias' = 65535,
      response_topic' = "response-topic",
      correlation_data' = [4; 5; 6; 7],
      user_properties' = user_properties,
      subscription_identifier' = 127,
      content_type' = "json",
      payload' = [0; 1; 2; 3]
    )

    let buf = MqttPublish.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttPublishPacket =>
        h.assert_eq[Bool](pkt.dup_flag, true)
        h.assert_eq[U8](pkt.qos_level(), MqttQoS1())
        h.assert_eq[Bool](pkt.retain, true)
        h.assert_eq[String](pkt.topic_name, "")
        try h.assert_eq[U16](pkt.packet_identifier as U16, 0) else h.fail("Expect packet-identifier to be 0 but got None") end
        try h.assert_eq[U8]((pkt.payload_format_indicator as MqttPayloadFormatIndicatorType)(), MqttUnspecifiedBytes()) else h.fail("Expect payload-format-indicator to be MqttUnspecifiedBytes but got None") end
        try h.assert_eq[U16](pkt.topic_alias as U16, 65535) else h.fail("Expect topic-alias to be 65535 but got None") end
        try h.assert_eq[String](pkt.response_topic as String, "response-topic") else h.fail("Expect response-topic to be response-topic but got None") end
        try h.assert_array_eq[U8](pkt.correlation_data as Array[U8], [4; 5; 6; 7]) else h.fail("Expect correlation-data to be [4, 5, 6, 7] but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
        try h.assert_eq[ULong](pkt.subscription_identifier as ULong, 127) else h.fail("Expect subscription-identifier to be 127 but got None") end
        try h.assert_eq[String](pkt.content_type as String, "json") else h.fail("Expect content-type to be json but got None") end
        try h.assert_array_eq[U8](pkt.payload as Array[U8], [0; 1; 2; 3]) else h.fail("Expect payload to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not PUBLISH")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end
