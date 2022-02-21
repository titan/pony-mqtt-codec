use "ponytest"
use "buffered"
use "collections"

class _TestUnsubscribe is UnitTest
  fun name(): String => "UNSUBSCRIBE"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let topic_filters: Array[String] = [
      "#"
      "foobar"
    ]
    let origin = MqttUnsubscribePacket(
      where
      packet_identifier' = 65535,
      topic_filters' = topic_filters
    )

    let buf = MqttUnsubscribe.encode(origin, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttUnsubscribePacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.topic_filters.size(), 2)
        h.assert_eq[String](pkt.topic_filters(0)?, "#")
        h.assert_eq[String](pkt.topic_filters(1)?, "foobar")
      else
        h.fail("Encoded packet is not UNSUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let topic_filters: Array[String] = [
      "#"
      "foobar"
    ]
    let origin = MqttUnsubscribePacket(
      where
      packet_identifier' = 65535,
      topic_filters' = topic_filters,
      user_properties' = user_properties
    )

    let buf = MqttUnsubscribe.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttUnsubscribePacket =>
        h.assert_eq[U16](pkt.packet_identifier, 65535)
        h.assert_eq[USize](pkt.topic_filters.size(), 2)
        h.assert_eq[String](pkt.topic_filters(0)?, "#")
        h.assert_eq[String](pkt.topic_filters(1)?, "foobar")
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not UNSUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end
