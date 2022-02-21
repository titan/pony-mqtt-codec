use "ponytest"
use "buffered"
use "collections"

class _TestSubscribe is UnitTest
  fun name(): String => "SUBSCRIBE"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let topic_subscriptions: Array[MqttTopicSubscription] = [
      MqttTopicSubscription("#", MqttQoS0)
      MqttTopicSubscription("foobar", MqttQoS1)
    ]
    let origin = MqttSubscribePacket(
      where
      packet_identifier' = 65535,
      topic_subscriptions' = topic_subscriptions
    )

    let buf = MqttSubscribe.encode(origin, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttSubscribePacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.topic_subscriptions.size(), 2)
        try h.assert_eq[String](pkt.topic_subscriptions(0)?.topic_filter, "#") else h.fail("Expect first topic-filter to be # but got None") end
        try h.assert_eq[U8](pkt.topic_subscriptions(0)?.qos_level(), MqttQoS0()) else h.fail("Expect first qos-level to be QoS0 but got None") end
        try h.assert_eq[String](pkt.topic_subscriptions(1)?.topic_filter, "foobar") else h.fail("Expect second topic-filter to be foobar but got None") end
        try h.assert_eq[U8](pkt.topic_subscriptions(1)?.qos_level(), MqttQoS1()) else h.fail("Expect second qos-level to be QoS1 but got None") end
      else
        h.fail("Encoded packet is not SUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let topic_subscriptions: Array[MqttTopicSubscription] = [
      MqttTopicSubscription("#", MqttQoS0)
      MqttTopicSubscription("foobar", MqttQoS1)
    ]
    let origin = MqttSubscribePacket(
      where
      packet_identifier' = 65535,
      topic_subscriptions' = topic_subscriptions,
      subscription_identifier' = 65535,
      user_properties' = user_properties
    )

    let buf = MqttSubscribe.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttSubscribePacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.topic_subscriptions.size(), 2)
        try h.assert_eq[String](pkt.topic_subscriptions(0)?.topic_filter, "#") else h.fail("Expect first topic-filter to be # but got None") end
        try h.assert_eq[U8](pkt.topic_subscriptions(0)?.qos_level(), MqttQoS0()) else h.fail("Expect first qos-level to be QoS0 but got None") end
        try h.assert_eq[String](pkt.topic_subscriptions(1)?.topic_filter, "foobar") else h.fail("Expect second topic-filter to be foobar but got None") end
        try h.assert_eq[U8](pkt.topic_subscriptions(1)?.qos_level(), MqttQoS1()) else h.fail("Expect second qos-level to be QoS1 but got None") end
        try h.assert_eq[ULong](pkt.subscription_identifier as ULong, 65535) else h.fail("Expect subscription-identifier to be 65535 but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not SUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end
