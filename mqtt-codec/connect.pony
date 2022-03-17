use "buffered"
use "collections"

primitive MqttCleanStart
  fun decode(flags: U8 box): Bool val =>
    (flags and 0x02) != 0

  fun encode(data: Bool box): U8 val =>
    if data then
      0x02
    else
      0
    end

primitive MqttWillFlag
  fun decode(flags: U8 box): Bool val =>
    (flags and 0x04) != 0

  fun encode(data: Bool box): U8 val =>
    if data then
      0x04
    else
      0
    end

primitive MqttWillQos
  fun decode(flags: U8 box): MqttQoS val =>
    _MqttQoSDecoder((flags and 0x18) >> 3)

  fun encode(data: MqttQoS box): U8 val =>
    let qos = _MqttQoSEncoder(data)
    qos << 3

primitive MqttWillRetain
  fun decode(flags: U8): Bool val =>
    (flags and 0x20) != 0

  fun encode(data: Bool): U8 val =>
    if data then
      0x20
    else
      0
    end

primitive MqttPasswordFlag
  fun decode(flags: U8 box): Bool val =>
    (flags and 0x40) != 0

  fun encode(data: Bool box): U8 val =>
    if data then
      0x40
    else
      0
    end

primitive MqttUserNameFlag
  fun decode(flags: U8 box): Bool val =>
    (flags and 0x80) != 0

  fun encode(data: Bool box): U8 val =>
    if data then
      0x80
    else
      0
    end

class MqttWillProperties
  let will_delay_interval: (U32 val | None)
  """
  It represents the Will Delay Interval in seconds.

  * mqtt-5
  """

  let payload_format_indicator: MqttPayloadFormatIndicatorType
  """
  It represents the Payload Format of Will Message, including unspecified bytes
  and UTF-8 Encoded Character Data.

  * mqtt-5
  """

  let message_expiry_interval: (U32 val | None)
  """
  It is the lifetime of the Will Message in seconds and is sent as the
  Publication Expiry Interval when the Server publishes the Will Message.

  * mqtt-5
  """

  let content_type: String val
  """
  It describes the content of the Will Message. The value of the Content Type
  is defined by the sending and receiving application.

  * mqtt-5
  """

  let response_topic: String val
  """
  It is used as the Topic Name for a response message.

  * mqtt-5
  """

  let correlation_data: (Array[U8 val] val| None)
  """
  The Correlation Data is used by the sender of the Request Message to identify
  which request the Response Message is for when it is received.

  * mqtt-5
  """

  let user_properties: (Array[(String val, String val)] val | None)
  """
  This property is intended to provide a means of transferring application
  layer name-value tags whose meaning and interpretation are known only by the
  application programs responsible for sending and receiving them.

  * mqtt-5
  """

  new iso create(
    will_delay_interval': (U32 val | None) = None,
    payload_format_indicator': MqttPayloadFormatIndicatorType val,
    message_expiry_interval': (U32 val | None) = None,
    content_type': String val,
    response_topic': String val,
    correlation_data': (Array[U8 val] val | None) = None,
    user_properties': (Array[(String val, String val)] val | None) = None
  ) =>
    will_delay_interval = will_delay_interval'
    payload_format_indicator = payload_format_indicator'
    message_expiry_interval = message_expiry_interval'
    content_type = content_type'
    response_topic = response_topic'
    correlation_data = correlation_data'
    user_properties = user_properties'

