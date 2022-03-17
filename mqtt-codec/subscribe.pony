use "buffered"
use "collections"

primitive MqttSendAtSubscribe
  """
  Send retained messages at the time of the subscribe.
  """
  fun apply(): U8 val =>
    0x0

primitive MqttSendAtSubscribeIfNotExist
  """
  Send retained messages at subscribe only if the subscription does not
  currently exist.
  """
  fun apply(): U8 val =>
    0x10

primitive MqttDoNotSendAtSubscribe
  """
  Do not send retained messages at the time of the subscribe.
  """
  fun apply(): U8 val =>
    0x20

type MqttRetainHandling is (MqttSendAtSubscribe | MqttSendAtSubscribeIfNotExist | MqttDoNotSendAtSubscribe)

class MqttSubscription
  let topic_filter: String val
  """
  It indicates the Topics to which the Client wants to subscribe

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let qos_level: MqttQoS val
  """
  This gives the maximum QoS level at which the Server can send Application
  Messages to the Client.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let no_local: Bool val
  """
  If the value is true, Application Messages MUST NOT be forwarded to a
  connection with a ClientID equal to the ClientID of the publishing connection.

  * mqtt-5
  """

  let retain_as_published: Bool val
  """
  If it is true, Application Messages forwarded using this subscription keep
  the RETAIN flag they were published with. If it is false, Application
  Messages forwarded using this subscription have the RETAIN flag set to false.
  Retained messages sent when the subscription is established have the RETAIN
  flag set to true.

  * mqtt-5
  """

  let retain_handling: (MqttRetainHandling val | None)
  """
  This option specifies whether retained messages are sent when the subscription
  is established. This does not affect the sending of retained messages at any
  point after the subscribe. If there are no retained messages matching the
  Topic Filter, all of these values act the same.

  * mqtt-5
  """

  new iso create(
      topic_filter': String val,
      qos_level': MqttQoS val,
      no_local': Bool val = false,
      retain_as_published': Bool val = false,
      retain_handling': (MqttRetainHandling val | None) = None
  ) =>
      topic_filter = topic_filter'
      qos_level = qos_level'
      no_local = no_local'
      retain_as_published = retain_as_published'
      retain_handling = retain_handling'

class MqttSubscribePacket
  let packet_identifier: U16 val
  """
  The Packet Identifier field.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let subscription_identifier: (ULong val | None)
  """
  The Subscription Identifier is a Variable Byte Integer representing the
  identifier of the subscription.

  * mqtt-5
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  User Properties on the SUBSCRIBE packet can be used to send subscription
  related properties from the Client to the Server.

  * mqtt-5
  """

  let subscriptions: Array[MqttSubscription val] val
  """
  This indicates the Topics to which the Client wants to subscribe.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  new iso create(
      packet_identifier': U16 val,
      subscriptions': Array[MqttSubscription val] val,
      subscription_identifier': (ULong val | None) = None,
      user_properties': (Map[String val, String val] val | None) = None
  ) =>
      packet_identifier = packet_identifier'
      subscriptions = subscriptions'
      subscription_identifier = subscription_identifier'
      user_properties = user_properties'

