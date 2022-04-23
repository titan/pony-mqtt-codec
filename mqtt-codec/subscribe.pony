use "collections"

primitive MqttSendAtSubscribe
  """
  Send retained messages at the time of the subscribe.
  """
  fun apply(): U8 =>
    0x0

primitive MqttSendAtSubscribeIfNotExist
  """
  Send retained messages at subscribe only if the subscription does not
  currently exist.
  """
  fun apply(): U8 =>
    0x10

primitive MqttDoNotSendAtSubscribe
  """
  Do not send retained messages at the time of the subscribe.
  """
  fun apply(): U8 =>
    0x20

type MqttRetainHandling is
  ( MqttSendAtSubscribe
  | MqttSendAtSubscribeIfNotExist
  | MqttDoNotSendAtSubscribe
  )

type MqttSubscription is
  ( String val // 1. topic_filter
  , MqttQoS // 2. qos_level
  , Bool // 3. no_local
  , Bool // 4. retain_as_published
  , MqttRetainHandling // 5. retain_handling
  )

primitive MqttSubscriptionAccessor
  fun topic_filter(
    data: MqttSubscription)
  : String val =>
    """
    It indicates the Topics to which the Client wants to subscribe

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    data._1

  fun qos_level(
    data: MqttSubscription)
  : MqttQoS =>
    """
    This gives the maximum QoS level at which the Server can send Application
    Messages to the Client.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    data._2

  fun no_local(
    data: MqttSubscription)
  : Bool =>
    """
    If the value is true, Application Messages MUST NOT be forwarded to a
    connection with a ClientID equal to the ClientID of the publishing
    connection.

    * mqtt-5
    """
    data._3

  fun retain_as_published(
    data: MqttSubscription)
  : Bool =>
    """
    If it is true, Application Messages forwarded using this subscription keep
    the RETAIN flag they were published with. If it is false, Application
    Messages forwarded using this subscription have the RETAIN flag set to
    false. Retained messages sent when the subscription is established have the
    RETAIN flag set to true.

    * mqtt-5
    """
    data._4

  fun retain_handling(
    data: MqttSubscription)
  : MqttRetainHandling =>
    """
    This option specifies whether retained messages are sent when the
    subscription is established. This does not affect the sending of retained
    messages at any point after the subscribe. If there are no retained
    messages matching the Topic Filter, all of these values act the same.

    * mqtt-5
    """
    data._5

  fun build(
    topic_filter': String val,
    qos_level': MqttQoS = MqttQoS0,
    no_local': Bool = false,
    retain_as_published': Bool = false,
    retain_handling': MqttRetainHandling = MqttSendAtSubscribe)
  : MqttSubscription =>
    ( topic_filter'
    , qos_level'
    , no_local'
    , retain_as_published'
    , retain_handling'
    )

type MqttSubscribePacket is
  ( U16 // 1. packet_identifier
  , Array[MqttSubscription] val // 2. subscriptions
  , ULong // 3. subscription_identifier
  , (Array[MqttUserProperty] val | None) // 4. user_properties
  )

primitive MqttSubscribe
  """
  Subscribe request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0x80

  fun packet_identifier(
    packet: MqttSubscribePacket)
  : U16 =>
    """
    The Packet Identifier field.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun subscriptions(
    packet: MqttSubscribePacket)
  : Array[MqttSubscription] val =>
    """
    This indicates the Topics to which the Client wants to subscribe.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._2

  fun subscription_identifier(
    packet: MqttSubscribePacket)
  : ULong =>
    """
    The Subscription Identifier is a Variable Byte Integer representing the
    identifier of the subscription.

    * mqtt-5
    """
    packet._3

  fun user_properties(
    packet: MqttSubscribePacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    User Properties on the SUBSCRIBE packet can be used to send subscription
    related properties from the Client to the Server.

    * mqtt-5
    """
    packet._4

  fun build(
    packet_identifier': U16,
    subscriptions': Array[MqttSubscription] val,
    subscription_identifier': ULong = 0,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttSubscribePacket =>
    ( packet_identifier'
    , subscriptions'
    , subscription_identifier'
    , user_properties'
    )

primitive _MqttSubscribeDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttSubscribe(),
    version: MqttVersion = MqttVersion5)
  : MqttSubscribePacket? =>
    if \likely\ version == MqttVersion5 then
      _decode_5(buf, offset, limit, header)?
    else
      _decode_3x(buf, offset, limit, header)?
    end

  fun _decode_5(
    buf: Array[U8] val,
    offset: USize,
    limit: USize,
    header: U8)
  : MqttSubscribePacket? =>

    var offset' = offset
    var subscription_identifier: ULong = 0
    var user_properties: (Array[MqttUserProperty] iso | None) = None

    (let packet_identifier: U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + packet_identifier_size

    (let property_length', let property_length_size: USize) = _MqttVariableByteInteger.decode(buf, offset')?
    offset' = offset' + property_length_size
    let property_length = property_length'.usize()
    var decoded_length: USize = 0
    user_properties = recover iso Array[MqttUserProperty] end
    while decoded_length < property_length do
      let identifier = buf(offset' + decoded_length)?
      decoded_length = decoded_length + 1
      match identifier
      | _MqttSubscriptionIdentifier() =>
        (let subscription_identifier', let subscription_identifier_size) = _MqttSubscriptionIdentifier.decode(buf, offset' + decoded_length)?
        subscription_identifier = subscription_identifier'
        decoded_length = decoded_length + subscription_identifier_size
      | _MqttUserProperty() =>
        (let user_property, let user_property_size) = _MqttUserProperty.decode(buf, offset' + decoded_length)?
        try (user_properties as Array[MqttUserProperty] iso).push(consume user_property) end
        decoded_length = decoded_length + user_property_size
      end
    end
    offset' = offset' + decoded_length

    var subscriptions: Array[MqttSubscription] iso = recover iso Array[MqttSubscription] end
    while offset' < limit do
      (let topic_filter: String, let topic_filter_size: USize) = _MqttUtf8String.decode(buf, offset')?
      offset' = offset' + topic_filter_size
      let option = buf(offset')?
      offset' = offset' + 1
      let qos_level = _MqttQoSDecoder(option << 1)
      let retain_handling: MqttRetainHandling  =
        if (option and MqttSendAtSubscribe()) == MqttSendAtSubscribe() then
          MqttSendAtSubscribe
        elseif (option and MqttSendAtSubscribeIfNotExist()) == MqttSendAtSubscribeIfNotExist() then
          MqttSendAtSubscribeIfNotExist
        elseif (option and MqttDoNotSendAtSubscribe()) == MqttDoNotSendAtSubscribe() then
          MqttDoNotSendAtSubscribe
        else
          MqttSendAtSubscribe
        end
      let no_local = (option and 0x04) == 0x04
      let retain_as_published = (option and 0x08) == 0x08
      subscriptions.push(MqttSubscriptionAccessor.build(topic_filter, qos_level, no_local, retain_as_published, retain_handling))
    end

    MqttSubscribe.build(
      packet_identifier,
      consume subscriptions,
      subscription_identifier,
      consume user_properties
    )

  fun _decode_3x(
    buf: Array[U8] val,
    offset: USize,
    limit: USize,
    header: U8)
  : MqttSubscribePacket? =>
    var offset' = offset
    (let packet_identifier: U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + packet_identifier_size
    var subscription_identifier: ULong = 0
    var subscriptions: Array[MqttSubscription] iso = recover iso Array[MqttSubscription] end
    while offset' < limit do
      (let topic_filter: String, let topic_filter_size) = _MqttUtf8String.decode(buf, offset')?
      offset' = offset' + topic_filter_size
      let option = buf(offset')?
      offset' = offset' + 1
      let qos_level = _MqttQoSDecoder(option << 1)
      subscriptions.push(MqttSubscriptionAccessor.build(topic_filter, qos_level))
    end

    MqttSubscribe.build(
      packet_identifier,
      consume subscriptions
    )

primitive _MqttSubscribeMeasurer
  fun variable_header_size(
    packet: MqttSubscribePacket,
    version: MqttVersion = MqttVersion5)
  : USize =>
    var size: USize = 0
    size = _MqttTwoByteInteger.size(MqttSubscribe.packet_identifier(packet))
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttSubscribePacket)
  : USize =>
    var size: USize = 0
    match MqttSubscribe.subscription_identifier(packet)
    | let subscription_identifier: ULong if subscription_identifier != 0 =>
      size = size + _MqttSubscriptionIdentifier.size(subscription_identifier)
    end

    match MqttSubscribe.user_properties(packet)
    | let user_properties: Array[MqttUserProperty] val =>
      for property in user_properties.values() do
        size = size + _MqttUserProperty.size(property)
      end
    end

    size

  fun payload_size(
    packet: MqttSubscribePacket)
  : USize =>
    var size: USize = 0
    for subscription in MqttSubscribe.subscriptions(packet).values() do
      size = size + _MqttUtf8String.size(MqttSubscriptionAccessor.topic_filter(subscription))
      size = size + 1 // option
    end
    size

primitive _MqttSubscriptionEncoder
  fun apply(
    buf: Array[U8] iso,
    data: MqttSubscription,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    var buf' = _MqttUtf8String.encode(consume buf, MqttSubscriptionAccessor.topic_filter(data))
    let option: U8 =
      if \likely\ version == MqttVersion5 then
        MqttSubscriptionAccessor.retain_handling(data)() or
        (if MqttSubscriptionAccessor.retain_as_published(data) then 0x08 else 0 end) or
        (if MqttSubscriptionAccessor.no_local(data) then 0x04 else 0 end) or
        (MqttSubscriptionAccessor.qos_level(data)() >> 1)
      else
        MqttSubscriptionAccessor.qos_level(data)() >> 1
      end
    buf'.push(option)
    consume buf'

primitive _MqttSubscribeEncoder
  fun apply(
    packet: MqttSubscribePacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let size = (_MqttSubscribeMeasurer.variable_header_size(packet, version) + _MqttSubscribeMeasurer.payload_size(packet)).ulong()

    var buf = recover iso Array[U8](_MqttVariableByteInteger.size(size) + size.usize() + 1) end

    buf.push((MqttSubscribe() and 0xF2) or 0x02)
    buf = _MqttVariableByteInteger.encode(consume buf, size)
    buf = _MqttTwoByteInteger.encode(consume buf, MqttSubscribe.packet_identifier(packet))

    if \likely\ version == MqttVersion5 then
      let properties_length: USize = _MqttSubscribeMeasurer.properties_size(packet)
      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttSubscribe.subscription_identifier(packet)
      | let subscription_identifier: ULong if subscription_identifier != 0 =>
        buf = _MqttSubscriptionIdentifier.encode(consume buf, subscription_identifier)
      end

      match MqttSubscribe.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          buf = _MqttUserProperty.encode(consume buf, property)
        end
      end
    end

    for property in MqttSubscribe.subscriptions(packet).values() do
      buf = _MqttSubscriptionEncoder(consume buf, property, version)
    end

    consume buf
