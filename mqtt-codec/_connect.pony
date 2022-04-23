use "pony_test"
use "collections"

class _TestConnect is UnitTest
  fun name(): String => "CONNECT"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin =
      MqttConnect.build(
        where
        protocol_name' = "MQTT",
        keep_alive' = 300,
        client_identifier' = "client-id",
        user_name' = "user-name",
        password' = [0; 1; 2; 3],
        will_topic' = "will-topic",
        will_payload' = [4; 5; 6; 7]
      )

    let buf = MqttEncoder.connect(consume origin, MqttVersion311)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf) ?
    | (MqttDecodeDone, (MqttConnect, let pkt: MqttConnectPacket), _) =>
      h.assert_eq[U16](MqttConnect.keep_alive(pkt), 300)
      h.assert_eq[String val](MqttConnect.client_identifier(pkt), "client-id")
      try h.assert_eq[String val](MqttConnect.user_name(pkt) as String val, "user-name") else h.fail("Expect user-name to be user-name but got None") end
      try h.assert_array_eq[U8](MqttConnect.password(pkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect password to be [0, 1, 2, 3] but got None") end
      try h.assert_eq[String val](MqttConnect.will_topic(pkt) as String val, "will-topic") else h.fail("Expect will-topic to be will-topic but got None") end
      try h.assert_array_eq[U8](MqttConnect.will_payload(pkt) as Array[U8] val, [4; 5; 6; 7]) else h.fail("Expect will-payload to be [4, 5, 6, 7] but got None") end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not CONNECT")
    | MqttDecodeContinue =>
      h.fail("Encoded CONNECT packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let will_properties: MqttWillProperties =
      MqttWillPropertiesAccessor.build(
        where
        will_delay_interval' = 100,
        payload_format_indicator' = MqttCharacterData,
        message_expiry_interval' = 65535,
        content_type' = "json",
        response_topic' = "response-topic",
        correlation_data' = [0x0C; 0x0D; 0x0E; 0x0F],
        user_properties' = [("is-secret", "true"); ("tag", "first-tag"); ("tag", "second-tag")]
      )
    let user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty](2) end
    user_properties.push(("foo", "bar"))
    user_properties.push(("hello", "world"))
    let origin: MqttConnectPacket =
      MqttConnect.build(
        where
        protocol_name' = "MQTT",
        keep_alive' = 300,
        client_identifier' = "client-id",
        user_name' = "user-name",
        password' = [0; 1; 2; 3],
        session_expiry_interval' = 10,
        will_topic' = "will-topic",
        will_payload' = [4; 5; 6; 7],
        will_properties' = will_properties,
        receive_maximum' = 65535,
        maximum_packet_size' = 65535,
        topic_alias_maximum' = 65535,
        request_response_information' = true,
        request_problem_information' = true,
        user_properties' = consume user_properties,
        authentication_method' = "Plain",
        authentication_data' = [8; 9; 0x0A; 0x0B]
      )

    let buf = MqttEncoder.connect(consume origin)
    let buf': Array[U8] iso = recover iso try [buf(1)?; buf(2)?] else [0; 0] end end
    (let remaining: ULong, let remainlen: USize) = try _MqttVariableByteInteger.decode(consume buf', 0)? else (0, 1) end
    h.assert_eq[USize](remaining.usize() + remainlen + 1, buf.size())
    match MqttDecoder(consume buf) ?
    | (MqttDecodeDone, (MqttConnect, let pkt: MqttConnectPacket), _) =>
      h.assert_eq[U16](MqttConnect.keep_alive(pkt), 300)
      h.assert_eq[U32](MqttConnect.session_expiry_interval(pkt), 10)
      h.assert_eq[U16](MqttConnect.receive_maximum(pkt), 65535)
      h.assert_eq[U32](MqttConnect.maximum_packet_size(pkt), 65535)
      h.assert_eq[U16](MqttConnect.topic_alias_maximum(pkt), 65535)
      h.assert_eq[Bool](MqttConnect.request_response_information(pkt), true)
      h.assert_eq[Bool](MqttConnect.request_problem_information(pkt), true)
      try _TestUtils.assert_user_properties_eq(h, (MqttConnect.user_properties(pkt) as Array[MqttUserProperty] val), [("foo", "bar"); ("hello", "world")]) else h.fail("Expect [(\"foo\", \"bar\"), (\"hello\", \"world\")], but got None") end
      try h.assert_array_eq[U8](MqttConnect.authentication_data(pkt) as Array[U8] val, [8; 9; 0x0A; 0x0B]) else h.fail("Expect authentication-data to be [8, 9, A, B] but got None") end
      h.assert_eq[String val](MqttConnect.client_identifier(pkt), "client-id")
      try h.assert_eq[U32](MqttWillPropertiesAccessor.will_delay_interval(MqttConnect.will_properties(pkt) as MqttWillProperties val), 100) else h.fail("Expect will-delay-interval to be 100 but got None") end
      try h.assert_eq[U8](MqttWillPropertiesAccessor.payload_format_indicator(MqttConnect.will_properties(pkt) as MqttWillProperties val)(), MqttCharacterData()) else h.fail("Expect payload-format-indicator to be charactor-data but got None") end
      try h.assert_eq[U32](MqttWillPropertiesAccessor.message_expiry_interval(MqttConnect.will_properties(pkt) as MqttWillProperties val), 65535) else h.fail("Expect message-expiry-interval to be 65535 but got None") end
      try h.assert_eq[String val](MqttWillPropertiesAccessor.content_type(MqttConnect.will_properties(pkt) as MqttWillProperties val), "json") else h.fail("Expect content-type to be json but got None") end
      try h.assert_eq[String val](MqttWillPropertiesAccessor.response_topic(MqttConnect.will_properties(pkt) as MqttWillProperties val), "response-topic") else h.fail("Expect response-topic to be response-topic but got None") end
      try h.assert_array_eq[U8]((MqttWillPropertiesAccessor.correlation_data(MqttConnect.will_properties(pkt) as MqttWillProperties val)) as Array[U8] val, [0x0C; 0x0D; 0x0E; 0x0F]) else h.fail("Expect correlation-data to be [C, D, E, F] but got None") end
      try h.assert_eq[USize]((MqttWillPropertiesAccessor.user_properties((MqttConnect.will_properties(pkt) as MqttWillProperties val)) as Array[MqttUserProperty] val).size(), 3) else h.fail("Expect length of user-properties in will to be 3") end
      try
        let pair = (MqttWillPropertiesAccessor.user_properties((MqttConnect.will_properties(pkt) as MqttWillProperties val)) as Array[MqttUserProperty] val)(0) ?
        h.assert_eq[String val](pair._1, "is-secret")
        h.assert_eq[String val](pair._2, "true")
      else
        h.fail("Expect first item in user-properties in will to be (is-secret, true)")
      end
      try
        let pair = (MqttWillPropertiesAccessor.user_properties((MqttConnect.will_properties(pkt) as MqttWillProperties val)) as Array[MqttUserProperty] val)(1) ?
        h.assert_eq[String val](pair._1, "tag")
        h.assert_eq[String val](pair._2, "first-tag")
      else
        h.fail("Expect second item in user-properties in will to be (tag, first-tag)")
      end
      try
        let pair = (MqttWillPropertiesAccessor.user_properties((MqttConnect.will_properties(pkt) as MqttWillProperties val)) as Array[MqttUserProperty] val)(2) ?
        h.assert_eq[String val](pair._1, "tag")
        h.assert_eq[String val](pair._2, "second-tag")
      else
        h.fail("Expect third item in user-properties in will to be (tag, second-tag)")
      end
      try h.assert_eq[String val](MqttConnect.will_topic(pkt) as String val, "will-topic") else h.fail("Expect will-topic to be will-topic but got None") end
      try h.assert_array_eq[U8](MqttConnect.will_payload(pkt) as Array[U8] val, [4; 5; 6; 7]) else h.fail("Expect will-payload to be [4, 5, 6, 7] but got None") end
      try h.assert_eq[String val](MqttConnect.user_name(pkt) as String val, "user-name") else h.fail("Expect user-name to be user-name but got None") end
      try h.assert_array_eq[U8](MqttConnect.password(pkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect password to be [0, 1, 2, 3] but got None") end
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Encoded packet is not CONNECT")
    | MqttDecodeContinue =>
      h.fail("Encoded CONNECT packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end
