use "collections"

type MqttConnectReasonCode is
  ( MqttSuccess
  | MqttUnspecifiedError
  | MqttMalformedPacket
  | MqttProtocolError
  | MqttImplementationSpecificError
  | MqttUnsupportedProtocolVersion
  | MqttClientIdentifierNotValid
  | MqttBadUserNameOrPassword5
  | MqttNotAuthorized5
  | MqttServerUnavailable5
  | MqttServerBusy
  | MqttBanned
  | MqttBadAuthenticationMethod
  | MqttTopicNameInvalid
  | MqttPacketTooLarge
  | MqttQuotaExceeded
  | MqttPayloadFormatInvalid
  | MqttRetainNotSupported
  | MqttQoSNotSupported
  | MqttUseAnotherServer
  | MqttServerMoved
  | MqttConnectionRateExceeded
  )

type MqttConnAckPacket is
  ( Bool // 1. session_present
  , MqttConnectReasonCode // 2. reason_code
  , MqttConnectReturnCode // 3. return_code
  , U32 // 4. session_expiry_interval
  , U16 // 5. receive_maximum
  , Bool // 6. maximum_qos
  , Bool // 7. retain_available
  , U32 // 8. maximum_packet_size
  , (String val | None) // 9. assigned_client_identifier
  , U16 // 10. topic_alias_maximum
  , (String val | None) // 11. reason_string
  , (Array[MqttUserProperty] val | None) // 12. user_properties
  , Bool // 13. wildcard_subscription_available
  , Bool // 14. subscription_identifier_available
  , Bool // 15. shared_subscription_available
  , U16 // 16. server_keep_alive
  , (String val | None) // 17. response_information
  , (String val | None) // 18. server_reference
  , (String val | None) // 19. authentication_method
  , (Array[U8] val | None) // 20. authentication_data
  )

