use "ponytest"
use "buffered"
use "collections"

class _TestDisconnect is UnitTest
  fun name(): String => "DISCONNECT"

  fun apply(h: TestHelper) ? =>
    _test_mqtt311(h) ?
    _test_mqtt5(h) ?
    _test_mqtt5_too_large(h) ?
    _test_mqtt5_empty(h) ?

  fun _test_mqtt311(h: TestHelper) ? =>
    let origin = MqttDisconnectPacket(
    )

    let buf = MqttDisconnect.encode(origin, None, MqttVersion311)
    match MqttDecoder(buf, MqttVersion311) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttDisconnectPacket =>
        None
      else
        h.fail("Encoded packet is not DISCONNECT")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttDisconnect.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttDisconnectPacket =>
        try h.assert_eq[U8]((pkt.reason_code as MqttDisconnectReasonCode)(), MqttNormalDisconnection()) else h.fail("Expect reason-code to be MqttNormalDisconnection but got None") end
        try h.assert_eq[U32]((pkt.session_expiry_interval as U32), 65535) else h.fail("Expect session-expiry-interval to be 65535 but got None") end
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 2) else h.fail("Expect 2 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("hello")?, "world") else h.fail("Expect hello in user-properties to be world") end
        try h.assert_eq[String]((pkt.server_reference as String), "Unknown") else h.fail("Expect server-reference to be Unknown but got None") end
      else
        h.fail("Encoded packet is not DISCONNECT")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_too_large(h: TestHelper) ? =>
    let origin = _mqtt5_packet()

    let buf = MqttDisconnect.encode(origin, 45)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttDisconnectPacket =>
        try h.assert_eq[U8]((pkt.reason_code as MqttDisconnectReasonCode)(), MqttNormalDisconnection()) else h.fail("Expect reason-code to be MqttNormalDisconnection but got None") end
        try h.assert_eq[U32]((pkt.session_expiry_interval as U32), 65535) else h.fail("Expect session-expiry-interval to be 65535 but got None") end
        try h.assert_eq[String]((pkt.reason_string as String), "Unknown") else h.fail("Expect reason-string to be Unknown but got None") end
        try h.assert_eq[USize]((pkt.user_properties as Map[String, String]).size(), 1) else h.fail("Expect 1 items in user-properties") end
        try h.assert_eq[String]((pkt.user_properties as Map[String, String])("foo")?, "bar") else h.fail("Expect foo in user-properties to be bar") end
        try h.assert_eq[String]((pkt.server_reference as String), "Unknown") else h.fail("Expect server-reference to be Unknown but got None") end
      else
        h.fail("Encoded packet is not DISCONNECT")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _test_mqtt5_empty(h: TestHelper) ? =>
    let origin =
      MqttDisconnectPacket(
        where
        reason_code' = MqttNormalDisconnection
      )

    let buf = MqttDisconnect.encode(origin)
    match MqttDecoder(buf) ?
    | (MqttDecodeDone, let packet: MqttControlPacketType) =>
      match packet
      | let pkt: MqttDisconnectPacket =>
        try h.assert_eq[U8]((pkt.reason_code as MqttDisconnectReasonCode)(), MqttNormalDisconnection()) else h.fail("Expect reason-code to be MqttNormalDisconnection but got None") end
      else
        h.fail("Encoded packet is not DISCONNECT")
      end
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded DISCONNECT packet is not completed")
    | (MqttDecodeError, let err: String) =>
      h.fail(err)
    end

  fun _mqtt5_packet(): MqttDisconnectPacket =>
    let user_properties: Map[String, String] = Map[String, String]()
    user_properties("foo") = "bar"
    user_properties("hello") = "world"
    MqttDisconnectPacket(
      where
      reason_code' = MqttNormalDisconnection,
      session_expiry_interval' = 65535,
      reason_string' = "Unknown",
      user_properties' = user_properties,
      server_reference' = "Unknown"
    )
