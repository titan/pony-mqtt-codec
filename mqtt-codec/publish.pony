use "buffered"
use "collections"

primitive _MqttDup
  fun decode(flag: U8 box): Bool val =>
    (flag and 0x08) == 0x08

  fun encode(data: Bool box): U8 val =>
    if data then
      0x08
    else
      0
    end

primitive _MqttRetain
  fun decode(flag: U8 box): Bool val =>
    (flag and 0x01) == 0x01

  fun encode(data: Bool box): U8 val =>
    if data then
      0x01
    else
      0
    end

class MqttPublishPacket
  let dup_flag: Bool val
  """
  If the DUP flag is false, it indicates that this is the first occasion that
  the Client or Server has attempted to send this PUBLISH packet. If the DUP
  flag is set to true, it indicates that this might be re-delivery of an
  earlier attempt to send the packet.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let qos_level: MqttQoS val
  """
  This field indicates the level of assurance for delivery of an Application
  Message.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let retain: Bool val
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

  let topic_name: String val
  """
  The Topic Name identifies the information channel to which Payload data is
  published.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let packet_identifier: (U16 val | None)
  """
  The Packet Identifier field is only present in PUBLISH packets where the QoS
  level is 1 or 2.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let payload_format_indicator: (MqttPayloadFormatIndicatorType val | None)
  """
  It represents the Payload Format of Will Message, including unspecified bytes
  and UTF-8 Encoded Character Data.

  * mqtt-5
  """

  let message_expiry_interval: (U32 val | None)
  """
  It is the lifetime of the Application Message in seconds. If absent, the
  Application Message does not expire.

  * mqtt-5
  """

  let topic_alias: (U16 val | None)
  """
  A Topic Alias is an integer value that is used to identify the Topic instead
  of using the Topic Name. This reduces the size of the PUBLISH packet, and is
  useful when the Topic Names are long and the same Topic Names are used
  repetitively within a Network Connection.

  * mqtt-5
  """

  let response_topic: (String val | None)
  """
  It is used as the Topic Name for a response message.

  * mqtt-5
  """

  let correlation_data: (Array[U8 val] val | None)
  """
  The Correlation Data is used by the sender of the Request Message to identify
  which request the Response Message is for when it is received.

  * mqtt-5
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  This property is intended to provide a means of transferring application
  layer name-value tags whose meaning and interpretation are known only by the
  application programs responsible for sending and receiving them.

  * mqtt-5
  """

  let subscription_identifier: (ULong val | None)
  """
  It represents the identifier of the subscription.

  * mqtt-5
  """

  let content_type: (String val | None)
  """
  It describes the content of the Application Message.

  * mqtt-5
  """

  let payload: (Array[U8 val] val | None)
  """
  The Payload contains the Application Message that is being published. The
  content and format of the data is application specific.

  * mqtt-5
  """

  new iso create(
    dup_flag': Bool val,
    qos_level': MqttQoS val,
    retain': Bool val,
    topic_name': String val,
    packet_identifier': (U16 val | None) = None,
    payload_format_indicator': (MqttPayloadFormatIndicatorType val | None) = None,
    message_expiry_interval': (U32 val | None) = None,
    topic_alias': (U16 val | None) = None,
    response_topic': (String val | None) = None,
    correlation_data': (Array[U8 val] val | None) = None,
    user_properties': (Map[String val, String val] val | None) = None,
    subscription_identifier': (ULong val | None) = None,
    content_type': (String val | None) = None,
    payload': (Array[U8 val] val | None) = None
  ) =>
  dup_flag = dup_flag'
  qos_level = qos_level'
  retain = retain'
  topic_name = topic_name'
  packet_identifier = packet_identifier'
  payload_format_indicator = payload_format_indicator'
  message_expiry_interval = message_expiry_interval'
  topic_alias = topic_alias'
  response_topic = response_topic'
  correlation_data = correlation_data'
  user_properties = user_properties'
  subscription_identifier = subscription_identifier'
  content_type = content_type'
  payload = payload'

