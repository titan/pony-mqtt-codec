use "collections"

primitive _MqttDup
  fun decode(
    flag: U8)
  : Bool =>
    (flag and 0x08) == 0x08

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x08
    else
      0
    end

primitive _MqttRetain
  fun decode(
    flag: U8)
  : Bool =>
    (flag and 0x01) == 0x01

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x01
    else
      0
    end

type MqttPublishPacket is
  ( Bool // 1. dup_flag
  , MqttQoS // 2. qos_level
  , Bool // 3. retain
  , String val // 4. topic_name
  , U16 // 5. packet_identifier
  , MqttPayloadFormatIndicatorType // 6. payload_format_indicator
  , U32 // 7. message_expiry_interval
  , U16 // 8. topic_alias
  , (String val | None) // 9. response_topic
  , (Array[U8] val | None) // 10. correlation_data
  , (Array[MqttUserProperty] val | None) // 11. user_properties
  , ULong // 12. subscription_identifier
  , (String val | None) // 13. content_type
  , (Array[U8] val | None) // 14. payload
  )

primitive MqttPublish
  """
  Publish message

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x30

  fun dup_flag(
    pkt: MqttPublishPacket)
  : Bool =>
    """
    If the DUP flag is false, it indicates that this is the first occasion that
    the Client or Server has attempted to send this PUBLISH packet. If the DUP
    flag is set to true, it indicates that this might be re-delivery of an
    earlier attempt to send the packet.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    pkt._1

  fun qos_level(
    pkt: MqttPublishPacket)
  : MqttQoS =>
    """
    This field indicates the level of assurance for delivery of an Application
    Message.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    pkt._2

  fun retain(
    pkt: MqttPublishPacket)
  : Bool =>
    """
    If the RETAIN flag is set to true in a PUBLISH packet sent by a Client to a
    Server, the Server MUST replace any existing retained message for this topic
    and store the Application Message. If the RETAIN flag is false in a PUBLISH
    packet sent by a Client to a Server, the Server MUST NOT store the message as
    a retained message and MUST NOT remove or replace any existing retained
    message.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    pkt._3

  fun topic_name(
    pkt: MqttPublishPacket)
  : String val =>
    """
    The Topic Name identifies the information channel to which Payload data is
    published.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    pkt._4

  fun packet_identifier(
    pkt: MqttPublishPacket)
  : U16 =>
    """
    The Packet Identifier field is only present in PUBLISH packets where the QoS
    level is 1 or 2.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    pkt._5

  fun payload_format_indicator(
    pkt: MqttPublishPacket)
  : MqttPayloadFormatIndicatorType =>
    """
    It represents the Payload Format of Will Message, including unspecified bytes
    and UTF-8 Encoded Character MqttPublishHelper.(data)

    * mqtt-5
    """
    pkt._6

  fun message_expiry_interval(
    pkt: MqttPublishPacket)
  : U32 =>
    """
    It is the lifetime of the Application Message in seconds. If absent, the
    Application Message does not expire.

    * mqtt-5
    """
    pkt._7

  fun topic_alias(
    pkt: MqttPublishPacket)
  : U16 =>
    """
    A Topic Alias is an integer value that is used to identify the Topic instead
    of using the Topic Name. This reduces the size of the PUBLISH packet, and is
    useful when the Topic Names are long and the same Topic Names are used
    repetitively within a Network Connection.

    * mqtt-5
    """
    pkt._8

  fun response_topic(
    pkt: MqttPublishPacket)
  : (String val | None) =>
    """
    It is used as the Topic Name for a response message.

    * mqtt-5
    """
    pkt._9

  fun correlation_data(
    pkt: MqttPublishPacket)
  : (Array[U8] val | None) =>
    """
    The Correlation Data is used by the sender of the Request Message to identify
    which request the Response Message is for when it is received.

    * mqtt-5
    """
    pkt._10

  fun user_properties(
    pkt: MqttPublishPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    This property is intended to provide a means of transferring application
    layer name-value tags whose meaning and interpretation are known only by the
    application programs responsible for sending and receiving them.

    * mqtt-5
    """
    pkt._11

  fun subscription_identifier(
    pkt: MqttPublishPacket)
  : ULong =>
    """
    It represents the identifier of the subscription.

    * mqtt-5
    """
    pkt._12

  fun content_type(
    pkt: MqttPublishPacket)
  : (String val | None) =>
    """
    It describes the content of the Application Message.

    * mqtt-5
    """
    pkt._13

  fun payload(
    pkt: MqttPublishPacket)
  : (Array[U8] val | None) =>
    """
    The Payload contains the Application Message that is being published. The
    content and format of the data is application specific.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    pkt._14

  fun build(
    dup_flag': Bool = false,
    qos_level': MqttQoS = MqttQoS0,
    retain': Bool = false,
    topic_name': String val = "",
    packet_identifier': U16 = 0,
    payload_format_indicator': MqttPayloadFormatIndicatorType = MqttUnspecifiedBytes ,
    message_expiry_interval': U32 = 0,
    topic_alias': U16 = 0,
    response_topic': (String val | None) = None,
    correlation_data': (Array[U8] val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None,
    subscription_identifier': ULong = 0,
    content_type': (String val | None) = None,
    payload': (Array[U8] val | None) = None)
  : MqttPublishPacket =>
    ( dup_flag'
    , qos_level'
    , retain'
    , topic_name'
    , packet_identifier'
    , payload_format_indicator'
    , message_expiry_interval'
    , topic_alias'
    , response_topic'
    , correlation_data'
    , user_properties'
    , subscription_identifier'
    , content_type'
    , payload'
    )

primitive _MqttPublishDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttPublish(),
    version: MqttVersion = MqttVersion5)
  : MqttPublishPacket? =>
    var offset' = offset
    let dup_flag = _MqttDup.decode(header)
    let qos_level = _MqttQoSDecoder(header)
    let retain = _MqttRetain.decode(header)
    (let topic_name: String val, let topic_name_size: USize) = _MqttUtf8String.decode(buf, offset', limit)?
    offset' = offset' + topic_name_size
    var packet_identifier: U16 = 0
    match qos_level
    | MqttQoS1 =>
      (let packet_identifier': U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset', limit)?
      offset' = offset' + packet_identifier_size
      packet_identifier = packet_identifier'
    | MqttQoS2 =>
      (let packet_identifier': U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset', limit)?
      offset' = offset' + packet_identifier_size
      packet_identifier = packet_identifier'
    end
    var payload: (Array[U8] val | None) = None
    if \likely\ version == MqttVersion5 then
      (let property_length': ULong, let property_length_size: USize) = _MqttVariableByteInteger.decode(buf, offset', limit)?
      offset' = offset' + property_length_size
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      var payload_format_indicator: MqttPayloadFormatIndicatorType = MqttUnspecifiedBytes
      var message_expiry_interval: U32 = 0
      var topic_alias: U16 = 0
      var response_topic: (String | None) = None
      var correlation_data: (Array[U8] val | None) = None
      var user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty] end
      var subscription_identifier: ULong = 0
      var content_type: (String | None) = None
      while decoded_length < property_length do
        let identifier = buf(offset' + decoded_length)?
        decoded_length = decoded_length + 1
        match identifier
        | _MqttPayloadFormatIndicator() =>
          (let payload_format_indicator', let payload_format_indicator_size) = _MqttPayloadFormatIndicator.decode(buf, offset' + decoded_length, limit)?
          payload_format_indicator = payload_format_indicator'
          decoded_length = decoded_length + payload_format_indicator_size
        | _MqttMessageExpiryInterval() =>
          (let message_expiry_interval', let message_expiry_interval_size) = _MqttMessageExpiryInterval.decode(buf, offset' + decoded_length, limit)?
          message_expiry_interval = message_expiry_interval'
          decoded_length = decoded_length + message_expiry_interval_size
        | _MqttTopicAlias() =>
          (let topic_alias', let topic_alias_size) = _MqttTopicAlias.decode(buf, offset' + decoded_length, limit)?
          topic_alias = topic_alias'
          decoded_length = decoded_length + topic_alias_size
        | _MqttResponseTopic() =>
          (let response_topic', let response_topic_size) = _MqttResponseTopic.decode(buf, offset' + decoded_length, limit)?
          response_topic = consume response_topic'
          decoded_length = decoded_length + response_topic_size
        | _MqttCorrelationData() =>
          (let correlation_data', let correlation_data_size) = _MqttCorrelationData.decode(buf, offset' + decoded_length, limit)?
          correlation_data = consume correlation_data'
          decoded_length = decoded_length + correlation_data_size
        | _MqttUserProperty() =>
          (let user_property, let user_property_size) = _MqttUserProperty.decode(buf, offset' + decoded_length, limit)?
          user_properties.push(consume user_property)
          decoded_length = decoded_length + user_property_size
        | _MqttSubscriptionIdentifier() =>
          (let subscription_identifier', let subscription_identifier_size) = _MqttSubscriptionIdentifier.decode(buf, offset' + decoded_length, limit)?
          subscription_identifier = subscription_identifier'
          decoded_length = decoded_length + subscription_identifier_size
        | _MqttContentType() =>
          (let content_type': String iso, let content_type_size) = _MqttContentType.decode(buf, offset' + decoded_length, limit)?
          content_type = consume content_type'
          decoded_length = decoded_length + content_type_size
        end
      end
      offset' = offset' + decoded_length
      let payload_len = limit - offset'
      if payload_len > 0 then
        let payload': Array[U8] iso = recover iso Array[U8](payload_len) end
        payload'.copy_from(buf, offset', 0, payload_len)
        payload = consume payload'
      end

      MqttPublish.build(
        dup_flag,
        qos_level,
        retain,
        topic_name,
        packet_identifier,
        payload_format_indicator,
        message_expiry_interval,
        topic_alias,
        response_topic,
        correlation_data,
        consume user_properties,
        subscription_identifier,
        content_type,
        payload
      )
    else
      let payload_len = limit - offset'
      if payload_len > 0 then
        let payload': Array[U8] iso = recover iso Array[U8](payload_len) end
        payload'.copy_from(buf, offset', 0, payload_len)
        payload = consume payload'
      end
      MqttPublish.build(
        dup_flag,
        qos_level,
        retain,
        topic_name,
        packet_identifier
        where
        payload' = payload
      )
    end

primitive _MqttPublishMeasurer
  fun variable_header_size(
    packet: MqttPublishPacket,
    version: MqttVersion val = MqttVersion5)
  : USize =>
    var size: USize = _MqttUtf8String.size(MqttPublish.topic_name(packet))
    if MqttPublish.packet_identifier(packet) != 0 then
      match MqttPublish.qos_level(packet)
      | MqttQoS1 =>
        size = size + _MqttTwoByteInteger.size(MqttPublish.packet_identifier(packet))
      | MqttQoS2 =>
        size = size + _MqttTwoByteInteger.size(MqttPublish.packet_identifier(packet))
      end
    end
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttPublishPacket)
  : USize =>
    var size: USize = 0
    match MqttPublish.payload_format_indicator(packet)
    | let payload_format_indicator: MqttPayloadFormatIndicatorType =>
      size = size + _MqttPayloadFormatIndicator.size(payload_format_indicator)
    end
    match MqttPublish.message_expiry_interval(packet)
    | let message_expiry_interval: U32 if message_expiry_interval != 0 =>
      size = size + _MqttMessageExpiryInterval.size(message_expiry_interval)
    end
    match MqttPublish.topic_alias(packet)
    | let topic_alias: U16 if topic_alias != 0 =>
      size = size + _MqttTopicAlias.size(topic_alias)
    end
    match MqttPublish.response_topic(packet)
    | let response_topic: String val =>
      size = size + _MqttResponseTopic.size(response_topic)
    end
    match MqttPublish.correlation_data(packet)
    | let correlation_data: Array[U8] val =>
      size = size + _MqttCorrelationData.size(correlation_data)
    end

    match MqttPublish.user_properties(packet)
    | let user_properties: Array[MqttUserProperty] val =>
      for property in user_properties.values() do
        size = size + _MqttUserProperty.size(property)
      end
    end

    match MqttPublish.subscription_identifier(packet)
    | let subscription_identifier: ULong if subscription_identifier != 0 =>
      size = size + _MqttSubscriptionIdentifier.size(subscription_identifier)
    end
    match MqttPublish.content_type(packet)
    | let content_type: String val =>
      size = size + _MqttContentType.size(content_type)
    end

    size

  fun payload_size(
    packet: MqttPublishPacket)
  : USize =>
    var size: USize = 0
    match MqttPublish.payload(packet)
    | let payload: Array[U8] val =>
      size = size + payload.size()
    end
    size

