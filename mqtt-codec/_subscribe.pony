use "pony_test"
use "buffered"
use "collections"

class _TestSubscribe is UnitTest
  fun name(): String => "SUBSCRIBE"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let subscriptions: Array[MqttSubscription val] val = [
      MqttSubscription("#", MqttQoS0)
      MqttSubscription("foobar", MqttQoS1)
    ]
    let origin =
      MqttSubscribePacket(
        where
        packet_identifier' = 65535,
        subscriptions' = subscriptions
      )

    let buf = MqttSubscribe.encode(consume origin, MqttVersion311)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttSubscribePacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
        h.assert_eq[USize val](pkt.subscriptions.size(), 2)
        try h.assert_eq[String val](pkt.subscriptions(0)?.topic_filter, "#") else h.fail("Expect first topic-filter to be # but got None") end
        try h.assert_eq[U8 val](pkt.subscriptions(0)?.qos_level(), MqttQoS0()) else h.fail("Expect first qos-level to be QoS0 but got None") end
        try h.assert_eq[String val](pkt.subscriptions(1)?.topic_filter, "foobar") else h.fail("Expect second topic-filter to be foobar but got None") end
        try h.assert_eq[U8 val](pkt.subscriptions(1)?.qos_level(), MqttQoS1()) else h.fail("Expect second qos-level to be QoS1 but got None") end
      else
        h.fail("Encoded packet is not SUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let user_properties: Map[String val, String val] iso = recover iso Map[String val, String val](2) end
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let subscriptions: Array[MqttSubscription val] val = [
      MqttSubscription("#", MqttQoS0)
      MqttSubscription("foobar", MqttQoS1)
    ]
    let origin =
      MqttSubscribePacket(
        where
        packet_identifier' = 65535,
        subscriptions' = subscriptions,
        subscription_identifier' = 65535,
        user_properties' = consume user_properties
      )

    let buf = MqttSubscribe.encode(consume origin)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val, _) =>
      match packet
      | let pkt: MqttSubscribePacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
        h.assert_eq[USize val](pkt.subscriptions.size(), 2)
        try h.assert_eq[String val](pkt.subscriptions(0)?.topic_filter, "#") else h.fail("Expect first topic-filter to be # but got None") end
        try h.assert_eq[U8 val](pkt.subscriptions(0)?.qos_level(), MqttQoS0()) else h.fail("Expect first qos-level to be QoS0 but got None") end
        try h.assert_eq[String val](pkt.subscriptions(1)?.topic_filter, "foobar") else h.fail("Expect second topic-filter to be foobar but got None") end
        try h.assert_eq[U8 val](pkt.subscriptions(1)?.qos_level(), MqttQoS1()) else h.fail("Expect second qos-level to be QoS1 but got None") end
        h.assert_eq[ULong val](pkt.subscription_identifier, 65535)
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not SUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded SUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val, _) =>
      h.fail(err)
    end
