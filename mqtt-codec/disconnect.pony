use "buffered"
use "collections"

type MqttDisconnectReasonCode is (MqttNormalDisconnection | MqttDisconnectWithWillMessage | MqttUnspecifiedError | MqttMalformedPacket | MqttProtocolError | MqttImplementationSpecificError | MqttNotAuthorized5 | MqttServerBusy | MqttServerShuttingDown | MqttKeepAliveTimeout | MqttSessionTakenOver | MqttTopicFilterInvalid | MqttTopicNameInvalid | MqttReceiveMaximumExceeded | MqttTopicAliasInvalid | MqttPacketTooLarge | MqttMessageRateTooHigh | MqttMessageRateTooHigh | MqttQuotaExceeded | MqttAdministrativeAction | MqttPayloadFormatInvalid | MqttRetainNotSupported | MqttQoSNotSupported | MqttUseAnotherServer | MqttServerMoved | MqttSharedSubscriptionsNotSupported | MqttConnectionRateExceeded | MqttMaximumConnectTime | MqttSubscriptionIdentifiersNotSupported | MqttWildcardSubscriptionsNotSupported)

class MqttDisconnectPacket
  let reason_code: (MqttDisconnectReasonCode | None)
  """
  The Disconnect Reason Code

  * mqtt-5
  """

  let session_expiry_interval: (U32 | None)
  """
  It represents the Session Expiry Interval in seconds.

  * mqtt-5
  """

  let reason_string: (String | None)
  """
  This Reason String is a human readable string designed for diagnostics and
  SHOULD NOT be parsed by the Client.

  * mqtt-5
  """

  let user_properties: (Map[String, String] | None)
  """
  User Properties on the DISCONNECT packet can be used to send subscription
  related properties from the Client to the Server.

  * mqtt-5
  """

  let server_reference: (String | None)
  """
  It can be used by the Client to identify another Server to use.

  * mqtt-5
  """

  new create(
      reason_code': (MqttDisconnectReasonCode | None) = None,
      session_expiry_interval': (U32 | None) = None,
      reason_string': (String | None) = None,
      user_properties': (Map[String, String] | None) = None,
      server_reference': (String | None) = None
  ) =>
      reason_code = reason_code'
      session_expiry_interval = session_expiry_interval'
      reason_string = reason_string'
      user_properties = user_properties'
      server_reference = server_reference'

