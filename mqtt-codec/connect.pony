use "collections"

primitive _MqttCleanStart
  fun decode(
    flags: U8)
  : Bool =>
    (flags and 0x02) != 0

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x02
    else
      0
    end

primitive _MqttWillFlag
  fun decode(
    flags: U8)
  : Bool =>
    (flags and 0x04) != 0

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x04
    else
      0
    end

primitive _MqttWillQos
  fun decode(
    flags: U8)
  : MqttQoS val =>
    _MqttQoSDecoder((flags and 0x18) >> 3)

  fun encode(
    data: MqttQoS)
  : U8 =>
    let qos = _MqttQoSEncoder(data)
    qos << 3

primitive _MqttWillRetain
  fun decode(
    flags: U8)
  : Bool =>
    (flags and 0x20) != 0

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x20
    else
      0
    end

primitive _MqttPasswordFlag
  fun decode(
    flags: U8)
  : Bool =>
    (flags and 0x40) != 0

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x40
    else
      0
    end

primitive _MqttUserNameFlag
  fun decode(
    flags: U8)
  : Bool =>
    (flags and 0x80) != 0

  fun encode(
    data: Bool)
  : U8 =>
    if data then
      0x80
    else
      0
    end

type MqttWillProperties is
  ( U32 // 1. will_delay_interval
  , MqttPayloadFormatIndicatorType // 2. payload_format_indicator
  , U32 // 3. message_expiry_interval
  , String val // 4. content_type
  , String val // 5. response_topic
  , (Array[U8] val| None) // 6. correlation_data
  , (Array[MqttUserProperty] val | None) // 7. user_properties
  )

