use "buffered"
use "collections"

type MqttConnectReasonCode is (MqttSuccess | MqttUnspecifiedError | MqttMalformedPacket | MqttProtocolError | MqttImplementationSpecificError | MqttUnsupportedProtocolVersion | MqttClientIdentifierNotValid | MqttBadUserNameOrPassword5 | MqttNotAuthorized5 | MqttServerUnavailable5 | MqttServerBusy | MqttBanned | MqttBadAuthenticationMethod | MqttTopicNameInvalid | MqttPacketTooLarge | MqttQuotaExceeded | MqttPayloadFormatInvalid | MqttRetainNotSupported | MqttQoSNotSupported | MqttUseAnotherServer | MqttServerMoved | MqttConnectionRateExceeded)

class MqttConnAckPacket
  let session_present: Bool val
  """
  The Session Present flag informs the Client whether the Server is using
  Session State from a previous connection for this ClientID. This allows the
  Client and Server to have a consistent view of the Session State.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let reason_code: (MqttConnectReasonCode val | None)
  """
  If a well formed CONNECT packet is received by the Server, but the Server is
  unable to complete the Connection the Server MAY send a CONNACK packet
  containing the appropriate Connect Reason code.

  * mqtt-5
  """

  let return_code: (MqttConnectReturnCode val | None)
  """
  If a well formed CONNECT Packet is received by the Server, but the Server is
  unable to process it for some reason, then the Server SHOULD attempt to send
  a CONNACK packet containing the appropriate non-zero Connect return code.

  * mqtt-3.1.1
  * mqtt-3.1
  """

  let session_expiry_interval: (U32 val | None)
  """
  When the Session expires the Client and Server need not process the deletion
  of state atomically.

  * mqtt-5
  """

  let receive_maximum: (U16 val | None)
  """
  The Client uses this value to limit the number of QoS 1 and QoS 2
  publications that it is willing to process concurrently.

  * mqtt-5
  """

  let maximum_qos: (Bool val | None)
  """
  The Server uses this value to specify the highest QoS it supports.

  * mqtt-5
  """

  let retain_available: (Bool val | None)
  """
  A value of 0 means that retained messages are not supported. A value of 1
  means retained messages are supported.

  * mqtt-5
  """

  let maximum_packet_size: (U32 val | None)
  """
  The Server uses the Maximum Packet Size to inform the Client that it will not
  process packets whose size exceeds this limit.

  * mqtt-5
  """

  let assigned_client_identifier: (String val | None)
  """
  The Client Identifier which was assigned by the Server because a zero length
  Client Identifier was found in the CONNECT packet.

  * mqtt-5
  """

  let topic_alias_maximum: (U16 val | None)
  """
  This value indicates the highest value that the Server will accept as a Topic
  Alias sent by the Client. The Server uses this value to limit the number of
  Topic Aliases that it is willing to hold on this Connection.

  * mqtt-5
  """

  let reason_string: (String val | None)
  """
  The Server uses this value to give additional information to the Client.

  * mqtt-5
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  This property can be used to provide additional information to the Client
  including diagnostic information.

  * mqtt-5
  """

  let wildcard_subscription_available: (Bool val | None)
  """
  This property declares whether the Server supports Wildcard Subscriptions.

  * mqtt-5
  """

  let subscription_identifier_available: (Bool val | None)
  """
  This property declares whether the Server supports Subscription Identifiers.

  * mqtt-5
  """

  let shared_subscription_available: (Bool val | None)
  """
  This property declares whether the Server supports Shared Subscriptions.

  * mqtt-5
  """

  let server_keep_alive: (U16 val | None)
  """
  This property declares the Keep Alive time assigned by the Server.

  * mqtt-5
  """

  let response_information: (String val | None)
  """
  This property is used as the basis for creating a Response Topic.

  * mqtt-5
  """

  let server_reference: (String val | None)
  """
  This property can be used by the Client to identify another Server to use.

  * mqtt-5
  """

  let authentication_method: (String val | None)
  """
  This property contains the name of the authentication method.

  * mqtt-5
  """

  let authentication_data: (Array[U8 val] val | None)
  """
  This property contains authentication data. The contents of this data are
  defined by the authentication method and the state of already exchanged
  authentication data.

  * mqtt-5
  """

  new iso create(
    session_present': Bool val,
    reason_code': (MqttConnectReasonCode val | None) = None,
    return_code': (MqttConnectReturnCode val | None) = None,
    session_expiry_interval': (U32 val | None) = None,
    receive_maximum': (U16 val | None) = None,
    maximum_qos': (Bool val | None) = None,
    retain_available': (Bool val | None) = None,
    maximum_packet_size': (U32 val | None) = None,
    assigned_client_identifier': (String val | None) = None,
    topic_alias_maximum': (U16 val | None) = None,
    reason_string': (String val | None) = None,
    user_properties': (Map[String val, String val] val | None) = None,
    wildcard_subscription_available': (Bool val | None) = None,
    subscription_identifier_available': (Bool val | None) = None,
    shared_subscription_available': (Bool val | None) = None,
    server_keep_alive': (U16 val | None) = None,
    response_information': (String val | None) = None,
    server_reference': (String val | None) = None,
    authentication_method': (String val | None) = None,
    authentication_data': (Array[U8 val] val | None) = None
  ) =>
    session_present = session_present'
    reason_code = reason_code'
    return_code = return_code'
    session_expiry_interval = session_expiry_interval'
    receive_maximum = receive_maximum'
    maximum_qos = maximum_qos'
    retain_available = retain_available'
    maximum_packet_size = maximum_packet_size'
    assigned_client_identifier = assigned_client_identifier'
    topic_alias_maximum = topic_alias_maximum'
    reason_string = reason_string'
    user_properties = user_properties'
    wildcard_subscription_available = wildcard_subscription_available'
    subscription_identifier_available = subscription_identifier_available'
    shared_subscription_available = shared_subscription_available'
    server_keep_alive = server_keep_alive'
    response_information = response_information'
    server_reference = server_reference'
    authentication_method = authentication_method'
    authentication_data = authentication_data'

primitive MqttConnAckDecoder
  fun apply(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttConnAckPacket val] val ? =>
    let flags = reader.u8() ?
    let session_present: Bool = (flags and 0x01) == 1
    if \likely\ version() == MqttVersion5() then
      var reason_code: MqttConnectReasonCode val =
        match reader.u8() ?
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
      (let property_length', _) = MqttVariableByteInteger.decode_reader(reader) ?
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      var session_expiry_interval: (U32 | None) = None
      var receive_maximum: (U16 | None) = None
      var maximum_qos: (Bool | None) = None
      var retain_available: (Bool | None) = None
      var maximum_packet_size: (U32 | None) = None
      var assigned_client_identifier: (String | None) = None
      var topic_alias_maximum: (U16 | None) = None
      var reason_string: (String | None) = None
      var user_properties: Map[String val, String val] iso = recover iso Map[String val, String val] end
      var wildcard_subscription_available: (Bool | None) = None
      var subscription_identifier_available: (Bool | None) = None
      var shared_subscription_available: (Bool | None) = None
      var server_keep_alive: (U16 | None) = None
      var response_information: (String | None) = None
      var server_reference: (String | None) = None
      var authentication_method: (String | None) = None
      var authentication_data: (Array[U8 val] val | None) = None
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
        | MqttMaximumQoS() =>
          (let maximum_qos', let consumed) = MqttMaximumQoS.decode(reader) ?
          maximum_qos = maximum_qos'
          decoded_length = decoded_length + consumed
        | MqttRetainAvailable() =>
          (let retain_available', let consumed) = MqttRetainAvailable.decode(reader) ?
          retain_available = retain_available'
          decoded_length = decoded_length + consumed
        | MqttMaximumPacketSize() =>
          (let maximum_packet_size', let consumed) = MqttMaximumPacketSize.decode(reader) ?
          maximum_packet_size = maximum_packet_size'
          decoded_length = decoded_length + consumed
        | MqttAssignedClientIdentifier() =>
          (let assigned_client_identifier', let consumed) = MqttAssignedClientIdentifier.decode(reader) ?
          assigned_client_identifier = assigned_client_identifier'
          decoded_length = decoded_length + consumed
        | MqttTopicAliasMaximum() =>
          (let topic_alias_maximum', let consumed) = MqttTopicAliasMaximum.decode(reader) ?
          topic_alias_maximum = topic_alias_maximum'
          decoded_length = decoded_length + consumed
        | MqttReasonString() =>
          (let reason_string', let consumed) = MqttReasonString.decode(reader) ?
          reason_string = reason_string'
          decoded_length = decoded_length + consumed
        | MqttUserProperty() =>
          (let user_property', let consumed) = MqttUserProperty.decode(reader) ?
          user_properties.insert(user_property'._1, user_property'._2)
          decoded_length = decoded_length + consumed
        | MqttWildcardSubscriptionAvailable() =>
          (let wildcard_subscription_available', let consumed) = MqttWildcardSubscriptionAvailable.decode(reader) ?
          wildcard_subscription_available = wildcard_subscription_available'
          decoded_length = decoded_length + consumed
        | MqttSubscriptionIdentifierAvailable() =>
          (let subscription_identifier_available', let consumed) = MqttSubscriptionIdentifierAvailable.decode(reader) ?
          subscription_identifier_available = subscription_identifier_available'
          decoded_length = decoded_length + consumed
        | MqttSharedSubscriptionAvailable() =>
          (let shared_subscription_available', let consumed) = MqttSharedSubscriptionAvailable.decode(reader) ?
          shared_subscription_available = shared_subscription_available'
          decoded_length = decoded_length + consumed
        | MqttServerKeepAlive() =>
          (let server_keep_alive', let consumed) = MqttServerKeepAlive.decode(reader) ?
          server_keep_alive = server_keep_alive'
          decoded_length = decoded_length + consumed
        | MqttResponseInformation() =>
          (let response_information', let consumed) = MqttResponseInformation.decode(reader) ?
          response_information = response_information'
          decoded_length = decoded_length + consumed
        | MqttServerReference() =>
          (let server_reference', let consumed) = MqttServerReference.decode(reader) ?
          server_reference = server_reference'
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
      let packet = MqttConnAckPacket(
        session_present,
        reason_code,
        None,
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
      (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)
    else
      var return_code: MqttConnectReturnCode =
        match reader.u8() ?
        | MqttConnectionAccepted() => MqttConnectionAccepted
        | MqttUnacceptableProtocolVersion() => MqttUnacceptableProtocolVersion
        | MqttIdentifierRejected() => MqttIdentifierRejected
        | MqttServerUnavailable() => MqttServerUnavailable
        | MqttBadUserNameOrPassword() => MqttBadUserNameOrPassword
        | MqttNotAuthorized() => MqttNotAuthorized
        else
          MqttServerUnavailable
        end
      let packet = MqttConnAckPacket(
        session_present,
        None,
        return_code
      )
      (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)
    end

primitive MqttConnAckMeasurer
  fun variable_header_size(data: MqttConnAckPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): USize val =>
    var size: USize = 1 // flags
    size = size + 1 // reason code(mqtt-5) or return code (mqtt-3.1.1/mqtt-3.1)
    if \likely\ version() == MqttVersion5() then
      let properties_length = properties_size(data, try (maximum_packet_size as USize box) - size else None end)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(data: MqttConnAckPacket box, maximum_packet_size: (USize box | None) = None): USize val =>
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
        match data.maximum_qos
        | let maximum_qos: Bool box =>
          MqttMaximumQoS.size(maximum_qos)
        else
          0
        end
    size = size +
        match data.retain_available
        | let retain_available: Bool box =>
          MqttRetainAvailable.size(retain_available)
        else
          0
        end
    size = size +
        match data.maximum_packet_size
        | let maximum_packet_size': U32 box =>
          MqttMaximumPacketSize.size(maximum_packet_size')
        else
          0
        end
    size = size +
        match data.assigned_client_identifier
        | let assigned_client_identifier: String box =>
          MqttAssignedClientIdentifier.size(assigned_client_identifier)
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
        match data.wildcard_subscription_available
        | let wildcard_subscription_available: Bool box =>
          MqttWildcardSubscriptionAvailable.size(wildcard_subscription_available)
        else
          0
        end
    size = size +
        match data.subscription_identifier_available
        | let subscription_identifier_available: Bool box =>
          MqttSubscriptionIdentifierAvailable.size(subscription_identifier_available)
        else
          0
        end
    size = size +
        match data.shared_subscription_available
        | let shared_subscription_available: Bool box =>
          MqttSharedSubscriptionAvailable.size(shared_subscription_available)
        else
          0
        end
    size = size +
        match data.server_keep_alive
        | let server_keep_alive: U16 box =>
          MqttServerKeepAlive.size(server_keep_alive)
        else
          0
        end
    size = size +
        match data.response_information
        | let response_information: String box =>
          MqttResponseInformation.size(response_information)
        else
          0
        end
    size = size +
        match data.server_reference
        | let server_reference: String box =>
          MqttServerReference.size(server_reference)
        else
          0
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
    match data.reason_string
    | \unlikely\ let reason_string: String box =>
      let length = MqttReasonString.size(reason_string)
      match maximum_packet_size
      | \unlikely\ let maximum_packet_size': USize box =>
        if maximum_packet_size' >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match maximum_packet_size
    | \unlikely\ let maximum_packet_size': USize box =>
      match data.user_properties
      | \unlikely\ let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          let item_size = MqttUserProperty.size(item)
          if maximum_packet_size' >= (size + item_size) then
            size = size + item_size
          end
        end
      end
    else
      match data.user_properties
      | \unlikely\ let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          size = size + MqttUserProperty.size(item)
        end
      end
    end

    size

primitive MqttConnAckEncoder
  fun apply(data: MqttConnAckPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    var maximum_size: (USize | None) = None
    var remaining: USize = 0
    match maximum_packet_size
    | let maximum_packet_size': USize box =>
      var maximum: USize = maximum_packet_size' - 1 - 1
      remaining = MqttConnAckMeasurer.variable_header_size(data, maximum, version)
      var remaining_length = MqttVariableByteInteger.size(remaining.ulong())
      maximum = maximum - remaining_length
      var delta: USize = 0
      repeat
        maximum = maximum - delta
        let remaining': USize = MqttConnAckMeasurer.variable_header_size(data, maximum, version)
        let remaining_length': USize = MqttVariableByteInteger.size(remaining'.ulong())
        delta = remaining_length - remaining_length'
        remaining = remaining'
        remaining_length = remaining_length'
      until delta == 0 end
      maximum_size = maximum
    else
      remaining = MqttConnAckMeasurer.variable_header_size(data, None, version)
    end

    let total_size = MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf' = recover iso Array[U8 val](total_size) end
    var buf: Array[U8 val] trn^ = consume buf'

    buf.push(MqttConnAck() and 0xF0)
    MqttVariableByteInteger.encode(buf, remaining.ulong())
    buf.push(if data.session_present then 1 else 0 end)
    if \likely\ version() == MqttVersion5() then
      match data.reason_code
      | let reason_code: MqttConnectReasonCode =>
        buf.push(reason_code())
      else
        buf.push(MqttUnspecifiedError())
      end

      var properties_length: USize = MqttConnAckMeasurer.properties_size(data, maximum_size)

      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.session_expiry_interval
      | let session_expiry_interval: U32 box =>
        MqttSessionExpiryInterval.encode(buf, session_expiry_interval)
      end

      match data.receive_maximum
      | let receive_maximum: U16 box =>
        MqttReceiveMaximum.encode(buf, receive_maximum)
      end

      match data.maximum_qos
      | let maximum_qos: Bool box =>
        MqttMaximumQoS.encode(buf, maximum_qos)
      end

      match data.retain_available
      | let retain_available: Bool box =>
        MqttRetainAvailable.encode(buf, retain_available)
      end

      match data.maximum_packet_size
      | let maximum_packet_size': U32 box =>
        MqttMaximumPacketSize.encode(buf, maximum_packet_size')
      end

      match data.assigned_client_identifier
      | let assigned_client_identifier: String box =>
        MqttAssignedClientIdentifier.encode(buf, assigned_client_identifier)
      end

      match data.topic_alias_maximum
      | let topic_alias_maximum: U16 box =>
        MqttTopicAliasMaximum.encode(buf, topic_alias_maximum)
      end

      match data.wildcard_subscription_available
      | let wildcard_subscription_available: Bool box =>
        MqttWildcardSubscriptionAvailable.encode(buf, wildcard_subscription_available)
      end

      match data.subscription_identifier_available
      | let subscription_identifier_available: Bool box =>
        MqttSubscriptionIdentifierAvailable.encode(buf, subscription_identifier_available)
      end

      match data.shared_subscription_available
      | let shared_subscription_available: Bool box =>
        MqttSharedSubscriptionAvailable.encode(buf, shared_subscription_available)
      end

      match data.server_keep_alive
      | let server_keep_alive: U16 box =>
        MqttServerKeepAlive.encode(buf, server_keep_alive)
      end

      match data.response_information
      | let response_information: String box =>
        MqttResponseInformation.encode(buf, response_information)
      end

      match data.server_reference
      | let server_reference: String box =>
        MqttServerReference.encode(buf, server_reference)
      end

      match data.authentication_method
      | let authentication_method: String box =>
        MqttAuthenticationMethod.encode(buf, authentication_method)
      end

      match data.authentication_data
      | let authentication_data: Array[U8 val] box =>
        MqttAuthenticationData.encode(buf, authentication_data)
      end

      match data.reason_string
      | let reason_string: String box =>
        if (buf.size() + MqttReasonString.size(reason_string)) <= total_size then
          MqttReasonString.encode(buf, reason_string)
        end
      end

      match data.user_properties
      | \unlikely\ let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          if (buf.size() + MqttUserProperty.size(item)) <= total_size then
            MqttUserProperty.encode(buf, item)
          end
        end
      end

    else
      match data.return_code
      | let return_code: MqttConnectReturnCode box =>
        buf.push(return_code())
      else
        buf.push(MqttServerUnavailable())
      end
    end

    buf