primitive MqttSubscribeDecoder
  fun apply(
    reader: Reader,
    header: U8 box,
    remaining: box->USize,
    version: MqttVersion box = MqttVersion5)
  : MqttDecodeResultType[MqttSubscribePacket val] val ? =>
    if \likely\ version() == MqttVersion5() then
      _decode_5(reader, header, remaining) ?
    else
      _decode_3x(reader, header, remaining) ?
    end

  fun _decode_5(
    reader: Reader,
    header: U8 box,
    remaining: box->USize)
  : MqttDecodeResultType[MqttSubscribePacket val] val ? =>

    var subscription_identifier: (ULong | None) = None
    var user_properties: (Map[String val, String val] iso | None) = None
    var consumed: USize = 0

    (let packet_identifier: U16, let consumed1: USize) = MqttTwoByteInteger.decode(reader) ?
    consumed = consumed + consumed1

    (let property_length', let consumed2: USize) = MqttVariableByteInteger.decode_reader(reader) ?
    consumed = consumed + consumed2
    let property_length = property_length'.usize()
    var decoded_length: USize = 0
    user_properties = recover iso Map[String val, String val] end
    while decoded_length < property_length do
      let identifier = reader.u8() ?
      decoded_length = decoded_length + 1
      match identifier
      | MqttSubscriptionIdentifier() =>
        (let subscription_identifier', let consumed3) = MqttSubscriptionIdentifier.decode(reader) ?
        subscription_identifier = subscription_identifier'
        decoded_length = decoded_length + consumed3
      | MqttUserProperty() =>
        (let user_property', let consumed3) = MqttUserProperty.decode(reader) ?
        try (user_properties as Map[String val, String val] iso).insert(user_property'._1, user_property'._2) end
        decoded_length = decoded_length + consumed3
      end
    end
    consumed = consumed + property_length

    var subscriptions: Array[MqttSubscription val] iso = recover iso Array[MqttSubscription val] end
    while consumed < remaining do
      (let topic_filter: String, let consumed4) = MqttUtf8String.decode(reader) ?
      consumed = consumed + consumed4
      let option = reader.u8() ?
      consumed = consumed + 1
      let qos_level = _MqttQoSDecoder(option << 1)
      subscriptions.push(MqttSubscription(topic_filter, qos_level))
    end

    let packet =
      MqttSubscribePacket(
        packet_identifier,
        consume subscriptions,
        subscription_identifier,
        consume user_properties
      )
    (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)

  fun _decode_3x(
    reader: Reader,
    header: U8 box,
    remaining: box->USize,
    version: MqttVersion box = MqttVersion5)
  : MqttDecodeResultType[MqttSubscribePacket val] val ? =>
    var consumed: USize = 0
    (let packet_identifier: U16, let consumed1: USize) = MqttTwoByteInteger.decode(reader) ?
    consumed = consumed + consumed1
    var subscription_identifier: (ULong | None) = None
    var subscriptions: Array[MqttSubscription val] iso = recover iso Array[MqttSubscription val] end
    while consumed < remaining do
      (let topic_filter: String, let consumed4) = MqttUtf8String.decode(reader) ?
      consumed = consumed + consumed4
      let option = reader.u8() ?
      consumed = consumed + 1
      let qos_level = _MqttQoSDecoder(option << 1)
      subscriptions.push(MqttSubscription(topic_filter, qos_level))
    end

    let packet =
      MqttSubscribePacket(
        packet_identifier,
        consume subscriptions
      )
    (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)

primitive MqttSubscribeMeasurer
  fun variable_header_size(data: MqttSubscribePacket box, version: MqttVersion box = MqttVersion5): USize val =>
    var size: USize = 0
    size = MqttTwoByteInteger.size(data.packet_identifier)
    if \likely\ version() == MqttVersion5() then
      let properties_length = properties_size(data)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(data: MqttSubscribePacket box): USize val =>
    var size: USize = 0
    size = size +
        match data.subscription_identifier
        | let subscription_identifier: ULong box =>
          MqttSubscriptionIdentifier.size(subscription_identifier)
        else
          0
        end

    match data.user_properties
    | let user_properties: Map[String val, String val] box =>
      for item in user_properties.pairs() do
        size = size + MqttUserProperty.size(item)
      end
    end

    size

  fun payload_size(data: MqttSubscribePacket box): USize val =>
    var size: USize = 0
    for subscription in data.subscriptions.values() do
      size = size + MqttUtf8String.size(subscription.topic_filter)
      size = size + 1 // option
    end
    size

primitive MqttSubscriptionEncoder
  fun apply(buf: Array[U8], data: MqttSubscription box, version: MqttVersion box = MqttVersion5): USize val =>
    var cnt: USize = MqttUtf8String.encode(buf, data.topic_filter)
    let option: U8 =
      if \likely\ version() == MqttVersion5() then
        (try (data.retain_handling as MqttRetainHandling)() else MqttSendAtSubscribe() end) or ((if data.retain_as_published then 0x08 else 0 end) or ((if data.no_local then 0x04 else 0 end) or (data.qos_level() >> 1)))
      else
        data.qos_level() >> 1
      end
    buf.push(option)
    cnt = cnt + 1
    cnt

primitive MqttSubscribeEncoder
  fun apply(data: MqttSubscribePacket box, version: MqttVersion box = MqttVersion5): Array[U8] val =>
    let size = (MqttSubscribeMeasurer.variable_header_size(data, version) + MqttSubscribeMeasurer.payload_size(data)).ulong()

    var buf = Array[U8](MqttVariableByteInteger.size(size) + size.usize() + 1)

    buf.push((MqttSubscribe() and 0xF2) or 0x02)
    MqttVariableByteInteger.encode(buf, size)
    MqttTwoByteInteger.encode(buf, data.packet_identifier)

    if \likely\ version() == MqttVersion5() then
      let properties_length: USize = MqttSubscribeMeasurer.properties_size(data)
      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.subscription_identifier
      | let subscription_identifier: ULong box =>
        MqttSubscriptionIdentifier.encode(buf, subscription_identifier)
      end

      match data.user_properties
      | let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          MqttUserProperty.encode(buf, item)
        end
      end
    end

    for item in data.subscriptions.values() do
      MqttSubscriptionEncoder(buf, item, version)
    end

    U8ArrayClone(buf)