class MqttConnectPacket
  let protocol_name: String val
  """
  A Server which support multiple protocols uses the Protocol Name to determine
  whether the data is MQTT.

  * mqtt-3
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let protocol_version: MqttVersion val
  """
  This represents the revision level of the protocol used by the Client.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let clean_start: Bool val
  """
  This specifies whether the Connection starts a new Session or is a
  continuation of an existing Session.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let will_qos: MqttQoS val
  """
  This specifies the QoS level to be used when publishing the Will Message.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let will_retain: Bool val
  """
  This specifies if the Will Message is to be retained when it is published.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let keep_alive: U16 val
  """
  It is the maximum time interval measured in seconds that is permitted to
  elapse between the point at which the Client finishes transmitting one MQTT
  Control Packet and the point it starts sending the next.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let session_expiry_interval: (U32 val | None)
  """
  It represents the Session Expiry Interval in seconds.

  * mqtt-5
  """

  let receive_maximum: (U16 val | None)
  """
  It represents the Receive Maximum value. The Client uses this value to limit
  the number of QoS 1 and QoS 2 publications that it is willing to process
  concurrently. There is no mechanism to limit the QoS 0 publications that the
  Server might try to send.

  * mqtt-5
  """

  let maximum_packet_size: (U32 val | None)
  """
  It represents the Maximum Packet Size the Client is willing to accept.

  * mqtt-5
  """

  let topic_alias_maximum: (U16 val | None)
  """
  It represents the Topic Alias Maximum value. This value indicates the highest
  value that the Client will accept as a Topic Alias sent by the Server. The
  Client uses this value to limit the number of Topic Aliases that it is
  willing to hold on this Connection.

  * mqtt-5
  """

  let request_response_information: Bool val
  """
  The Client uses this value to request the Server to return Response
  Information in the CONNACK.

  * mqtt-5
  """

  let request_problem_information: Bool val
  """
  The Client uses this value to indicate whether the Reason String or User
  Properties are sent in the case of failures.

  * mqtt-5
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  User Properties on the CONNECT packet can be used to send connection related
  properties from the Client to the Server.

  * mqtt-5
  """

  let authentication_method: (String val | None)
  """
  It contains the name of the authentication method used for extended
  authentication.

  * mqtt-5
  """

  let authentication_data: (Array[U8 val] val | None)
  """
  It contains authentication data. The contents of this data are defined by the
  authentication method.

  * mqtt-5
  """

  let client_identifier: String val
  """
  The Client Identifier (ClientID) identifies the Client to the Server.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let will_properties: (MqttWillProperties val | None)
  """
  The Will Properties field defines the Application Message properties to be
  sent with the Will Message when it is published, and properties which define
  when to publish the Will Message.

  * mqtt-5
  """

  let will_topic: (String val | None)
  """
  It represents the topic of the Will Message.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let will_payload: (Array[U8 val] val | None)
  """
  The Will Payload defines the Application Message Payload that is to be
  published to the Will Topic.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let user_name: (String val | None)
  """
  It can be used by the Server for authentication and authorization.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let password: (Array[U8 val] val| None)
  """
  It can be used by the Server for authentication and authorization.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  new iso create(
    protocol_name': String val,
    protocol_version': MqttVersion val = MqttVersion5,
    clean_start': Bool val = false,
    will_qos': MqttQoS val = MqttQoS0,
    will_retain': Bool val = false,
    keep_alive': U16 val,
    session_expiry_interval': (U32 val | None) = None,
    receive_maximum': (U16 val | None) = None,
    maximum_packet_size': (U32 val | None) = None,
    topic_alias_maximum': (U16 val | None) = None,
    request_response_information': Bool val = false,
    request_problem_information': Bool val = false,
    user_properties': (Map[String val, String val] val | None) = None,
    authentication_method': (String val | None) = None,
    authentication_data': (Array[U8 val] val | None) = None,
    client_identifier': String val,
    will_properties': (MqttWillProperties val | None) = None,
    will_topic': (String val | None) = None,
    will_payload': (Array[U8 val] val | None) = None,
    user_name': (String val | None) = None,
    password': (Array[U8 val] val | None) = None
  ) =>
    protocol_name = protocol_name'
    protocol_version = protocol_version'
    clean_start = clean_start'
    will_qos = will_qos'
    will_retain = will_retain'
    keep_alive = keep_alive'
    session_expiry_interval = session_expiry_interval'
    receive_maximum = receive_maximum'
    maximum_packet_size = maximum_packet_size'
    topic_alias_maximum = topic_alias_maximum'
    request_response_information = request_response_information'
    request_problem_information = request_problem_information'
    user_properties = user_properties'
    authentication_method = authentication_method'
    authentication_data = authentication_data'
    client_identifier = client_identifier'
    will_properties = will_properties'
    will_topic = will_topic'
    will_payload = will_payload'
    user_name = user_name'
    password = password'

primitive MqttConnectDecoder
  fun apply(reader: Reader, header: U8 box, remaining: USize box): MqttDecodeResultType[MqttConnectPacket val] val ? =>
    (let protocol_name, _) = MqttUtf8String.decode(reader) ?
    let protocol_version =
      match reader.u8() ?
      | MqttVersion311() => MqttVersion311
      | MqttVersion31() => MqttVersion31
      else
        MqttVersion5
      end
    let flags = reader.u8() ?
    let clean_start = MqttCleanStart.decode(flags)
    let will_flag = MqttWillFlag.decode(flags)
    let will_qos = MqttWillQos.decode(flags)
    let will_retain = MqttWillRetain.decode(flags)
    let password_flag = MqttPasswordFlag.decode(flags)
    let user_name_flag = MqttUserNameFlag.decode(flags)
    (let keep_alive, _) = MqttTwoByteInteger.decode(reader) ?
    var session_expiry_interval: (U32 val | None) = None
    var receive_maximum: (U16 val | None) = None
    var maximum_packet_size: (U32 val | None) = None
    var topic_alias_maximum: (U16 val | None) = None
    var request_response_information: Bool val = false
    var request_problem_information: Bool val = false
    var user_properties: (Map[String val, String val] iso | None) = None
    var authentication_method: (String val | None) = None
    var authentication_data: (Array[U8 val] val | None) = None
    var will_properties: (MqttWillProperties val | None) = None
    var will_topic: (String val | None) = None
    var will_payload: (Array[U8 val] val | None) = None
    var user_name: (String val | None) = None
    var password: (Array[U8 val] val | None) = None
    if \likely\ protocol_version() == MqttVersion5() then
      (let property_length', _) = MqttVariableByteInteger.decode_reader(reader) ?
      user_properties = recover iso Map[String val, String val] end
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      while decoded_length < property_length do
        let identifier = reader.u8() ?
        decoded_length = decoded_length + 1
        match identifier
        | MqttSessionExpiryInterval() =>
          (let session_expiry_interval', let consumed) = MqttSessionExpiryInterval.decode(reader) ?
          session_expiry_interval = session_expiry_interval'
          decoded_length = decoded_length + consumed
        | MqttReceiveMaximum() =>
          (let receive_maximum', let consumed) = MqttReceiveMaximum.decode(reader) ?
          receive_maximum = receive_maximum'
          decoded_length = decoded_length + consumed
        | MqttMaximumPacketSize() =>
          (let maximum_packet_size', let consumed) = MqttMaximumPacketSize.decode(reader) ?
          maximum_packet_size = maximum_packet_size'
          decoded_length = decoded_length + consumed
        | MqttTopicAliasMaximum() =>
          (let topic_alias_maximum', let consumed) = MqttTopicAliasMaximum.decode(reader) ?
          topic_alias_maximum = topic_alias_maximum'
          decoded_length = decoded_length + consumed
        | MqttRequestResponseInformation() =>
          (let request_response_information', let consumed) = MqttRequestResponseInformation.decode(reader) ?
          request_response_information = request_response_information'
          decoded_length = decoded_length + consumed
        | MqttRequestProblemInformation() =>
          (let request_problem_information', let consumed) = MqttRequestResponseInformation.decode(reader) ?
          request_problem_information = request_problem_information'
          decoded_length = decoded_length + consumed
        | MqttUserProperty() =>
          (let user_property', let consumed) = MqttUserProperty.decode(reader) ?
          try (user_properties as Map[String val, String val] iso).insert(user_property'._1, user_property'._2) end
          decoded_length = decoded_length + consumed
        | MqttAuthenticationMethod() =>
          (let authentication_method', let consumed) = MqttAuthenticationMethod.decode(reader) ?
          authentication_method = authentication_method'
          decoded_length = decoded_length + consumed
        | MqttAuthenticationData() =>
          (let authentication_data', let consumed) = MqttAuthenticationData.decode(reader) ?
          authentication_data = authentication_data'
          decoded_length = decoded_length + consumed
        end
      end
    end
    (let client_identifier, _) = MqttUtf8String.decode(reader) ?
    if \unlikely\ will_flag then
      if protocol_version() == MqttVersion5() then
        (let will_property_length', _) = MqttVariableByteInteger.decode_reader(reader) ?
        let will_property_length = will_property_length'.usize()
        var will_decoded_length: USize = 0
        var will_delay_interval: U32 val = 0
        var payload_format_indicator: MqttPayloadFormatIndicatorType val = MqttUnspecifiedBytes
        var message_expiry_interval: (U32 val | None) = None
        var content_type: String val = ""
        var response_topic: String val = ""
        var correlation_data: (Array[U8 val] val | None) = None
        var will_user_properties: Array[(String val, String val)] iso = recover Array[(String val, String val)] end
        while will_decoded_length < will_property_length do
          let identifier = reader.u8() ?
          will_decoded_length = will_decoded_length + 1
          match identifier
          | MqttWillDelayInterval() =>
            (let will_delay_interval', let consumed) = MqttWillDelayInterval.decode(reader) ?
            will_delay_interval = will_delay_interval'
            will_decoded_length = will_decoded_length + consumed
          | MqttPayloadFormatIndicator() =>
            (let payload_format_indicator', let consumed) = MqttPayloadFormatIndicator.decode(reader) ?
            payload_format_indicator = payload_format_indicator'
            will_decoded_length = will_decoded_length + consumed
          | MqttMessageExpiryInterval() =>
            (let message_expiry_interval', let consumed) = MqttMessageExpiryInterval.decode(reader) ?
            message_expiry_interval = message_expiry_interval'
            will_decoded_length = will_decoded_length + consumed
          | MqttContentType() =>
            (let content_type', let consumed) = MqttContentType.decode(reader) ?
            content_type = content_type'
            will_decoded_length = will_decoded_length + consumed
          | MqttResponseTopic() =>
            (let response_topic', let consumed) = MqttResponseTopic.decode(reader) ?
            response_topic = response_topic'
            will_decoded_length = will_decoded_length + consumed
          | MqttCorrelationData() =>
            (let correlation_data', let consumed) = MqttCorrelationData.decode(reader) ?
            correlation_data = correlation_data'
            will_decoded_length = will_decoded_length + consumed
          | MqttUserProperty() =>
            (let user_property', let consumed) = MqttUserProperty.decode(reader) ?
            will_user_properties.push(user_property')
            will_decoded_length = will_decoded_length + consumed
          end
        end
        will_properties = MqttWillProperties(
          will_delay_interval,
          payload_format_indicator,
          message_expiry_interval,
          content_type,
          response_topic,
          correlation_data,
          consume will_user_properties
        )
      end
      (let will_topic': String val, _) = MqttUtf8String.decode(reader) ?
      will_topic = will_topic'
      (let will_payload': Array[U8 val] val, _) = MqttBinaryData.decode(reader) ?
      will_payload = will_payload'
    end
    if user_name_flag then
      (let user_name': String val, _) = MqttUtf8String.decode(reader) ?
      user_name = user_name'
    end
    if password_flag then
      (let password': Array[U8 val] val, _) = MqttBinaryData.decode(reader) ?
      password = password'
    end
    let packet =
      MqttConnectPacket(
        protocol_name,
        protocol_version,
        clean_start,
        will_qos,
        will_retain,
        keep_alive,
        session_expiry_interval,
        receive_maximum,
        maximum_packet_size,
        topic_alias_maximum,
        request_response_information,
        request_problem_information,
        consume user_properties,
        authentication_method,
        authentication_data,
        client_identifier,
        will_properties,
        will_topic,
        will_payload,
        user_name,
        password
      )
    (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)

primitive MqttConnectMeasurer
  fun variable_header_size(data: MqttConnectPacket box, version: MqttVersion box): USize val =>
    var size: USize = 0
    if \unlikely\ version() == MqttVersion31() then
      size = MqttUtf8String.size("MQisdp")
    else
      size = MqttUtf8String.size("MQTT")
    end
    size = size + 1 // protocol version
    size = size + 1 // flags
    size = size + MqttTwoByteInteger.size(data.keep_alive)
    if \likely\ version() == MqttVersion5() then
      let properties_length = properties_size(data)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun payload_size(data: MqttConnectPacket box, version: MqttVersion box): USize val =>
    var size: USize = 0

    let will_flag: Bool =
      if \likely\ version() == MqttVersion5() then
        match (data.will_properties, data.will_topic, data.will_payload)
        | (None, _, _) => false
        | (_, None, _) => false
        | (_, _, None) => false
        else
          true
        end
      else
        match (data.will_topic, data.will_payload)
        | (None, _) => false
        | (_, None) => false
        else
          true
        end
      end

    size = MqttUtf8String.size(data.client_identifier)
    if \unlikely\ will_flag then
      if \likely\ version() == MqttVersion5() then
        let will_properties_length =
          match data.will_properties
          | let will_properties: MqttWillProperties box =>
            will_properties_size(will_properties)
          else
            0
          end
        size = size + MqttVariableByteInteger.size(will_properties_length.ulong()) + will_properties_length
      end
      size = size +
          match data.will_topic
          | let will_topic: String box =>
            MqttUtf8String.size(will_topic)
          else
            0
          end
      size = size +
          match data.will_payload
          | let will_payload: Array[U8] box =>
            MqttBinaryData.size(will_payload)
          else
            0
          end
    end
    size = size +
        match data.user_name
        | let user_name: String box =>
          MqttUtf8String.size(user_name)
        else
          0
        end
    size = size +
        match data.password
        | let password: Array[U8] box =>
          MqttBinaryData.size(password)
        else
          0
        end
    size

  fun properties_size(data: MqttConnectPacket box): USize val =>
    var size: USize = 0
    size = size +
        match data.session_expiry_interval
        | let session_expiry_interval: U32 box =>
          MqttSessionExpiryInterval.size(session_expiry_interval)
        else
          0
        end

    size = size +
        match data.receive_maximum
        | let receive_maximum: U16 box =>
          MqttReceiveMaximum.size(receive_maximum)
        else
          0
        end

    size = size +
        match data.maximum_packet_size
        | let maximum_packet_size: U32 box =>
          MqttMaximumPacketSize.size(maximum_packet_size)
        else
          0
        end

    size = size +
        match data.topic_alias_maximum
        | let topic_alias_maximum: U16 box =>
          MqttTopicAliasMaximum.size(topic_alias_maximum)
        else
          0
        end

    size = size +
        match data.request_response_information
        | true =>
          MqttRequestResponseInformation.size(true)
        else
          0
        end

    size = size +
        match data.request_problem_information
        | true =>
          MqttRequestProblemInformation.size(true)
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
        match data.authentication_method
        | let authentication_method: String box =>
          MqttAuthenticationMethod.size(authentication_method)
        else
          0
        end

    size = size +
        match data.authentication_data
        | let authentication_data: Array[U8 val] box =>
          MqttAuthenticationData.size(authentication_data)
        else
          0
        end

    size

  fun will_properties_size(will_properties: MqttWillProperties box): USize val =>
    var size: USize = 0

    size = size +
        match will_properties.will_delay_interval
        | let will_delay_interval: U32 box =>
          MqttWillDelayInterval.size(will_delay_interval)
        else
          0
        end

    size = size + MqttPayloadFormatIndicator.size(will_properties.payload_format_indicator)

    size = size +
        match will_properties.message_expiry_interval
        | let message_expiry_interval: U32 box =>
          MqttMessageExpiryInterval.size(message_expiry_interval)
        else
          0
        end

    size = size + MqttContentType.size(will_properties.content_type)

    size = size + MqttResponseTopic.size(will_properties.response_topic)

    size = size +
        match will_properties.correlation_data
        | let correlation_data: Array[U8 val] box =>
          MqttCorrelationData.size(correlation_data)
        else
          0
        end

    match will_properties.user_properties
    | let user_properties: Array[(String val, String val)] box =>
      for item in user_properties.values() do
        size = size + MqttUserProperty.size(item)
      end
    end

    size

primitive MqttConnectEncoder
  fun apply(data: MqttConnectPacket box, version: MqttVersion box = MqttVersion5): Array[U8] val =>
    let size = (MqttConnectMeasurer.variable_header_size(data, version) + MqttConnectMeasurer.payload_size(data, version)).ulong()
    let user_name_flag: Bool =
      match data.user_name
      | None => false
      else
        true
      end
    let password_flag: Bool =
      match data.password
      | None => false
      else
        true
      end
    let will_flag: Bool =
      if \likely\ version() == MqttVersion5() then
        match (data.will_properties, data.will_topic, data.will_payload)
        | (None, _, _) => false
        | (_, None, _) => false
        | (_, _, None) => false
        else
          true
        end
      else
        match (data.will_topic, data.will_payload)
        | (None, _) => false
        | (_, None) => false
        else
          true
        end
      end

    var buf = Array[U8](1 + MqttVariableByteInteger.size(size) + size.usize())

    buf.push(MqttConnect() and 0xF0)
    MqttVariableByteInteger.encode(buf, size)
    if \unlikely\ version() == MqttVersion31() then
      MqttUtf8String.encode(buf, "MQisdp")
    else
      MqttUtf8String.encode(buf, "MQTT")
    end
    buf.push(version())
    buf.push(MqttUserNameFlag.encode(user_name_flag) or (MqttPasswordFlag.encode(password_flag) or (MqttWillRetain.encode(data.will_retain) or (MqttWillQos.encode(data.will_qos) or (MqttWillFlag.encode(will_flag) or MqttCleanStart.encode(data.clean_start))))))
    MqttTwoByteInteger.encode(buf, data.keep_alive)

    if \likely\ version() == MqttVersion5() then
      var properties_length: USize = MqttConnectMeasurer.properties_size(data)

      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.session_expiry_interval
      | let session_expiry_interval: U32 box =>
        MqttSessionExpiryInterval.encode(buf, session_expiry_interval)
      end

      match data.receive_maximum
      | let receive_maximum: U16 box =>
        MqttReceiveMaximum.encode(buf, receive_maximum)
      end

      match data.maximum_packet_size
      | let maximum_packet_size: U32 box =>
        MqttMaximumPacketSize.encode(buf, maximum_packet_size)
      end

      match data.topic_alias_maximum
      | let topic_alias_maximum: U16 box =>
        MqttTopicAliasMaximum.encode(buf, topic_alias_maximum)
      end

      match data.request_response_information
      | true =>
        MqttRequestResponseInformation.encode(buf, true)
      end

      match data.request_problem_information
      | true =>
        MqttRequestProblemInformation.encode(buf, true)
      end

      match data.user_properties
      | let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
           MqttUserProperty.encode(buf, item)
        end
      end

      match data.authentication_method
      | let authentication_method: String box =>
        MqttAuthenticationMethod.encode(buf, authentication_method)
      end

      match data.authentication_data
      | let authentication_data: Array[U8 val] box =>
        MqttAuthenticationData.encode(buf, authentication_data)
      end
    end

    MqttUtf8String.encode(buf, data.client_identifier)

    if \unlikely\ will_flag then
      if \likely\ version() == MqttVersion5() then
        match data.will_properties
        | \unlikely\ let will_properties: MqttWillProperties box =>
          let will_properties_length = MqttConnectMeasurer.will_properties_size(will_properties)
          MqttVariableByteInteger.encode(buf, will_properties_length.ulong())

          match will_properties.will_delay_interval
          | let will_delay_interval: U32 box =>
            MqttWillDelayInterval.encode(buf, will_delay_interval)
          end

          MqttPayloadFormatIndicator.encode(buf, will_properties.payload_format_indicator)

          match will_properties.message_expiry_interval
          | let message_expiry_interval: U32 box =>
            MqttMessageExpiryInterval.encode(buf, message_expiry_interval)
          end

          MqttContentType.encode(buf, will_properties.content_type)
          MqttResponseTopic.encode(buf, will_properties.response_topic)

          match will_properties.correlation_data
          | let correlation_data: Array[U8] box =>
            MqttCorrelationData.encode(buf, correlation_data)
          end

          match will_properties.user_properties
          | let user_properties: Array[(String val, String val)] box =>
            for item in user_properties.values() do
              MqttUserProperty.encode(buf, item)
            end
          end
        end
      end

      match data.will_topic
      | let will_topic: String box =>
        MqttUtf8String.encode(buf, will_topic)
      end

      match data.will_payload
      | let will_payload: Array[U8 val] box =>
        MqttBinaryData.encode(buf, will_payload)
      end
    end

    match data.user_name
    | let user_name: String box =>
      MqttUtf8String.encode(buf, user_name)
    end

    match data.password
    | let password: Array[U8 val] box =>
      MqttBinaryData.encode(buf, password)
    end

    U8ArrayClone(buf)