primitive MqttWillPropertiesAccessor
  fun will_delay_interval(
    data: MqttWillProperties)
  : U32 =>
    """
    It represents the Will Delay Interval in seconds.

    * mqtt-5
    """
    data._1

  fun payload_format_indicator(
    data: MqttWillProperties)
  : MqttPayloadFormatIndicatorType =>
    """
    It represents the Payload Format of Will Message, including unspecified
    bytes and UTF-8 Encoded Character Data.

    * mqtt-5
    """
    data._2

  fun message_expiry_interval(
    data: MqttWillProperties)
  : U32 =>
    """
    It is the lifetime of the Will Message in seconds and is sent as the
    Publication Expiry Interval when the Server publishes the Will Message.

    * mqtt-5
    """
    data._3

  fun content_type(
    data: MqttWillProperties)
  : String val =>
    """
    It describes the content of the Will Message. The value of the Content Type
    is defined by the sending and receiving application.

    * mqtt-5
    """
    data._4

  fun response_topic(
    data: MqttWillProperties)
  : String val =>
    """
    It is used as the Topic Name for a response message.

    * mqtt-5
    """
    data._5

  fun correlation_data(
    data: MqttWillProperties)
  : (Array[U8] val| None) =>
    """
    The Correlation Data is used by the sender of the Request Message to
    identify which request the Response Message is for when it is received.

    * mqtt-5
    """
    data._6

  fun user_properties(
    data: MqttWillProperties)
  : (Array[MqttUserProperty] val | None) =>
    """
    This property is intended to provide a means of transferring application
    layer name-value tags whose meaning and interpretation are known only by
    the application programs responsible for sending and receiving them.

    * mqtt-5
    """
    data._7

  fun build(
    will_delay_interval': U32 = 0,
    payload_format_indicator': MqttPayloadFormatIndicatorType val,
    message_expiry_interval': U32 = 0,
    content_type': String val,
    response_topic': String val,
    correlation_data': (Array[U8] val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttWillProperties =>
    ( will_delay_interval'
    , payload_format_indicator'
    , message_expiry_interval'
    , content_type'
    , response_topic'
    , correlation_data'
    , user_properties'
    )

type MqttConnectPacket is
  ( String val // 1. protocal_name
  , MqttVersion // 2. protocol_version
  , Bool // 3. clean_start
  , MqttQoS // 4. will_qos
  , Bool // 5. will_retain
  , U16 // 6. keep_alive
  , U32 // 7. session_expiry_interval
  , U16 // 8. receive_maximum
  , U32 // 9. maximum_packet_size
  , U16 // 10. topic_alias_maximum
  , Bool // 11. requet_response_information
  , Bool // 12. request_problem_information
  , (Array[MqttUserProperty] val | None) // 13. user_properties
  , (String val | None) // 14. authentication_method
  , (Array[U8] val | None) // 15. authentication_data
  , String val // 16. client_identifier
  , (MqttWillProperties | None) // 17. will_properties
  , (String val | None) // 18. will_topic
  , (Array[U8] val | None) // 19. will_payload
  , (String val | None) // 20. user_name
  , (Array[U8] val | None) // 21. password
  )

primitive MqttConnect
  """
  Connection request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0x10

  fun protocol_name(
    packet: MqttConnectPacket)
  : String val =>
    """
    A Server which support multiple protocols uses the Protocol Name to
    determine whether the data is MQTT.

    * mqtt-3
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun protocol_version(
    packet: MqttConnectPacket)
  : MqttVersion =>
    """
    This represents the revision level of the protocol used by the Client.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._2

  fun clean_start(
    packet: MqttConnectPacket)
  : Bool =>
    """
    This specifies whether the Connection starts a new Session or is a
    continuation of an existing Session.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._3

  fun will_qos(
    packet: MqttConnectPacket)
  : MqttQoS =>
    """
    This specifies the QoS level to be used when publishing the Will Message.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._4

  fun will_retain(
    packet: MqttConnectPacket)
  : Bool =>
    """
    This specifies if the Will Message is to be retained when it is published.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._5

  fun keep_alive(
    packet: MqttConnectPacket)
  : U16 =>
    """
    It is the maximum time interval measured in seconds that is permitted to
    elapse between the point at which the Client finishes transmitting one MQTT
    Control Packet and the point it starts sending the next.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._6

  fun session_expiry_interval(
    packet: MqttConnectPacket)
  : U32 =>
    """
    It represents the Session Expiry Interval in seconds.

    * mqtt-5
    """
    packet._7

  fun receive_maximum(
    packet: MqttConnectPacket)
  : U16 =>
    """
    It represents the Receive Maximum value. The Client uses this value to
    limit the number of QoS 1 and QoS 2 publications that it is willing to
    process concurrently. There is no mechanism to limit the QoS 0 publications
    that the Server might try to send.

    * mqtt-5
    """
    packet._8

  fun maximum_packet_size(
    packet: MqttConnectPacket)
  : U32 =>
    """
    It represents the Maximum Packet Size the Client is willing to accept.

    * mqtt-5
    """
    packet._9

  fun topic_alias_maximum(
    packet: MqttConnectPacket)
  : U16 =>
    """
    It represents the Topic Alias Maximum value. This value indicates the
    highest value that the Client will accept as a Topic Alias sent by the
    Server. The Client uses this value to limit the number of Topic Aliases
    that it is willing to hold on this Connection.

    * mqtt-5
    """
    packet._10

  fun request_response_information(
    packet: MqttConnectPacket)
  : Bool =>
    """
    The Client uses this value to request the Server to return Response
    Information in the CONNACK.

    * mqtt-5
    """
    packet._11

  fun request_problem_information(
    packet: MqttConnectPacket)
  : Bool =>
    """
    The Client uses this value to indicate whether the Reason String or User
    Properties are sent in the case of failures.

    * mqtt-5
    """
    packet._12

  fun user_properties(
    packet: MqttConnectPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    User Properties on the CONNECT packet can be used to send connection related
    properties from the Client to the Server.

    * mqtt-5
    """
    packet._13

  fun authentication_method(
    packet: MqttConnectPacket)
  : (String val | None) =>
    """
    It contains the name of the authentication method used for extended
    authentication.

    * mqtt-5
    """
    packet._14

  fun authentication_data(
    packet: MqttConnectPacket)
  : (Array[U8] val | None) =>
    """
    It contains authentication data. The contents of this data are defined by
    the authentication method.

    * mqtt-5
    """
    packet._15

  fun client_identifier(
    packet: MqttConnectPacket)
  : String val =>
    """
    The Client Identifier (ClientID) identifies the Client to the Server.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._16

  fun will_properties(
    packet: MqttConnectPacket)
  : (MqttWillProperties | None) =>
    """
    The Will Properties field defines the Application Message properties to be
    sent with the Will Message when it is published, and properties which
    define when to publish the Will Message.

    * mqtt-5
    """
    packet._17

  fun will_topic(
    packet: MqttConnectPacket)
  : (String val | None) =>
    """
    It represents the topic of the Will Message.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._18

  fun will_payload(
    packet: MqttConnectPacket)
  : (Array[U8] val | None) =>
    """
    The Will Payload defines the Application Message Payload that is to be
    published to the Will Topic.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._19

  fun user_name(
    packet: MqttConnectPacket)
  : (String val | None) =>
    """
    It can be used by the Server for authentication and authorization.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._20

  fun password(
    packet: MqttConnectPacket)
  : (Array[U8] val| None) =>
    """
    It can be used by the Server for authentication and authorization.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._21

  fun build(
    protocol_name': String val,
    protocol_version': MqttVersion = MqttVersion5,
    clean_start': Bool = false,
    will_qos': MqttQoS = MqttQoS0,
    will_retain': Bool = false,
    keep_alive': U16 = 0,
    session_expiry_interval': U32 = 0,
    receive_maximum': U16 = 0,
    maximum_packet_size': U32 = 0,
    topic_alias_maximum': U16 = 0,
    request_response_information': Bool = false,
    request_problem_information': Bool = false,
    user_properties': (Array[MqttUserProperty] val | None) = None,
    authentication_method': (String val | None) = None,
    authentication_data': (Array[U8] val | None) = None,
    client_identifier': String val,
    will_properties': (MqttWillProperties | None) = None,
    will_topic': (String val | None) = None,
    will_payload': (Array[U8] val | None) = None,
    user_name': (String val | None) = None,
    password': (Array[U8] val | None) = None)
  : MqttConnectPacket =>
    ( protocol_name'
    , protocol_version'
    , clean_start'
    , will_qos'
    , will_retain'
    , keep_alive'
    , session_expiry_interval'
    , receive_maximum'
    , maximum_packet_size'
    , topic_alias_maximum'
    , request_response_information'
    , request_problem_information'
    , user_properties'
    , authentication_method'
    , authentication_data'
    , client_identifier'
    , will_properties'
    , will_topic'
    , will_payload'
    , user_name'
    , password'
    )

primitive _MqttConnectDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8)
  : MqttConnectPacket? =>
    var offset' = offset
    (let protocol_name, let protocal_name_size) = _MqttUtf8String.decode(buf, offset')?
    offset' = offset' + protocal_name_size
    let protocol_version =
      match buf(offset')?
      | MqttVersion311() => MqttVersion311
      | MqttVersion31() => MqttVersion31
      else
        MqttVersion5
      end
    offset' = offset' + 1
    let flags = buf(offset')?
    offset' = offset' + 1
    let clean_start = _MqttCleanStart.decode(flags)
    let will_flag = _MqttWillFlag.decode(flags)
    let will_qos = _MqttWillQos.decode(flags)
    let will_retain = _MqttWillRetain.decode(flags)
    let password_flag = _MqttPasswordFlag.decode(flags)
    let user_name_flag = _MqttUserNameFlag.decode(flags)
    (let keep_alive, let keep_alive_size) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + keep_alive_size
    var session_expiry_interval: U32 = 0
    var receive_maximum: U16 = 0
    var maximum_packet_size: U32 = 0
    var topic_alias_maximum: U16 = 0
    var request_response_information: Bool = false
    var request_problem_information: Bool = false
    var user_properties: (Array[MqttUserProperty] iso | None) = None
    var authentication_method: (String val | None) = None
    var authentication_data: (Array[U8] val | None) = None
    var will_properties: (MqttWillProperties val | None) = None
    var will_topic: (String val | None) = None
    var will_payload: (Array[U8] val | None) = None
    var user_name: (String val | None) = None
    var password: (Array[U8] val | None) = None
    if \likely\ protocol_version == MqttVersion5 then
      (let property_length', let property_length_size) = _MqttVariableByteInteger.decode(buf, offset')?
      offset' = offset' + property_length_size
      user_properties = recover iso Array[MqttUserProperty] end
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      while decoded_length < property_length do
        let identifier = buf(decoded_length + offset')?
        decoded_length = decoded_length + 1
        match identifier
        | _MqttSessionExpiryInterval() =>
          (let session_expiry_interval', let session_expiry_interval_size) = _MqttSessionExpiryInterval.decode(buf, offset' + decoded_length)?
          session_expiry_interval = session_expiry_interval'
          decoded_length = decoded_length + session_expiry_interval_size
        | _MqttReceiveMaximum() =>
          (let receive_maximum', let receive_maximum_size) = _MqttReceiveMaximum.decode(buf, offset' + decoded_length)?
          receive_maximum = receive_maximum'
          decoded_length = decoded_length + receive_maximum_size
        | _MqttMaximumPacketSize() =>
          (let maximum_packet_size', let maximum_packet_size_size) = _MqttMaximumPacketSize.decode(buf, offset' + decoded_length)?
          maximum_packet_size = maximum_packet_size'
          decoded_length = decoded_length + maximum_packet_size_size
        | _MqttTopicAliasMaximum() =>
          (let topic_alias_maximum', let topic_alias_maximum_size) = _MqttTopicAliasMaximum.decode(buf, offset' + decoded_length)?
          topic_alias_maximum = topic_alias_maximum'
          decoded_length = decoded_length + topic_alias_maximum_size
        | _MqttRequestResponseInformation() =>
          (let request_response_information', let request_response_information_size) = _MqttRequestResponseInformation.decode(buf, offset' + decoded_length)?
          request_response_information = request_response_information'
          decoded_length = decoded_length + request_response_information_size
        | _MqttRequestProblemInformation() =>
          (let request_problem_information', let request_problem_information_size) = _MqttRequestResponseInformation.decode(buf, offset' + decoded_length)?
          request_problem_information = request_problem_information'
          decoded_length = decoded_length + request_problem_information_size
        | _MqttUserProperty() =>
          (let user_property, let user_property_size) = _MqttUserProperty.decode(buf, offset' + decoded_length)?
          try (user_properties as Array[MqttUserProperty] iso).push(consume user_property) end
          decoded_length = decoded_length + user_property_size
        | _MqttAuthenticationMethod() =>
          (let authentication_method', let  authentication_method_size) = _MqttAuthenticationMethod.decode(buf, offset' + decoded_length)?
          authentication_method = consume authentication_method'
          decoded_length = decoded_length + authentication_method_size
        | _MqttAuthenticationData() =>
          (let authentication_data', let authentication_data_size) = _MqttAuthenticationData.decode(buf, offset' + decoded_length)?
          authentication_data = consume authentication_data'
          decoded_length = decoded_length + authentication_data_size
        end
      end
      offset' = offset' + decoded_length
    end
    (let client_identifier, let client_identifier_size) = _MqttUtf8String.decode(buf, offset')?
    offset' = offset' + client_identifier_size
    if \unlikely\ will_flag then
      if protocol_version == MqttVersion5 then
        (let will_property_length', let will_property_length_size) = _MqttVariableByteInteger.decode(buf, offset')?
        offset' = offset' + will_property_length_size
        let will_property_length = will_property_length'.usize()
        var will_decoded_length: USize = 0
        var will_delay_interval: U32 = 0
        var payload_format_indicator: MqttPayloadFormatIndicatorType val = MqttUnspecifiedBytes
        var message_expiry_interval: U32 = 0
        var content_type: String val = ""
        var response_topic: String val = ""
        var correlation_data: (Array[U8] val | None) = None
        var will_user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty] end
        while will_decoded_length < will_property_length do
          let identifier = buf(offset' + will_decoded_length)?
          will_decoded_length = will_decoded_length + 1
          match identifier
          | _MqttWillDelayInterval() =>
            (let will_delay_interval', let will_delay_interval_size) = _MqttWillDelayInterval.decode(buf, offset' + will_decoded_length)?
            will_delay_interval = will_delay_interval'
            will_decoded_length = will_decoded_length + will_delay_interval_size
          | _MqttPayloadFormatIndicator() =>
            (let payload_format_indicator', let payload_format_indicator_size) = _MqttPayloadFormatIndicator.decode(buf, offset' + will_decoded_length)?
            payload_format_indicator = payload_format_indicator'
            will_decoded_length = will_decoded_length + payload_format_indicator_size
          | _MqttMessageExpiryInterval() =>
            (let message_expiry_interval', let message_expiry_interval_size) = _MqttMessageExpiryInterval.decode(buf, offset' + will_decoded_length)?
            message_expiry_interval = message_expiry_interval'
            will_decoded_length = will_decoded_length + message_expiry_interval_size
          | _MqttContentType() =>
            (let content_type', let content_type_size) = _MqttContentType.decode(buf, offset' + will_decoded_length)?
            content_type = consume content_type'
            will_decoded_length = will_decoded_length + content_type_size
          | _MqttResponseTopic() =>
            (let response_topic', let response_topic_size) = _MqttResponseTopic.decode(buf, offset' + will_decoded_length)?
            response_topic = consume response_topic'
            will_decoded_length = will_decoded_length + response_topic_size
          | _MqttCorrelationData() =>
            (let correlation_data', let correlation_data_size) = _MqttCorrelationData.decode(buf, offset' + will_decoded_length)?
            correlation_data = consume correlation_data'
            will_decoded_length = will_decoded_length + correlation_data_size
          | _MqttUserProperty() =>
            (let user_property, let user_property_size) = _MqttUserProperty.decode(buf, offset' + will_decoded_length)?
            will_user_properties.push(consume user_property)
            will_decoded_length = will_decoded_length + user_property_size
          end
        end
        offset' = offset' + will_decoded_length
        will_properties = MqttWillPropertiesAccessor.build(
          will_delay_interval,
          payload_format_indicator,
          message_expiry_interval,
          content_type,
          response_topic,
          correlation_data,
          consume will_user_properties
        )
      end
      (let will_topic': String val, let will_topic_size) = _MqttUtf8String.decode(buf, offset')?
      offset' = offset' + will_topic_size
      will_topic = will_topic'
      (let will_payload': Array[U8] val, let will_payload_size) = _MqttBinaryData.decode(buf, offset')?
      offset' = offset' + will_payload_size
      will_payload = will_payload'
    end
    if user_name_flag then
      (let user_name': String val, let user_name_size) = _MqttUtf8String.decode(buf, offset')?
      offset' = offset' + user_name_size
      user_name = user_name'
    end
    if password_flag then
      (let password': Array[U8] val, let password_size) = _MqttBinaryData.decode(buf, offset')?
      offset' = offset' + password_size
      password = password'
    end
    MqttConnect.build(
      consume protocol_name,
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
      consume client_identifier,
      will_properties,
      will_topic,
      will_payload,
      user_name,
      password
    )

primitive _MqttConnectMeasurer
  fun variable_header_size(
    packet: MqttConnectPacket,
    version: MqttVersion)
  : USize =>
    var size: USize = 0
    if \unlikely\ version == MqttVersion31 then
      size = _MqttUtf8String.size("MQisdp")
    else
      size = _MqttUtf8String.size("MQTT")
    end
    size = size + 1 // protocol version
    size = size + 1 // flags
    size = size + _MqttTwoByteInteger.size(MqttConnect.keep_alive(packet))
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun payload_size(
    packet: MqttConnectPacket,
    version: MqttVersion)
  : USize =>
    var size: USize = 0

    let will_flag: Bool =
      if \likely\ version == MqttVersion5 then
        match (MqttConnect.will_properties(packet), MqttConnect.will_topic(packet), MqttConnect.will_payload(packet))
        | (None, _, _) => false
        | (_, None, _) => false
        | (_, _, None) => false
        else
          true
        end
      else
        match (MqttConnect.will_topic(packet), MqttConnect.will_payload(packet))
        | (None, _) => false
        | (_, None) => false
        else
          true
        end
      end

    size = _MqttUtf8String.size(MqttConnect.client_identifier(packet))
    if \unlikely\ will_flag then
      if \likely\ version == MqttVersion5 then
        let will_properties_length =
          match MqttConnect.will_properties(packet)
          | let will_properties: MqttWillProperties =>
            will_properties_size(will_properties)
          else
            0
          end
        size = size + _MqttVariableByteInteger.size(will_properties_length.ulong()) + will_properties_length
      end
      match MqttConnect.will_topic(packet)
      | let will_topic: String val =>
        size = size + _MqttUtf8String.size(will_topic)
      end
      match MqttConnect.will_payload(packet)
      | let will_payload: Array[U8] val =>
        size = size + _MqttBinaryData.size(will_payload)
      end
    end
    match MqttConnect.user_name(packet)
    | let user_name: String val =>
      size = size + _MqttUtf8String.size(user_name)
    end
    match MqttConnect.password(packet)
    | let password: Array[U8] val =>
      size = size + _MqttBinaryData.size(password)
    end
    size

  fun properties_size(
    packet: MqttConnectPacket)
  : USize =>
    var size: USize = 0
    match MqttConnect.session_expiry_interval(packet)
    | let session_expiry_interval: U32 if session_expiry_interval != 0 =>
      size = size + _MqttSessionExpiryInterval.size(session_expiry_interval)
    end

    match MqttConnect.receive_maximum(packet)
    | let receive_maximum: U16 if receive_maximum != 0 =>
      size = size + _MqttReceiveMaximum.size(receive_maximum)
    end

    match MqttConnect.maximum_packet_size(packet)
    | let maximum_packet_size: U32 if maximum_packet_size != 0 =>
      size = size + _MqttMaximumPacketSize.size(maximum_packet_size)
    end

    match MqttConnect.topic_alias_maximum(packet)
    | let topic_alias_maximum: U16 if topic_alias_maximum != 0 =>
      size = size + _MqttTopicAliasMaximum.size(topic_alias_maximum)
    end

    if MqttConnect.request_response_information(packet) then
      size = size + _MqttRequestResponseInformation.size(true)
    end

    if MqttConnect.request_problem_information(packet) then
      size = size + _MqttRequestProblemInformation.size(true)
    end

    match MqttConnect.user_properties(packet)
    | let user_properties: Array[MqttUserProperty] val =>
      for property in user_properties.values() do
        size = size + _MqttUserProperty.size(property)
      end
    end

    match MqttConnect.authentication_method(packet)
    | let authentication_method: String val =>
      size = size + _MqttAuthenticationMethod.size(authentication_method)
    end

    match MqttConnect.authentication_data(packet)
    | let authentication_data: Array[U8] val =>
      size = size + _MqttAuthenticationData.size(authentication_data)
    end

    size

  fun will_properties_size(
    will_properties: MqttWillProperties)
  : USize =>
    var size: USize = 0

    match MqttWillPropertiesAccessor.will_delay_interval(will_properties)
    | let will_delay_interval: U32 if will_delay_interval != 0 =>
      size = size + _MqttWillDelayInterval.size(will_delay_interval)
    end

    size = size + _MqttPayloadFormatIndicator.size(MqttWillPropertiesAccessor.payload_format_indicator(will_properties))

    match MqttWillPropertiesAccessor.message_expiry_interval(will_properties)
    | let message_expiry_interval: U32 if message_expiry_interval != 0 =>
      size = size + _MqttMessageExpiryInterval.size(message_expiry_interval)
    end

    size = size + _MqttContentType.size(MqttWillPropertiesAccessor.content_type(will_properties))

    size = size + _MqttResponseTopic.size(MqttWillPropertiesAccessor.response_topic(will_properties))

    match MqttWillPropertiesAccessor.correlation_data(will_properties)
    | let correlation_data: Array[U8] val =>
      size = size + _MqttCorrelationData.size(correlation_data)
    end

    match MqttWillPropertiesAccessor.user_properties(will_properties)
    | let user_properties: Array[MqttUserProperty] val =>
      for property in user_properties.values() do
        size = size + _MqttUserProperty.size(property)
      end
    end

    size

primitive _MqttConnectEncoder
  fun apply(
    packet: MqttConnectPacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let size = (_MqttConnectMeasurer.variable_header_size(packet, version) + _MqttConnectMeasurer.payload_size(packet, version)).ulong()
    let user_name_flag: Bool =
      match MqttConnect.user_name(packet)
      | None => false
      else
        true
      end
    let password_flag: Bool =
      match MqttConnect.password(packet)
      | None => false
      else
        true
      end
    let will_flag: Bool =
      if \likely\ version == MqttVersion5 then
        match (MqttConnect.will_properties(packet), MqttConnect.will_topic(packet), MqttConnect.will_payload(packet))
        | (None, _, _) => false
        | (_, None, _) => false
        | (_, _, None) => false
        else
          true
        end
      else
        match (MqttConnect.will_topic(packet), MqttConnect.will_payload(packet))
        | (None, _) => false
        | (_, None) => false
        else
          true
        end
      end

    var buf = recover iso Array[U8](1 + _MqttVariableByteInteger.size(size) + size.usize()) end

    buf.push(MqttConnect() and 0xF0)
    buf = _MqttVariableByteInteger.encode(consume buf, size)
    if \unlikely\ version == MqttVersion31 then
      buf = _MqttUtf8String.encode(consume buf, "MQisdp")
    else
      buf = _MqttUtf8String.encode(consume buf, "MQTT")
    end
    buf.push(version())
    buf.push(_MqttUserNameFlag.encode(user_name_flag) or _MqttPasswordFlag.encode(password_flag) or _MqttWillRetain.encode(MqttConnect.will_retain(packet)) or _MqttWillQos.encode(MqttConnect.will_qos(packet)) or _MqttWillFlag.encode(will_flag) or _MqttCleanStart.encode(MqttConnect.clean_start(packet)))
    buf = _MqttTwoByteInteger.encode(consume buf, MqttConnect.keep_alive(packet))

    if \likely\ version == MqttVersion5 then
      var properties_length: USize = _MqttConnectMeasurer.properties_size(packet)

      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttConnect.session_expiry_interval(packet)
      | let session_expiry_interval: U32 if session_expiry_interval != 0 =>
        buf = _MqttSessionExpiryInterval.encode(consume buf, session_expiry_interval)
      end

      match MqttConnect.receive_maximum(packet)
      | let receive_maximum: U16 if receive_maximum != 0 =>
        buf = _MqttReceiveMaximum.encode(consume buf, receive_maximum)
      end

      match MqttConnect.maximum_packet_size(packet)
      | let maximum_packet_size: U32 if maximum_packet_size != 0 =>
        buf = _MqttMaximumPacketSize.encode(consume buf, maximum_packet_size)
      end

      match MqttConnect.topic_alias_maximum(packet)
      | let topic_alias_maximum: U16 if topic_alias_maximum != 0 =>
        buf = _MqttTopicAliasMaximum.encode(consume buf, topic_alias_maximum)
      end

      if MqttConnect.request_response_information(packet) then
        buf = _MqttRequestResponseInformation.encode(consume buf, true)
      end

      if MqttConnect.request_problem_information(packet) then
        buf = _MqttRequestProblemInformation.encode(consume buf, true)
      end

      match MqttConnect.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          buf = _MqttUserProperty.encode(consume buf, property)
        end
      end

      match MqttConnect.authentication_method(packet)
      | let authentication_method: String val =>
        buf = _MqttAuthenticationMethod.encode(consume buf, authentication_method)
      end

      match MqttConnect.authentication_data(packet)
      | let authentication_data: Array[U8] val =>
        buf = _MqttAuthenticationData.encode(consume buf, authentication_data)
      end
    end

    buf = _MqttUtf8String.encode(consume buf, MqttConnect.client_identifier(packet))

    if \unlikely\ will_flag then
      if \likely\ version == MqttVersion5 then
        match MqttConnect.will_properties(packet)
        | \unlikely\ let will_properties: MqttWillProperties val =>
          let will_properties_length = _MqttConnectMeasurer.will_properties_size(will_properties)
          buf = _MqttVariableByteInteger.encode(consume buf, will_properties_length.ulong())

          match MqttWillPropertiesAccessor.will_delay_interval(will_properties)
          | let will_delay_interval: U32 if will_delay_interval != 0 =>
            buf = _MqttWillDelayInterval.encode(consume buf, will_delay_interval)
          end

          buf = _MqttPayloadFormatIndicator.encode(consume buf, MqttWillPropertiesAccessor.payload_format_indicator(will_properties))

          match MqttWillPropertiesAccessor.message_expiry_interval(will_properties)
          | let message_expiry_interval: U32 if message_expiry_interval != 0 =>
            buf = _MqttMessageExpiryInterval.encode(consume buf, message_expiry_interval)
          end

          buf = _MqttContentType.encode(consume buf, MqttWillPropertiesAccessor.content_type(will_properties))
          buf = _MqttResponseTopic.encode(consume buf, MqttWillPropertiesAccessor.response_topic(will_properties))

          match MqttWillPropertiesAccessor.correlation_data(will_properties)
          | let correlation_data: Array[U8] val =>
            buf = _MqttCorrelationData.encode(consume buf, correlation_data)
          end

          match MqttWillPropertiesAccessor.user_properties(will_properties)
          | let user_properties: Array[MqttUserProperty] val =>
            for property in user_properties.values() do
              buf = _MqttUserProperty.encode(consume buf, property)
            end
          end
        end
      end

      match MqttConnect.will_topic(packet)
      | let will_topic: String val =>
        buf = _MqttUtf8String.encode(consume buf, will_topic)
      end

      match MqttConnect.will_payload(packet)
      | let will_payload: Array[U8] val =>
        buf = _MqttBinaryData.encode(consume buf, will_payload)
      end
    end

    match MqttConnect.user_name(packet)
    | let user_name: String val =>
      buf = _MqttUtf8String.encode(consume buf, user_name)
    end

    match MqttConnect.password(packet)
    | let password: Array[U8] val =>
      buf = _MqttBinaryData.encode(consume buf, password)
    end

    consume buf
