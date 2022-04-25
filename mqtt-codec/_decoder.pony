use "pony_test"
use "collections"

class _TestDecoder is UnitTest
  fun name(): String => "Decoder"

  fun apply(h: TestHelper)? =>
    _test_empty(h)?
    _test_combined(h)?

  fun _test_empty(h: TestHelper)? =>
    match MqttDecoder(recover iso Array[U8 val] end)?
    | (MqttDecodeDone, let packet: MqttControlType, _) =>
      h.fail("Expect MqttDecodeContinue but got MqttDecodeDone")
    | (MqttDecodeError, let err: String val) =>
      h.fail("Expect MqttDecodeContinue but got MqttDecodeError" + err)
    end

  fun _test_combined(h: TestHelper)? =>
    let pkt1 =
      MqttPublish.build(
        where
        dup_flag' = true,
        qos_level' = MqttQoS1,
        packet_identifier' = 1,
        retain' = true,
        topic_name' = "",
        payload' = [0; 1; 2; 3]
      )
    let data1 = MqttEncoder.publish(pkt1, MqttVersion311)
    let pkt2 =
      MqttPubAck.build(
        where
        packet_identifier' = 65535
      )
    let data2 = MqttEncoder.puback(pkt2, 0, MqttVersion311)
    let combined': Array[U8] iso = recover iso Array[U8](data1.size() + data2.size()) end
    let combined: Array[U8] iso = (consume combined').>append(consume data1).>append(consume data2)
    match MqttDecoder(consume combined, MqttVersion311)?
    | (MqttDecodeDone, (MqttPublish, let publishpkt: MqttPublishPacket), let remained: (Array[U8] iso^ | None)) =>
      h.assert_eq[Bool](MqttPublish.dup_flag(publishpkt), true)
      h.assert_eq[MqttQoS val](MqttPublish.qos_level(publishpkt), MqttQoS1)
      h.assert_eq[U16](MqttPublish.packet_identifier(publishpkt), 1)
      h.assert_eq[Bool](MqttPublish.retain(publishpkt), true)
      h.assert_eq[String val](MqttPublish.topic_name(publishpkt), "")
      try h.assert_array_eq[U8](MqttPublish.payload(publishpkt) as Array[U8] val, [0; 1; 2; 3]) else h.fail("Expect payload of PUBLISH to be [0, 1, 2, 3] but got None") end
      match remained
      | let remained': Array[U8] iso^ =>
        match MqttDecoder(remained', MqttVersion311)?
        | (MqttDecodeDone, (MqttPubAck, let pubackpkt: MqttPubAckPacket), _) =>
          h.assert_eq[U16](MqttPubAck.packet_identifier(pubackpkt), 65535)
        | (MqttDecodeDone, _, _) =>
          h.fail("Encoded packet is not PUBACK")
        | (MqttDecodeContinue, _) =>
          h.fail("Encoded PUBACK packet is not completed")
        | (MqttDecodeError, let err: String val) =>
          h.fail(err)
        end
      else
        h.fail("Expect to continue to decode data for PUBACK but got None")
      end
    | (MqttDecodeDone, _, _) =>
      h.fail("Encoded packet is not PUBLISH")
    | (MqttDecodeContinue, _) =>
      h.fail("Encoded PUBLISH packet is not completed")
    | (MqttDecodeError, let err: String val) =>
      h.fail(err)
    end
