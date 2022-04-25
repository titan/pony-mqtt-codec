use "pony_test"
use "collections"

class _TestUnSubscribe is UnitTest
  fun name(): String => "UNSUBSCRIBE"

  fun apply(h: TestHelper)? =>
    _test_mqtt311(h)?
    _test_mqtt5(h)?

  fun _test_mqtt311(h: TestHelper)? =>
    let topic_filters: Array[String val] val = [
      "#"
      "foobar"
    ]
    let origin =
      MqttUnSubscribe.build(
        where
        packet_identifier' = 65535,
        topic_filters' = topic_filters
      )

    let buf = MqttEncoder.unsubscribe(consume origin, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf, MqttVersion311)?
    | (MqttDecodeDone, (MqttUnSubscribe, let pkt: MqttUnSubscribePacket), _) =>
      h.assert_eq[U16](MqttUnSubscribe.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttUnSubscribe.topic_filters(pkt).size(), 2)
      h.assert_eq[String val](MqttUnSubscribe.topic_filters(pkt)(0)?, "#")
      h.assert_eq[String val](MqttUnSubscribe.topic_filters(pkt)(1)?, "foobar")
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not UNSUBSCRIBE")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper)? =>
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    let topic_filters: Array[String val] val = [
      "#"
      "foobar"
    ]
    let origin =
      MqttUnSubscribe.build(
        where
        packet_identifier' = 65535,
        topic_filters' = topic_filters,
        user_properties' = consume user_properties
      )

    let buf = MqttEncoder.unsubscribe(consume origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0, 2)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf)?
    | (MqttDecodeDone, (MqttUnSubscribe, let pkt: MqttUnSubscribePacket), _) =>
      h.assert_eq[U16](MqttUnSubscribe.packet_identifier(pkt), 65535)
      h.assert_eq[USize](MqttUnSubscribe.topic_filters(pkt).size(), 2)
      h.assert_eq[String val](MqttUnSubscribe.topic_filters(pkt)(0)?, "#")
      h.assert_eq[String val](MqttUnSubscribe.topic_filters(pkt)(1)?, "foobar")
      try _TestUtils.assert_user_properties_eq(h, (MqttUnSubscribe.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not UNSUBSCRIBE")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded UNSUBSCRIBE packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end
