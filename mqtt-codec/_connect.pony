use "ponytest"
use "buffered"
use "collections"

class _TestConnect is UnitTest
  fun name(): String => "CONNECT"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin = MqttConnectPacket(
      where
      keep_alive' = 300,
      client_identifier' = "client-id",
      user_name' = "user-name",
      password' = [0; 1; 2; 3],
      will_topic' = "will-topic",
      will_payload' = [4; 5; 6; 7]
    )

    let buf = MqttConnect.encode(origin, MqttVersion311)
    let size = (MqttConnectMeasurer.variable_header_size(origin, MqttVersion311) + MqttConnectMeasurer.payload_size(origin, MqttVersion311)).ulong()
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttConnectPacket =>
        h.assert_eq[U16](pkt.keep_alive, 300)
        h.assert_eq[String](pkt.client_identifier, "client-id")
        try h.assert_eq[String](pkt.user_name as String, "user-name") else h.fail("Expect user-name to be user-name but got None") end
        try h.assert_array_eq[U8](pkt.password as Array[U8], [0; 1; 2; 3]) else h.fail("Expect password to be [0, 1, 2, 3] but got None") end
        try h.assert_eq[String](pkt.will_topic as String, "will-topic") else h.fail("Expect will-topic to be will-topic but got None") end
        try h.assert_array_eq[U8](pkt.will_payload as Array[U8], [4; 5; 6; 7]) else h.fail("Expect will-payload to be [4, 5, 6, 7] but got None") end
      else
        h.fail("Encoded packet is not CONNECT")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNECT packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let will_user_properties = [("is-secret", "true"); ("tag", "first-tag"); ("tag", "second-tag")]
    let will_properties = MqttWillProperties(
      where
      will_delay_interval' = 100,
      payload_format_indicator' = MqttCharacterData,
      message_expiry_interval' = 65535,
      content_type' = "json",
      response_topic' = "response-topic",
      correlation_data' = [0x0C; 0x0D; 0x0E; 0x0F],
      user_properties' = will_user_properties
    )
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    let origin = MqttConnectPacket(
      where
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
      user_properties' = user_properties,
      authentication_method' = "Plain",
      authentication_data' = [8; 9; 0x0A; 0x0B]
    )

    let buf = MqttConnect.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttConnectPacket =>
        h.assert_eq[U16](pkt.keep_alive, 300)
        try h.assert_eq[U32](pkt.session_expiry_interval as U32, 10) else h.fail("Expect session_expiry_interval to be 10 but got None") end
        try h.assert_eq[U16](pkt.receive_maximum as U16, 65535) else h.fail("Expect receive-maximum to be 65535 but got None") end
        try h.assert_eq[U32](pkt.maximum_packet_size as U32, 65535) else h.fail("Expect maximum-packet-size to be 65535 but got None") end
        try h.assert_eq[U16](pkt.topic_alias_maximum as U16, 65535) else h.fail("Expect topic-alias-maximum to be 65535 but got None") end
        h.assert_eq[Bool](pkt.request_response_information, true)
        h.assert_eq[Bool](pkt.request_problem_information, true)
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
        try h.assert_eq[String](pkt.authentication_method as String, "Plain") else h.fail("Expect authentication-method to be Plain but got None") end
        try h.assert_array_eq[U8](pkt.authentication_data as Array[U8], [8; 9; 0x0A; 0x0B]) else h.fail("Expect authentication-data to be [8, 9, A, B] but got None") end
        h.assert_eq[String](pkt.client_identifier, "client-id")
        try h.assert_eq[U32]((pkt.will_properties as MqttWillProperties).will_delay_interval as U32, 100) else h.fail("Expect will-delay-interval to be 100 but got None") end
        try h.assert_eq[U8]((pkt.will_properties as MqttWillProperties).payload_format_indicator(), MqttCharacterData()) else h.fail("Expect payload-format-indicator to be charactor-data but got None") end
        try h.assert_eq[U32]((pkt.will_properties as MqttWillProperties).message_expiry_interval as U32, 65535) else h.fail("Expect message-expiry-interval to be 65535 but got None") end
        try h.assert_eq[String]((pkt.will_properties as MqttWillProperties).content_type, "json") else h.fail("Expect content-type to be json but got None") end
        try h.assert_eq[String]((pkt.will_properties as MqttWillProperties).response_topic, "response-topic") else h.fail("Expect response-topic to be response-topic but got None") end
        try h.assert_array_eq[U8]((pkt.will_properties as MqttWillProperties).correlation_data as Array[U8], [0x0C; 0x0D; 0x0E; 0x0F]) else h.fail("Expect correlation-data to be [C, D, E, F] but got None") end
        try h.assert_eq[USize](((pkt.will_properties as MqttWillProperties).user_properties as Array[(String, String)]).size(), 3) else h.fail("Expect length of user-properties in will to be 3") end
        try
          let pair = ((pkt.will_properties as MqttWillProperties).user_properties as Array[(String, String)])(0) ?
          h.assert_eq[String](pair._1, "is-secret")
          h.assert_eq[String](pair._2, "true")
        else
          h.fail("Expect first item in user-properties in will to be (is-secret, true)")
        end
        try
          let pair = ((pkt.will_properties as MqttWillProperties).user_properties as Array[(String, String)])(1) ?
          h.assert_eq[String](pair._1, "tag")
          h.assert_eq[String](pair._2, "first-tag")
        else
          h.fail("Expect second item in user-properties in will to be (tag, first-tag)")
        end
        try
          let pair = ((pkt.will_properties as MqttWillProperties).user_properties as Array[(String, String)])(2) ?
          h.assert_eq[String](pair._1, "tag")
          h.assert_eq[String](pair._2, "second-tag")
        else
          h.fail("Expect third item in user-properties in will to be (tag, second-tag)")
        end
        try h.assert_eq[String](pkt.will_topic as String, "will-topic") else h.fail("Expect will-topic to be will-topic but got None") end
        try h.assert_array_eq[U8](pkt.will_payload as Array[U8], [4; 5; 6; 7]) else h.fail("Expect will-payload to be [4, 5, 6, 7] but got None") end
        try h.assert_eq[String](pkt.user_name as String, "user-name") else h.fail("Expect user-name to be user-name but got None") end
        try h.assert_array_eq[U8](pkt.password as Array[U8], [0; 1; 2; 3]) else h.fail("Expect password to be [0, 1, 2, 3] but got None") end
      else
        h.fail("Encoded packet is not CONNECT")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded CONNECT packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end
