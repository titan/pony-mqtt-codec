use "pony_test"
use "collections"

class _TestSubscribe is UnitTest
  fun name(): String => "SUBSCRIBE"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let subscriptions: Array[MqttSubscription] val = [
      MqttSubscriptionAccessor.build("#", MqttQoS0)
      MqttSubscriptionAccessor.build("foobar", MqttQoS1)
    ]
    let origin =
      MqttSubscribe.build(
        where
        packet_identifier' = 65535,
        subscriptions' = subscriptions
      )

    let buf = MqttEncoder.subscribe(consume origin, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttSubscribe, let pkt: MqttSubscribePacket), _) =>
      h.assert_eq[U16](MqttSubscribe.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttSubscribe.subscriptions(pkt).size(), 2)
      try h.assert_eq[String val](MqttSubscriptionAccessor.topic_filter(MqttSubscribe.subscriptions(pkt)(0)?), "#") else h.fail("Expect first topic-filter to be # but got None") end
      try h.assert_eq[U8](MqttSubscriptionAccessor.qos_level(MqttSubscribe.subscriptions(pkt)(0)?)(), MqttQoS0()) else h.fail("Expect first qos-level to be QoS0 but got None") end
      try h.assert_eq[String val](MqttSubscriptionAccessor.topic_filter(MqttSubscribe.subscriptions(pkt)(1)?), "foobar") else h.fail("Expect second topic-filter to be foobar but got None") end
      try h.assert_eq[U8](MqttSubscriptionAccessor.qos_level(MqttSubscribe.subscriptions(pkt)(1)?)(), MqttQoS1()) else h.fail("Expect second qos-level to be QoS1 but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not SUBSCRIBE")
    | MqttDecodeContinue =>
      h.fail("Encoded SUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    let subscriptions: Array[MqttSubscription] val = [
      MqttSubscriptionAccessor.build("#", MqttQoS0)
      MqttSubscriptionAccessor.build("foobar", MqttQoS1)
    ]
    let origin =
      MqttSubscribe.build(
        where
        packet_identifier' = 65535,
        subscriptions' = subscriptions,
        subscription_identifier' = 65535,
        user_properties' = consume user_properties
      )

    let buf = MqttEncoder.subscribe(consume origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttSubscribe, let pkt: MqttSubscribePacket), _) =>
      h.assert_eq[U16](MqttSubscribe.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttSubscribe.subscriptions(pkt).size(), 2)
      try h.assert_eq[String val](MqttSubscriptionAccessor.topic_filter(MqttSubscribe.subscriptions(pkt)(0)?), "#") else h.fail("Expect first topic-filter to be # but got None") end
      try h.assert_eq[U8](MqttSubscriptionAccessor.qos_level(MqttSubscribe.subscriptions(pkt)(0)?)(), MqttQoS0()) else h.fail("Expect first qos-level to be QoS0 but got None") end
      try h.assert_eq[String val](MqttSubscriptionAccessor.topic_filter(MqttSubscribe.subscriptions(pkt)(1)?), "foobar") else h.fail("Expect second topic-filter to be foobar but got None") end
      try h.assert_eq[U8](MqttSubscriptionAccessor.qos_level(MqttSubscribe.subscriptions(pkt)(1)?)(), MqttQoS1()) else h.fail("Expect second qos-level to be QoS1 but got None") end
      h.assert_eq[ULong](MqttSubscribe.subscription_identifier(pkt), 65535)
      try _TestUtils.assert_user_properties_eq(h, (MqttSubscribe.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not SUBSCRIBE")
    | MqttDecodeContinue =>
      h.fail("Encoded SUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end