primitive MqttConnAck
  """
  Connect acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0x20

  fun session_present(
    packet: MqttConnAckPacket)
  : Bool =>
    """
    The Session Present flag informs the Client whether the Server is using
    Session State from a previous connection for this ClientID. This allows the
    Client and Server to have a consistent view of the Session State.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun reason_code(
    packet: MqttConnAckPacket)
  : MqttConnectReasonCode =>
    """
    If a well formed CONNECT packet is received by the Server, but the Server is
    unable to complete the Connection the Server MAY send a CONNACK packet
    containing the appropriate Connect Reason code.

    * mqtt-5
    """
    packet._2

  fun return_code(
    packet: MqttConnAckPacket)
  : MqttConnectReturnCode =>
    """
    If a well formed CONNECT Packet is received by the Server, but the Server is
    unable to process it for some reason, then the Server SHOULD attempt to send
    a CONNACK packet containing the appropriate non-zero Connect return code.

    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._3

  fun session_expiry_interval(
    packet: MqttConnAckPacket)
  : U32 =>
    """
    When the Session expires the Client and Server need not process the deletion
    of state atomically.

    * mqtt-5
    """
    packet._4

  fun receive_maximum(
    packet: MqttConnAckPacket)
  : U16 =>
    """
    The Client uses this value to limit the number of QoS 1 and QoS 2
    publications that it is willing to process concurrently.

    * mqtt-5
    """
    packet._5

  fun maximum_qos(
    packet: MqttConnAckPacket)
  : Bool =>
    """
    The Server uses this value to specify the highest QoS it supports.

    * mqtt-5
    """
    packet._6

  fun retain_available(
    packet: MqttConnAckPacket)
  : Bool =>
    """
    A value of false means that retained messages are not supported. A value of
    true means retained messages are supported.

    * mqtt-5
    """
    packet._7

  fun maximum_packet_size(
    packet: MqttConnAckPacket)
  : U32 =>
    """
    The Server uses the Maximum Packet Size to inform the Client that it will
    not process packets whose size exceeds this limit.

    * mqtt-5
    """
    packet._8

  fun assigned_client_identifier(
    packet: MqttConnAckPacket)
  : (String val | None) =>
    """
    The Client Identifier which was assigned by the Server because a zero length
    Client Identifier was found in the CONNECT packet.

    * mqtt-5
    """
    packet._9

  fun topic_alias_maximum(
    packet: MqttConnAckPacket)
  : U16 =>
    """
    This value indicates the highest value that the Server will accept as a
    Topic Alias sent by the Client. The Server uses this value to limit the
    number of Topic Aliases that it is willing to hold on this Connection.

    * mqtt-5
    """
    packet._10

  fun reason_string(
    packet: MqttConnAckPacket)
  : (String val | None) =>
    """
    The Server uses this value to give additional information to the Client.

    * mqtt-5
    """
    packet._11

  fun user_properties(
    packet: MqttConnAckPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    This property can be used to provide additional information to the Client
    including diagnostic information.

    * mqtt-5
    """
    packet._12

  fun wildcard_subscription_available(
    packet: MqttConnAckPacket)
  : Bool =>
    """
    This property declares whether the Server supports Wildcard Subscriptions.

    * mqtt-5
    """
    packet._13

  fun subscription_identifier_available(
    packet: MqttConnAckPacket)
  : Bool =>
    """
    This property declares whether the Server supports Subscription Identifiers.

    * mqtt-5
    """
    packet._14

  fun shared_subscription_available(
    packet: MqttConnAckPacket)
  : Bool =>
    """
    This property declares whether the Server supports Shared Subscriptions.

    * mqtt-5
    """
    packet._15

  fun server_keep_alive(
    packet: MqttConnAckPacket)
  : U16 =>
    """
    This property declares the Keep Alive time assigned by the Server.

    * mqtt-5
    """
    packet._16

  fun response_information(
    packet: MqttConnAckPacket)
  : (String val | None) =>
    """
    This property is used as the basis for creating a Response Topic.

    * mqtt-5
    """
    packet._17

  fun server_reference(
    packet: MqttConnAckPacket)
  : (String val | None) =>
    """
    This property can be used by the Client to identify another Server to use.

    * mqtt-5
    """
    packet._18

  fun authentication_method(
    packet: MqttConnAckPacket)
  : (String val | None) =>
    """
    This property contains the name of the authentication method.

    * mqtt-5
    """
    packet._19

  fun authentication_data(
    packet: MqttConnAckPacket)
  : (Array[U8] val | None) =>
    """
    This property contains authentication data. The contents of this data are
    defined by the authentication method and the state of already exchanged
    authentication data.

    * mqtt-5
    """
    packet._20

  fun build(
    session_present': Bool,
    reason_code': MqttConnectReasonCode,
    return_code': MqttConnectReturnCode,
    session_expiry_interval': U32 = 0,
    receive_maximum': U16 = 0,
    maximum_qos': Bool = false,
    retain_available': Bool = false,
    maximum_packet_size': U32 = 0,
    assigned_client_identifier': (String val | None) = None,
    topic_alias_maximum': U16 = 0,
    reason_string': (String val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None,
    wildcard_subscription_available': Bool = false,
    subscription_identifier_available': Bool = false,
    shared_subscription_available': Bool = false,
    server_keep_alive': U16 = 0,
    response_information': (String val | None) = None,
    server_reference': (String val | None) = None,
    authentication_method': (String val | None) = None,
    authentication_data': (Array[U8] val | None) = None)
  : MqttConnAckPacket =>
    ( session_present'
    , reason_code'
    , return_code'
    , session_expiry_interval'
    , receive_maximum'
    , maximum_qos'
    , retain_available'
    , maximum_packet_size'
    , assigned_client_identifier'
    , topic_alias_maximum'
    , reason_string'
    , user_properties'
    , wildcard_subscription_available'
    , subscription_identifier_available'
    , shared_subscription_available'
    , server_keep_alive'
    , response_information'
    , server_reference'
    , authentication_method'
    , authentication_data'
    )

primitive _MqttConnAckDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttConnAck(),
    version: MqttVersion = MqttVersion5)
  : MqttConnAckPacket? =>
    var offset' = offset
    let flags = buf(offset')?
    offset' = offset' + 1
    let session_present: Bool = (flags and 0x01) == 1
    if \likely\ version == MqttVersion5 then
      var reason_code: MqttConnectReasonCode =
        match buf(offset')?
        | MqttSuccess() => MqttSuccess
        | MqttUnspecifiedError() => MqttUnspecifiedError
        | MqttMalformedPacket() => MqttMalformedPacket
        | MqttProtocolError() => MqttProtocolError
        | MqttImplementationSpecificError() => MqttImplementationSpecificError
        | MqttUnsupportedProtocolVersion() => MqttUnsupportedProtocolVersion
        | MqttClientIdentifierNotValid() => MqttClientIdentifierNotValid
        | MqttBadUserNameOrPassword5() => MqttBadUserNameOrPassword5
        | MqttNotAuthorized5() => MqttNotAuthorized5
        | MqttServerUnavailable5() => MqttServerUnavailable5
        | MqttServerBusy() => MqttServerBusy
        | MqttBanned() => MqttBanned
        | MqttBadAuthenticationMethod() => MqttBadAuthenticationMethod
        | MqttTopicNameInvalid() => MqttTopicNameInvalid
        | MqttPacketTooLarge() => MqttPacketTooLarge
        | MqttQuotaExceeded() => MqttQuotaExceeded
        | MqttPayloadFormatInvalid() => MqttPayloadFormatInvalid
        | MqttRetainNotSupported() => MqttRetainNotSupported
        | MqttQoSNotSupported() => MqttQoSNotSupported
        | MqttUseAnotherServer() => MqttUseAnotherServer
        | MqttServerMoved() => MqttServerMoved
        | MqttConnectionRateExceeded() => MqttConnectionRateExceeded
        else
          MqttUnspecifiedError
        end
      offset' = offset' + 1
      (let property_length', let property_length_size) = _MqttVariableByteInteger.decode(buf, offset', limit)?
      offset' = offset' + property_length_size
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      var session_expiry_interval: U32 = 0
      var receive_maximum: U16 = 0
      var maximum_qos: Bool = false
      var retain_available: Bool = false
      var maximum_packet_size: U32 = 0
      var assigned_client_identifier: (String | None) = None
      var topic_alias_maximum: U16 = 0
      var reason_string: (String | None) = None
      var user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty] end
      var wildcard_subscription_available: Bool = false
      var subscription_identifier_available: Bool = false
      var shared_subscription_available: Bool = false
      var server_keep_alive: U16 = 0
      var response_information: (String | None) = None
      var server_reference: (String | None) = None
      var authentication_method: (String | None) = None
      var authentication_data: (Array[U8] val | None) = None
      while decoded_length < property_length do
        let identifier = buf(offset' + decoded_length)?
        decoded_length = decoded_length + 1
        match identifier
        | _MqttSessionExpiryInterval() =>
          (let session_expiry_interval', let session_expiry_interval_size) = _MqttSessionExpiryInterval.decode(buf, offset' + decoded_length, limit)?
          session_expiry_interval = session_expiry_interval'
          decoded_length = decoded_length + session_expiry_interval_size
        | _MqttReceiveMaximum() =>
          (let receive_maximum', let receive_maximum_size) = _MqttReceiveMaximum.decode(buf, offset' + decoded_length, limit)?
          receive_maximum = receive_maximum'
          decoded_length = decoded_length + receive_maximum_size
        | _MqttMaximumQoS() =>
          (let maximum_qos', let maximum_qos_size) = _MqttMaximumQoS.decode(buf, offset' + decoded_length, limit)?
          maximum_qos = maximum_qos'
          decoded_length = decoded_length + maximum_qos_size
        | _MqttRetainAvailable() =>
          (let retain_available', let retain_available_size) = _MqttRetainAvailable.decode(buf, offset' + decoded_length, limit)?
          retain_available = retain_available'
          decoded_length = decoded_length + retain_available_size
        | _MqttMaximumPacketSize() =>
          (let maximum_packet_size', let maximum_packet_size_size) = _MqttMaximumPacketSize.decode(buf, offset' + decoded_length, limit)?
          maximum_packet_size = maximum_packet_size'
          decoded_length = decoded_length + maximum_packet_size_size
        | _MqttAssignedClientIdentifier() =>
          (let assigned_client_identifier', let assigned_client_identifier_size) = _MqttAssignedClientIdentifier.decode(buf, offset' + decoded_length, limit)?
          assigned_client_identifier = consume assigned_client_identifier'
          decoded_length = decoded_length + assigned_client_identifier_size
        | _MqttTopicAliasMaximum() =>
          (let topic_alias_maximum', let topic_alias_maximum_size) = _MqttTopicAliasMaximum.decode(buf, offset' + decoded_length, limit)?
          topic_alias_maximum = topic_alias_maximum'
          decoded_length = decoded_length + topic_alias_maximum_size
        | _MqttReasonString() =>
          (let reason_string', let reason_string_size) = _MqttReasonString.decode(buf, offset' + decoded_length, limit)?
          reason_string = consume reason_string'
          decoded_length = decoded_length + reason_string_size
        | _MqttUserProperty() =>
          ((let key, let value), let user_property_size) = _MqttUserProperty.decode(buf, offset' + decoded_length, limit)?
          user_properties.push((consume key, consume value))
          decoded_length = decoded_length + user_property_size
        | _MqttWildcardSubscriptionAvailable() =>
          (let wildcard_subscription_available', let wildcard_subscription_available_size) = _MqttWildcardSubscriptionAvailable.decode(buf, offset' + decoded_length, limit)?
          wildcard_subscription_available = wildcard_subscription_available'
          decoded_length = decoded_length + wildcard_subscription_available_size
        | _MqttSubscriptionIdentifierAvailable() =>
          (let subscription_identifier_available', let subscription_identifier_available_size) = _MqttSubscriptionIdentifierAvailable.decode(buf, offset' + decoded_length, limit)?
          subscription_identifier_available = subscription_identifier_available'
          decoded_length = decoded_length + subscription_identifier_available_size
        | _MqttSharedSubscriptionAvailable() =>
          (let shared_subscription_available', let shared_subscription_available_size) = _MqttSharedSubscriptionAvailable.decode(buf, offset' + decoded_length, limit)?
          shared_subscription_available = shared_subscription_available'
          decoded_length = decoded_length + shared_subscription_available_size
        | _MqttServerKeepAlive() =>
          (let server_keep_alive', let server_keep_alive_size) = _MqttServerKeepAlive.decode(buf, offset' + decoded_length, limit)?
          server_keep_alive = server_keep_alive'
          decoded_length = decoded_length + server_keep_alive_size
        | _MqttResponseInformation() =>
          (let response_information', let response_information_size) = _MqttResponseInformation.decode(buf, offset' + decoded_length, limit)?
          response_information = consume response_information'
          decoded_length = decoded_length + response_information_size
        | _MqttServerReference() =>
          (let server_reference', let server_reference_size) = _MqttServerReference.decode(buf, offset' + decoded_length, limit)?
          server_reference = consume server_reference'
          decoded_length = decoded_length + server_reference_size
        | _MqttAuthenticationMethod() =>
          (let authentication_method', let authentication_method_size) = _MqttAuthenticationMethod.decode(buf, offset' + decoded_length, limit)?
          authentication_method = consume authentication_method'
          decoded_length = decoded_length + authentication_method_size
        | _MqttAuthenticationData() =>
          (let authentication_data', let authentication_data_size) = _MqttAuthenticationData.decode(buf, offset' + decoded_length, limit)?
          authentication_data = consume authentication_data'
          decoded_length = decoded_length + authentication_data_size
        end
      end
      return MqttConnAck.build(
        session_present,
        reason_code,
        MqttUnacceptableProtocolVersion,
        session_expiry_interval,
        receive_maximum,
        maximum_qos,
        retain_available,
        maximum_packet_size,
        assigned_client_identifier,
        topic_alias_maximum,
        reason_string,
        consume user_properties,
        wildcard_subscription_available,
        subscription_identifier_available,
        shared_subscription_available,
        server_keep_alive,
        response_information,
        server_reference,
        authentication_method,
        authentication_data
      )
    else
      var return_code: MqttConnectReturnCode =
        match buf(offset')?
        | MqttConnectionAccepted() => MqttConnectionAccepted
        | MqttUnacceptableProtocolVersion() => MqttUnacceptableProtocolVersion
        | MqttIdentifierRejected() => MqttIdentifierRejected
        | MqttServerUnavailable() => MqttServerUnavailable
        | MqttBadUserNameOrPassword() => MqttBadUserNameOrPassword
        | MqttNotAuthorized() => MqttNotAuthorized
        else
          MqttServerUnavailable
        end
      return MqttConnAck.build(
        session_present,
        MqttProtocolError,
        return_code
      )
    end

primitive _MqttConnAckMeasurer
  fun variable_header_size(
    packet: MqttConnAckPacket,
    version: MqttVersion = MqttVersion5,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 1 // flags
    size = size + 1 // reason code(mqtt-5) or return code (mqtt-3.1.1/mqtt-3.1)
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet, if maximum_packet_size != 0 then maximum_packet_size - size else 0 end)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttConnAckPacket,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 0
    match MqttConnAck.session_expiry_interval(packet)
    | let session_expiry_interval: U32 if session_expiry_interval != 0 =>
      size = size + _MqttSessionExpiryInterval.size(session_expiry_interval)
    end
    match MqttConnAck.receive_maximum(packet)
    | let receive_maximum: U16 if receive_maximum != 0 =>
      size = size + _MqttReceiveMaximum.size(receive_maximum)
    end
    if MqttConnAck.maximum_qos(packet) then
      size = size + _MqttMaximumQoS.size(MqttConnAck.maximum_qos(packet))
    end
    if MqttConnAck.retain_available(packet) then
      size = size + _MqttRetainAvailable.size(MqttConnAck.retain_available(packet))
    end
    match MqttConnAck.maximum_packet_size(packet)
    | let maximum_packet_size': U32 if maximum_packet_size' != 0 =>
      size = size + _MqttMaximumPacketSize.size(maximum_packet_size')
    end
    match MqttConnAck.assigned_client_identifier(packet)
    | let assigned_client_identifier: String val =>
      size = size + _MqttAssignedClientIdentifier.size(assigned_client_identifier)
    end
    match MqttConnAck.topic_alias_maximum(packet)
    | let topic_alias_maximum: U16 if topic_alias_maximum != 0 =>
      size = size + _MqttTopicAliasMaximum.size(topic_alias_maximum)
    end
    if MqttConnAck.wildcard_subscription_available(packet) then
      size = size + _MqttWildcardSubscriptionAvailable.size(MqttConnAck.wildcard_subscription_available(packet))
    end
    if MqttConnAck.subscription_identifier_available(packet) then
      size = size + _MqttSubscriptionIdentifierAvailable.size(MqttConnAck.subscription_identifier_available(packet))
    end
    if MqttConnAck.shared_subscription_available(packet) then
      size = size + _MqttSharedSubscriptionAvailable.size(MqttConnAck.shared_subscription_available(packet))
    end
    match MqttConnAck.server_keep_alive(packet)
    | let server_keep_alive: U16 if server_keep_alive != 0 =>
      size = size + _MqttServerKeepAlive.size(server_keep_alive)
    end
    match MqttConnAck.response_information(packet)
    | let response_information: String val =>
      size = size + _MqttResponseInformation.size(response_information)
    end
    match MqttConnAck.server_reference(packet)
    | let server_reference: String val =>
      size = size + _MqttServerReference.size(server_reference)
    end
    match MqttConnAck.authentication_method(packet)
    | let authentication_method: String val =>
      size = size + _MqttAuthenticationMethod.size(authentication_method)
    end
    match MqttConnAck.authentication_data(packet)
    | let authentication_data: Array[U8] val =>
      size = size + _MqttAuthenticationData.size(authentication_data)
    end

    match MqttConnAck.reason_string(packet)
    | \unlikely\ let reason_string: String val =>
      let length = _MqttReasonString.size(reason_string)
      if (maximum_packet_size != 0) then
        if maximum_packet_size >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    if maximum_packet_size != 0 then
      match MqttConnAck.user_properties(packet)
      | \unlikely\ let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          let property_size = _MqttUserProperty.size(property)
          if maximum_packet_size >= (size + property_size) then
            size = size + property_size
          end
        end
      end
    else
      match MqttConnAck.user_properties(packet)
      | \unlikely\ let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          size = size + _MqttUserProperty.size(property)
        end
      end
    end

    size

primitive _MqttConnAckEncoder
  fun apply(
    packet: MqttConnAckPacket,
    maximum_packet_size: USize = 0,
    remaining: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let total_size = _MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = recover iso Array[U8](total_size) end

    buf.push(MqttConnAck() and 0xF0)
    buf = _MqttVariableByteInteger.encode(consume buf, remaining.ulong())
    buf.push(if MqttConnAck.session_present(packet) then 1 else 0 end)
    if \likely\ version == MqttVersion5 then
      buf.push(MqttConnAck.reason_code(packet)())

      var properties_length: USize = _MqttConnAckMeasurer.properties_size(packet, maximum_packet_size)

      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttConnAck.session_expiry_interval(packet)
      | let session_expiry_interval: U32 if session_expiry_interval != 0 =>
        buf = _MqttSessionExpiryInterval.encode(consume buf, session_expiry_interval)
      end

      match MqttConnAck.receive_maximum(packet)
      | let receive_maximum: U16 if receive_maximum != 0 =>
        buf = _MqttReceiveMaximum.encode(consume buf, receive_maximum)
      end

      if MqttConnAck.maximum_qos(packet) then
        buf = _MqttMaximumQoS.encode(consume buf, true)
      end

      if MqttConnAck.retain_available(packet) then
        buf = _MqttRetainAvailable.encode(consume buf, true)
      end

      match MqttConnAck.maximum_packet_size(packet)
      | let maximum_packet_size': U32 if maximum_packet_size' != 0 =>
        buf = _MqttMaximumPacketSize.encode(consume buf, maximum_packet_size')
      end

      match MqttConnAck.assigned_client_identifier(packet)
      | let assigned_client_identifier: String val =>
        buf = _MqttAssignedClientIdentifier.encode(consume buf, assigned_client_identifier)
      end

      match MqttConnAck.topic_alias_maximum(packet)
      | let topic_alias_maximum: U16 if topic_alias_maximum != 0 =>
        buf = _MqttTopicAliasMaximum.encode(consume buf, topic_alias_maximum)
      end

      if MqttConnAck.wildcard_subscription_available(packet) then
        buf = _MqttWildcardSubscriptionAvailable.encode(consume buf, true)
      end

      if MqttConnAck.subscription_identifier_available(packet) then
        buf = _MqttSubscriptionIdentifierAvailable.encode(consume buf, true)
      end

      if MqttConnAck.shared_subscription_available(packet) then
        buf = _MqttSharedSubscriptionAvailable.encode(consume buf, true)
      end

      match MqttConnAck.server_keep_alive(packet)
      | let server_keep_alive: U16 if server_keep_alive != 0 =>
        buf = _MqttServerKeepAlive.encode(consume buf, server_keep_alive)
      end

      match MqttConnAck.response_information(packet)
      | let response_information: String val =>
        buf = _MqttResponseInformation.encode(consume buf, response_information)
      end

      match MqttConnAck.server_reference(packet)
      | let server_reference: String val =>
        buf = _MqttServerReference.encode(consume buf, server_reference)
      end

      match MqttConnAck.authentication_method(packet)
      | let authentication_method: String val =>
        buf = _MqttAuthenticationMethod.encode(consume buf, authentication_method)
      end

      match MqttConnAck.authentication_data(packet)
      | let authentication_data: Array[U8] val =>
        buf = _MqttAuthenticationData.encode(consume buf, authentication_data)
      end

      match MqttConnAck.reason_string(packet)
      | let reason_string: String val =>
        if (buf.size() + _MqttReasonString.size(reason_string)) <= total_size then
          buf = _MqttReasonString.encode(consume buf, reason_string)
        end
      end

      match MqttConnAck.user_properties(packet)
      | \unlikely\ let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          if (buf.size() + _MqttUserProperty.size(property)) <= total_size then
            buf = _MqttUserProperty.encode(consume buf, property)
          end
        end
      end

    else
      buf.push(MqttConnAck.return_code(packet)())
    end

    consume buf
