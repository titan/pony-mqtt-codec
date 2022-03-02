use "ponytest"
use "buffered"
use "collections"

class _TestUnsubscribe is UnitTest
  fun name(): String => "UNSUBSCRIBE"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let topic_filters: Array[String val] val = [
      "#"
      "foobar"
    ]
    let origin =
      MqttUnsubscribePacket(
        where
        packet_identifier' = 65535,
        topic_filters' = topic_filters
      )

    let buf = MqttUnsubscribe.encode(consume origin, MqttVersion311)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val) =>
      match packet
      | let pkt: MqttUnsubscribePacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
        h.assert_eq[USize val](pkt.topic_filters.size(), 2)
        h.assert_eq[String val](pkt.topic_filters(0)?, "#")
        h.assert_eq[String val](pkt.topic_filters(1)?, "foobar")
      else
        h.fail("Encoded packet is not UNSUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let user_properties: Map[String val, String val] iso = recover iso Map[String val, String val](2) end
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let topic_filters: Array[String val] val = [
      "#"
      "foobar"
    ]
    let origin =
      MqttUnsubscribePacket(
        where
        packet_identifier' = 65535,
        topic_filters' = topic_filters,
        user_properties' = consume user_properties
      )

    let buf = MqttUnsubscribe.encode(consume origin)
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(buf, 1) ? else (0, 0) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType val) =>
      match packet
      | let pkt: MqttUnsubscribePacket val =>
        h.assert_eq[U16 val](pkt.packet_identifier, 65535)
        h.assert_eq[USize val](pkt.topic_filters.size(), 2)
        h.assert_eq[String val](pkt.topic_filters(0)?, "#")
        h.assert_eq[String val](pkt.topic_filters(1)?, "foobar")
        try h.assert_eq[USize val]((pkt.user_properties as Map[String val, String val] val).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String val]((pkt.user_properties as Map[String val, String val] val)("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
      else
        h.fail("Encoded packet is not UNSUBSCRIBE")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end