class MqttDisconnectDecoder
  fun apply(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttDisconnectPacket] ? =>
    var reason_code: (MqttDisconnectReasonCode | None) = None
    var session_expiry_interval: (U32 | None) = None
    var reason_string: (String | None) = None
    var user_properties: (Map[String, String] | None) = None
    var server_reference: (String | None) = None
    if \likely\ version() == MqttVersion5() then
      if remaining < 1 then
        reason_code = MqttNormalDisconnection
      else
        reason_code =
          match reader.u8() ?
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
        (let property_length', _) = MqttVariableByteInteger.decode_reader(reader) ?
        let property_length = property_length'.usize()
        var decoded_length: USize = 0
        user_properties = Map[String, String]()
        while decoded_length < property_length do
          let identifier = reader.u8() ?
          decoded_length = decoded_length + 1
          match identifier
          | MqttSessionExpiryInterval() =>
            (let session_expiry_interval': U32, let consumed: USize) = MqttSessionExpiryInterval.decode(reader) ?
            session_expiry_interval = session_expiry_interval'
            decoded_length = decoded_length + consumed
          | MqttReasonString() =>
            (let reason_string': String, let consumed: USize) = MqttReasonString.decode(reader) ?
            reason_string = reason_string'
            decoded_length = decoded_length + consumed
          | MqttUserProperty() =>
            (let user_property': (String, String), let consumed: USize) = MqttUserProperty.decode(reader) ?
            try (user_properties as Map[String, String]).insert(user_property'._1, user_property'._2) end
            decoded_length = decoded_length + consumed
          | MqttServerReference() =>
            (let server_reference': String, let consumed: USize) = MqttServerReference.decode(reader) ?
            server_reference = server_reference'
            decoded_length = decoded_length + consumed
          end
        end
      end
    end
    let packet =
      MqttDisconnectPacket(
        reason_code,
        session_expiry_interval,
        reason_string,
        user_properties,
        server_reference
      )
    (MqttDecodeDone, packet)

primitive MqttDisconnectMeasurer
  fun variable_header_size(data: MqttDisconnectPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): USize val =>
    """
    The Reason Code and Property Length can be omitted if the Reason Code is
    0x00 (Normal disconnecton) and there are no Properties. In this case the
    DISCONNECT has a Variable Header Size of 0.
    """
    var size: USize = 0
    if \likely\ version() == MqttVersion5() then
      size = 1 // reason code
      let properties_length = properties_size(data, try (maximum_packet_size as USize) - size else None end)
      if properties_length == 0 then
        match data.reason_code
        | let reason_code: MqttDisconnectReasonCode =>
          if reason_code() == MqttNormalDisconnection() then
            return 0
          end
        else
          return 0
        end
      end
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(data: MqttDisconnectPacket box, maximum_packet_size: (USize | None) = None): USize val =>
    var size: USize = 0

    size = size +
        match data.session_expiry_interval
        | let session_expiry_interval: U32 =>
          MqttSessionExpiryInterval.size(session_expiry_interval)
        else
          0
        end

    size = size +
        match data.server_reference
        | let server_reference: String =>
          MqttServerReference.size(server_reference)
        else
          0
        end

    match data.reason_string
    | let reason_string: String =>
      let length = MqttReasonString.size(reason_string)
      match maximum_packet_size
      | let maximum_packet_size': USize =>
        if (size + length) <= maximum_packet_size' then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match data.user_properties
    | let user_properties: Map[String, String] box =>
      match maximum_packet_size
      | let maximum_packet_size': USize =>
        for item in user_properties.pairs() do
          let item_size = MqttUserProperty.size(item)
          if (size + item_size) <= maximum_packet_size' then
            size = size + item_size
          else
            break
          end
        end
      else
        for item in user_properties.pairs() do
          size = size + MqttUserProperty.size(item)
        end
      end
    end

    size

primitive MqttDisconnectEncoder
  fun apply(data: MqttDisconnectPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    var maximum_size: (USize | None) = None
    var remaining: USize = 0
    match maximum_packet_size
    | let maximum_packet_size': USize =>
      var maximum: USize = maximum_packet_size' - 1 - 1
      remaining = MqttDisconnectMeasurer.variable_header_size(data, maximum, version)
      var remaining_length = MqttVariableByteInteger.size(remaining.ulong())
      maximum = maximum - remaining_length
      var delta: USize = 0
      repeat
        maximum = maximum - delta
        let remaining': USize = MqttDisconnectMeasurer.variable_header_size(data, maximum, version)
        let remaining_length': USize = MqttVariableByteInteger.size(remaining'.ulong())
        delta = remaining_length - remaining_length'
        remaining = remaining'
        remaining_length = remaining_length'
      until delta == 0 end
      maximum_size = maximum
    else
      remaining = MqttDisconnectMeasurer.variable_header_size(data, None, version)
    end

    let total_size = MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf' = recover iso Array[U8](total_size) end
    var buf: Array[U8] trn^ = consume buf'

    buf.push(MqttDisconnect() and 0xF0)
    MqttVariableByteInteger.encode(buf, remaining.ulong())

    if \likely\ version() == MqttVersion5() then
      match data.reason_code
      | let reason_code: MqttDisconnectReasonCode =>
        buf.push(reason_code())
      else
        buf.push(MqttNormalDisconnection())
      end

      var properties_length: USize = MqttDisconnectMeasurer.properties_size(data, maximum_size)
      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.session_expiry_interval
      | let session_expiry_interval: U32 =>
        MqttSessionExpiryInterval.encode(buf, session_expiry_interval)
      end

      match data.server_reference
      | let server_reference: String =>
        MqttServerReference.encode(buf, server_reference)
      end

      match data.reason_string
      | let reason_string: String =>
        if (buf.size() + MqttReasonString.size(reason_string)) <= total_size then
          MqttReasonString.encode(buf, reason_string)
        end
      end

      match data.user_properties
      | let user_properties: Map[String, String] box =>
        for item in user_properties.pairs() do
          if (buf.size() + MqttUserProperty.size(item)) <= total_size then
            MqttUserProperty.encode(buf, item)
          end
        end
      end
    end

    buf
