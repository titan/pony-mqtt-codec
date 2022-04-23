use "collections"

type MqttDisconnectReasonCode is
  ( MqttNormalDisconnection
  | MqttDisconnectWithWillMessage
  | MqttUnspecifiedError
  | MqttMalformedPacket
  | MqttProtocolError
  | MqttImplementationSpecificError
  | MqttNotAuthorized5
  | MqttServerBusy
  | MqttServerShuttingDown
  | MqttKeepAliveTimeout
  | MqttSessionTakenOver
  | MqttTopicFilterInvalid
  | MqttTopicNameInvalid
  | MqttReceiveMaximumExceeded
  | MqttTopicAliasInvalid
  | MqttPacketTooLarge
  | MqttMessageRateTooHigh
  | MqttMessageRateTooHigh
  | MqttQuotaExceeded
  | MqttAdministrativeAction
  | MqttPayloadFormatInvalid
  | MqttRetainNotSupported
  | MqttQoSNotSupported
  | MqttUseAnotherServer
  | MqttServerMoved
  | MqttSharedSubscriptionsNotSupported
  | MqttConnectionRateExceeded
  | MqttMaximumConnectTime
  | MqttSubscriptionIdentifiersNotSupported
  | MqttWildcardSubscriptionsNotSupported
  )

type MqttDisconnectPacket is
  ( MqttDisconnectReasonCode // 1. reason_code
  , U32 // 2. session_expiry_interval
  , (String val | None) // 3. reason_string
  , (Array[MqttUserProperty] val | None) // 4. user_properties
  , (String val | None) // 5. server_reference
  )