primitive _MqttPublishEncoder
  fun apply(
    packet: MqttPublishPacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let remaining = (_MqttPublishMeasurer.variable_header_size(packet, version) + _MqttPublishMeasurer.payload_size(packet)).ulong()

    var buf = recover iso Array[U8](_MqttVariableByteInteger.size(remaining) + remaining.usize() + 1) end

    buf.push(MqttPublish() or (_MqttDup.encode(MqttPublish.dup_flag(packet)) or (_MqttQoSEncoder(MqttPublish.qos_level(packet)) or (_MqttRetain.encode(MqttPublish.retain(packet))))))
    buf = _MqttVariableByteInteger.encode(consume buf, remaining)

    buf = _MqttUtf8String.encode(consume buf, MqttPublish.topic_name(packet))

    if MqttPublish.packet_identifier(packet) != 0 then
      match MqttPublish.qos_level(packet)
      | MqttQoS1 =>
        buf = _MqttTwoByteInteger.encode(consume buf, MqttPublish.packet_identifier(packet))
      | MqttQoS2 =>
        buf = _MqttTwoByteInteger.encode(consume buf, MqttPublish.packet_identifier(packet))
      end
    end

    if \likely\ version == MqttVersion5 then
      let properties_length: USize = _MqttPublishMeasurer.properties_size(packet)
      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttPublish.payload_format_indicator(packet)
      | let payload_format_indicator: MqttPayloadFormatIndicatorType =>
        buf = _MqttPayloadFormatIndicator.encode(consume buf, payload_format_indicator)
      end

      match MqttPublish.message_expiry_interval(packet)
      | let message_expiry_interval: U32 if message_expiry_interval != 0 =>
        buf = _MqttMessageExpiryInterval.encode(consume buf, message_expiry_interval)
      end

      match MqttPublish.topic_alias(packet)
      | let topic_alias: U16 if topic_alias != 0 =>
        buf = _MqttTopicAlias.encode(consume buf, topic_alias)
      end

      match MqttPublish.response_topic(packet)
      | let response_topic: String val =>
        buf = _MqttResponseTopic.encode(consume buf, response_topic)
      end

      match MqttPublish.correlation_data(packet)
      | let correlation_data: Array[U8] val =>
        buf = _MqttCorrelationData.encode(consume buf, correlation_data)
      end

      match MqttPublish.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          buf = _MqttUserProperty.encode(consume buf, property)
        end
      end

      match MqttPublish.subscription_identifier(packet)
      | let subscription_identifier: ULong if subscription_identifier != 0 =>
        buf = _MqttSubscriptionIdentifier.encode(consume buf, subscription_identifier)
      end

      match MqttPublish.content_type(packet)
      | let content_type: String val =>
        buf = _MqttContentType.encode(consume buf, content_type)
      end
    end

    match MqttPublish.payload(packet)
    | let payload: Array[U8] val =>
      buf.copy_from(payload, 0, buf.size(), payload.size())
    end

    consume buf