primitive MqttPublishDecoder
  fun apply(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttPublishPacket val] val ? =>
    let dup_flag = _MqttDup.decode(header)
    let qos_level = _MqttQoSDecoder(header)
    let retain = _MqttRetain.decode(header)
    var consumed: USize val = 0
    (let topic_name: String val, let consumed1: USize val) = MqttUtf8String.decode(reader) ?
    consumed = consumed + consumed1
    var packet_identifier: (U16 val | None) = None
    match qos_level
    | MqttQoS1 =>
      (let packet_identifier': U16 val, let consumed2: USize val) = MqttTwoByteInteger.decode(reader) ?
      packet_identifier = packet_identifier'
      consumed = consumed + consumed2
    | MqttQoS2 =>
      (let packet_identifier': U16 val, let consumed2: USize val) = MqttTwoByteInteger.decode(reader) ?
      packet_identifier = packet_identifier'
      consumed = consumed + consumed2
    end
    var payload: (Array[U8 val] iso | None) = None
    if \likely\ version() == MqttVersion5() then
      (let property_length': ULong val, let consumed3: USize val) = MqttVariableByteInteger.decode_reader(reader) ?
      consumed = consumed + consumed3
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      var payload_format_indicator: (MqttPayloadFormatIndicatorType val | None) = None
      var message_expiry_interval: (U32 | None) = None
      var topic_alias: (U16 | None) = None
      var response_topic: (String | None) = None
      var correlation_data: (Array[U8 val] val | None) = None
      var user_properties: Map[String val, String val] iso = recover iso Map[String val, String val] end
      var subscription_identifier: (ULong | None) = None
      var content_type: (String | None) = None
      while decoded_length < property_length do
        let identifier = reader.u8() ?
        decoded_length = decoded_length + 1
        match identifier
        | MqttPayloadFormatIndicator() =>
          (let payload_format_indicator', let property_consumed) = MqttPayloadFormatIndicator.decode(reader) ?
          payload_format_indicator = payload_format_indicator'
          decoded_length = decoded_length + property_consumed
        | MqttMessageExpiryInterval() =>
          (let message_expiry_interval', let property_consumed) = MqttMessageExpiryInterval.decode(reader) ?
          message_expiry_interval = message_expiry_interval'
          decoded_length = decoded_length + property_consumed
        | MqttTopicAlias() =>
          (let topic_alias', let property_consumed) = MqttTopicAlias.decode(reader) ?
          topic_alias = topic_alias'
          decoded_length = decoded_length + property_consumed
        | MqttResponseTopic() =>
          (let response_topic', let property_consumed) = MqttResponseTopic.decode(reader) ?
          response_topic = response_topic'
          decoded_length = decoded_length + property_consumed
        | MqttCorrelationData() =>
          (let correlation_data', let property_consumed) = MqttCorrelationData.decode(reader) ?
          correlation_data = correlation_data'
          decoded_length = decoded_length + property_consumed
        | MqttUserProperty() =>
          (let user_property', let property_consumed) = MqttUserProperty.decode(reader) ?
          user_properties.insert(user_property'._1, user_property'._2)
          decoded_length = decoded_length + property_consumed
        | MqttSubscriptionIdentifier() =>
          (let subscription_identifier', let property_consumed) = MqttSubscriptionIdentifier.decode(reader) ?
          subscription_identifier = subscription_identifier'
          decoded_length = decoded_length + property_consumed
        | MqttContentType() =>
          (let content_type', let property_consumed) = MqttContentType.decode(reader) ?
          content_type = content_type'
          decoded_length = decoded_length + property_consumed
        end
      end
      let payload_length = remaining - consumed - property_length
      if payload_length > 0 then
        payload = reader.block(payload_length) ?
      end

      let packet =
        MqttPublishPacket(
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
          consume payload
        )
      (MqttDecodeDone, packet)
    else
      let payload_length = remaining - consumed
      if payload_length > 0 then
        payload = reader.block(payload_length) ?
      end
      let packet =
        MqttPublishPacket(
          dup_flag,
          qos_level,
          retain,
          topic_name,
          packet_identifier
          where
          payload' = consume payload
        )
      (MqttDecodeDone, packet)
    end

primitive MqttPublishMeasurer
  fun variable_header_size(data: MqttPublishPacket box, version: MqttVersion box = MqttVersion5): USize val =>
    var size: USize = MqttUtf8String.size(data.topic_name)
    match data.packet_identifier
    | let packet_identifier': U16 box =>
      match data.qos_level
      | MqttQoS1 =>
        size = size + MqttTwoByteInteger.size(packet_identifier')
      | MqttQoS2 =>
        size = size + MqttTwoByteInteger.size(packet_identifier')
      end
    end
    if \likely\ version() == MqttVersion5() then
      let properties_length = properties_size(data)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(data: MqttPublishPacket box): USize val =>
    var size: USize val = 0
    size = size +
        match data.payload_format_indicator
        | let payload_format_indicator: MqttPayloadFormatIndicatorType box =>
          MqttPayloadFormatIndicator.size(payload_format_indicator)
        else
          0
        end
    size = size +
        match data.message_expiry_interval
        | let message_expiry_interval: U32 box =>
          MqttMessageExpiryInterval.size(message_expiry_interval)
        else
          0
        end
    size = size +
        match data.topic_alias
        | let topic_alias: U16 box =>
          MqttTopicAlias.size(topic_alias)
        else
          0
        end
    size = size +
        match data.response_topic
        | let response_topic: String box =>
          MqttResponseTopic.size(response_topic)
        else
          0
        end
    size = size +
        match data.correlation_data
        | let correlation_data: Array[U8 val] box =>
          MqttCorrelationData.size(correlation_data)
        else
          0
        end

    match data.user_properties
    | let user_properties: Map[String val, String val] box =>
      for item in user_properties.pairs() do
        size = size + MqttUserProperty.size(item)
      end
    end

    size = size +
        match data.subscription_identifier
        | let subscription_identifier: ULong box =>
          MqttSubscriptionIdentifier.size(subscription_identifier)
        else
          0
        end
    size = size +
        match data.content_type
        | let content_type: String box =>
          MqttContentType.size(content_type)
        else
          0
        end

    size

  fun payload_size(data: MqttPublishPacket box): USize val =>
    var size: USize = 0
    match data.payload
    | let payload: Array[U8] box =>
      size = size + payload.size()
    end
    size

primitive MqttPublishEncoder
  fun apply(data: MqttPublishPacket box, version: MqttVersion box = MqttVersion5): Array[U8] val =>
    let remaining = (MqttPublishMeasurer.variable_header_size(data, version) + MqttPublishMeasurer.payload_size(data)).ulong()

    var buf' = recover iso Array[U8](MqttVariableByteInteger.size(remaining) + remaining.usize() + 1) end
    var buf: Array[U8] trn^ = consume buf'

    buf.push(MqttPublish() or (_MqttDup.encode(data.dup_flag) or (_MqttQoSEncoder(data.qos_level) or (_MqttRetain.encode(data.retain)))))
    MqttVariableByteInteger.encode(buf, remaining)

    MqttUtf8String.encode(buf, data.topic_name)

    match data.packet_identifier
    | let packet_identifier: U16 box =>
      match data.qos_level
      | MqttQoS1 =>
        MqttTwoByteInteger.encode(buf, packet_identifier)
      | MqttQoS2 =>
        MqttTwoByteInteger.encode(buf, packet_identifier)
      end
    end

    if \likely\ version() == MqttVersion5() then
      let properties_length: USize = MqttPublishMeasurer.properties_size(data)
      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.payload_format_indicator
      | let payload_format_indicator: MqttPayloadFormatIndicatorType =>
        MqttPayloadFormatIndicator.encode(buf, payload_format_indicator)
      end

      match data.message_expiry_interval
      | let message_expiry_interval: U32 box =>
        MqttMessageExpiryInterval.encode(buf, message_expiry_interval)
      end

      match data.topic_alias
      | let topic_alias: U16 box =>
        MqttTopicAlias.encode(buf, topic_alias)
      end

      match data.response_topic
      | let response_topic: String box =>
        MqttResponseTopic.encode(buf, response_topic)
      end

      match data.correlation_data
      | let correlation_data: Array[U8 val] box =>
        MqttCorrelationData.encode(buf, correlation_data)
      end

      match data.user_properties
      | let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
           MqttUserProperty.encode(buf, item)
        end
      end

      match data.subscription_identifier
      | let subscription_identifier: ULong box =>
        MqttSubscriptionIdentifier.encode(buf, subscription_identifier)
      end

      match data.content_type
      | let content_type: String box =>
        MqttContentType.encode(buf, content_type)
      end
    end

    match data.payload
    | let payload: Array[U8] box =>
      buf.copy_from(payload, 0, buf.size(), payload.size())
    end

    buf