primitive MqttDisconnect
  """
  Disconnect notification

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0xE0

  fun reason_code(
    packet: MqttDisconnectPacket)
  : MqttDisconnectReasonCode =>
    """
    The Disconnect Reason Code

    * mqtt-5
    """
    packet._1

  fun session_expiry_interval(
    packet: MqttDisconnectPacket)
  : U32 =>
    """
    It represents the Session Expiry Interval in seconds.

    * mqtt-5
    """
    packet._2

  fun reason_string(
    packet: MqttDisconnectPacket)
  : (String val | None) =>
    """
    This Reason String is a human readable string designed for diagnostics and
    SHOULD NOT be parsed by the Client.

    * mqtt-5
    """
    packet._3

  fun user_properties(
    packet: MqttDisconnectPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    User Properties on the DISCONNECT packet can be used to send subscription
    related properties from the Client to the Server.

    * mqtt-5
    """
    packet._4

  fun server_reference(
    packet: MqttDisconnectPacket)
  : (String val | None) =>
    """
    It can be used by the Client to identify another Server to use.

    * mqtt-5
    """
    packet._5

  fun build(
    reason_code': MqttDisconnectReasonCode = MqttNormalDisconnection,
    session_expiry_interval': U32 = 0,
    reason_string': (String val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None,
    server_reference': (String val | None) = None)
  : MqttDisconnectPacket =>
    ( reason_code'
    , session_expiry_interval'
    , reason_string'
    , user_properties'
    , server_reference'
    )

primitive _MqttDisconnectDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttDisconnect(),
    version: MqttVersion = MqttVersion5)
  : MqttDisconnectPacket? =>
    var offset' = offset
    var reason_code: MqttDisconnectReasonCode = MqttNormalDisconnection
    var session_expiry_interval: U32 = 0
    var reason_string: (String | None) = None
    var user_properties: (Array[MqttUserProperty] iso | None) = None
    var server_reference: (String | None) = None
    if \likely\ version == MqttVersion5 then
      if (limit - offset) == 0 then
        reason_code = MqttNormalDisconnection
      else
        reason_code =
          match buf(offset')?
          | MqttNormalDisconnection() => MqttNormalDisconnection
          | MqttDisconnectWithWillMessage() => MqttDisconnectWithWillMessage
          | MqttUnspecifiedError() => MqttUnspecifiedError
          | MqttMalformedPacket() => MqttMalformedPacket
          | MqttProtocolError() => MqttProtocolError
          | MqttImplementationSpecificError() => MqttImplementationSpecificError
          | MqttNotAuthorized5() => MqttNotAuthorized5
          | MqttServerBusy() => MqttServerBusy
          | MqttServerShuttingDown() => MqttServerShuttingDown
          | MqttKeepAliveTimeout() => MqttKeepAliveTimeout
          | MqttSessionTakenOver() => MqttSessionTakenOver
          | MqttTopicFilterInvalid() => MqttTopicFilterInvalid
          | MqttTopicNameInvalid() => MqttTopicNameInvalid
          | MqttReceiveMaximumExceeded() => MqttReceiveMaximumExceeded
          | MqttTopicAliasInvalid() => MqttTopicAliasInvalid
          | MqttPacketTooLarge() => MqttPacketTooLarge
          | MqttMessageRateTooHigh() => MqttMessageRateTooHigh
          | MqttMessageRateTooHigh() => MqttMessageRateTooHigh
          | MqttQuotaExceeded() => MqttQuotaExceeded
          | MqttAdministrativeAction() => MqttAdministrativeAction
          | MqttPayloadFormatInvalid() => MqttPayloadFormatInvalid
          | MqttRetainNotSupported() => MqttRetainNotSupported
          | MqttQoSNotSupported() => MqttQoSNotSupported
          | MqttUseAnotherServer() => MqttUseAnotherServer
          | MqttServerMoved() => MqttServerMoved
          | MqttSharedSubscriptionsNotSupported() => MqttSharedSubscriptionsNotSupported
          | MqttConnectionRateExceeded() => MqttConnectionRateExceeded
          | MqttMaximumConnectTime() => MqttMaximumConnectTime
          | MqttSubscriptionIdentifiersNotSupported() => MqttSubscriptionIdentifiersNotSupported
          | MqttWildcardSubscriptionsNotSupported() => MqttWildcardSubscriptionsNotSupported
          else
            MqttUnspecifiedError
          end
        offset' = offset' + 1
        (let property_length', let property_length_size) = _MqttVariableByteInteger.decode(buf, offset')?
        offset' = offset' + property_length_size
        let property_length = property_length'.usize()
        var decoded_length: USize = 0
        user_properties = recover iso Array[MqttUserProperty] end
        while decoded_length < property_length do
          let identifier = buf(offset' + decoded_length)?
          decoded_length = decoded_length + 1
          match identifier
          | _MqttSessionExpiryInterval() =>
            (let session_expiry_interval': U32, let session_expiry_interval_size: USize) = _MqttSessionExpiryInterval.decode(buf, offset' + decoded_length)?
            session_expiry_interval = session_expiry_interval'
            decoded_length = decoded_length + session_expiry_interval_size
          | _MqttReasonString() =>
            (let reason_string': String, let reason_string_size: USize) = _MqttReasonString.decode(buf, offset' + decoded_length)?
            reason_string = reason_string'
            decoded_length = decoded_length + reason_string_size
          | _MqttUserProperty() =>
            (let user_property: MqttUserProperty, let user_property_size: USize) = _MqttUserProperty.decode(buf, offset' + decoded_length)?
            try (user_properties as Array[MqttUserProperty]).push(user_property) end
            decoded_length = decoded_length + user_property_size
          | _MqttServerReference() =>
            (let server_reference': String, let server_reference_size: USize) = _MqttServerReference.decode(buf, offset' + decoded_length)?
            server_reference = server_reference'
            decoded_length = decoded_length + server_reference_size
          end
        end
        offset' = offset' + decoded_length
      end
    end
    MqttDisconnect.build(
      reason_code,
      session_expiry_interval,
      reason_string,
      consume user_properties,
      server_reference
    )

primitive _MqttDisconnectMeasurer
  fun variable_header_size(
    packet: MqttDisconnectPacket,
    version: MqttVersion = MqttVersion5,
    maximum_packet_size: USize = 0)
  : USize =>
    """
    The Reason Code and Property Length can be omitted if the Reason Code is
    0x00 (Normal disconnecton) and there are no Properties. In this case the
    DISCONNECT has a Variable Header Size of 0.
    """
    var size: USize = 0
    if \likely\ version == MqttVersion5 then
      size = 1 // reason code
      let properties_length = properties_size(packet, if maximum_packet_size != 0 then maximum_packet_size - size else 0 end)
      if properties_length == 0 then
        if MqttDisconnect.reason_code(packet)() == MqttNormalDisconnection() then
          return 0
        end
      end
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttDisconnectPacket,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 0

    match MqttDisconnect.session_expiry_interval(packet)
    | let session_expiry_interval: U32 if session_expiry_interval != 0 =>
      size = size + _MqttSessionExpiryInterval.size(session_expiry_interval)
    end

    match MqttDisconnect.server_reference(packet)
    | let server_reference: String val =>
      size = size + _MqttServerReference.size(server_reference)
    end

    match MqttDisconnect.reason_string(packet)
    | let reason_string: String val =>
      let length = _MqttReasonString.size(reason_string)
      if maximum_packet_size != 0 then
        if maximum_packet_size >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match MqttDisconnect.user_properties(packet)
    | let user_properties: Array[MqttUserProperty] val =>
      if maximum_packet_size != 0 then
        for property in user_properties.values() do
          let property_size = _MqttUserProperty.size(property)
          if maximum_packet_size >= (size + property_size) then
            size = size + property_size
          else
            break
          end
        end
      else
        for property in user_properties.values() do
          size = size + _MqttUserProperty.size(property)
        end
      end
    end

    size

primitive _MqttDisconnectEncoder
  fun apply(
    packet: MqttDisconnectPacket,
    maximum_packet_size: USize = 0,
    remaining: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let total_size = _MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = recover iso Array[U8](total_size) end

    buf.push(MqttDisconnect() and 0xF0)
    buf = _MqttVariableByteInteger.encode(consume buf, remaining.ulong())

    if \likely\ version == MqttVersion5 then
      var properties_length: USize = _MqttDisconnectMeasurer.properties_size(packet, maximum_packet_size)

      if (MqttDisconnect.reason_code(packet)() == MqttNormalDisconnection()) and (properties_length == 0) then
        return consume buf
      end
      buf.push(MqttDisconnect.reason_code(packet)())

      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttDisconnect.session_expiry_interval(packet)
      | let session_expiry_interval: U32 if session_expiry_interval != 0 =>
        buf = _MqttSessionExpiryInterval.encode(consume buf, session_expiry_interval)
      end

      match MqttDisconnect.server_reference(packet)
      | let server_reference: String val =>
        buf = _MqttServerReference.encode(consume buf, server_reference)
      end

      match MqttDisconnect.reason_string(packet)
      | let reason_string: String val =>
        if (buf.size() + _MqttReasonString.size(reason_string)) <= total_size then
          buf = _MqttReasonString.encode(consume buf, reason_string)
        end
      end

      match MqttDisconnect.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          if (buf.size() + _MqttUserProperty.size(property)) <= total_size then
            buf = _MqttUserProperty.encode(consume buf, property)
          end
        end
      end
    end

    consume buf
