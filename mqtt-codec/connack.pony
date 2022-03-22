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

  let session_expiry_interval: U32 val
  """
  When the Session expires the Client and Server need not process the deletion
  of state atomically.

  * mqtt-5
  """

  let receive_maximum: U16 val
  """
  The Client uses this value to limit the number of QoS 1 and QoS 2
  publications that it is willing to process concurrently.

  * mqtt-5
  """

  let maximum_qos: Bool val
  """
  The Server uses this value to specify the highest QoS it supports.

  * mqtt-5
  """

  let retain_available: Bool val
  """
  A value of false means that retained messages are not supported. A value of
  true means retained messages are supported.

  * mqtt-5
  """

  let maximum_packet_size: U32 val
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

  let topic_alias_maximum: U16 val
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

  let wildcard_subscription_available: Bool val
  """
  This property declares whether the Server supports Wildcard Subscriptions.

  * mqtt-5
  """

  let subscription_identifier_available: Bool val
  """
  This property declares whether the Server supports Subscription Identifiers.

  * mqtt-5
  """

  let shared_subscription_available: Bool val
  """
  This property declares whether the Server supports Shared Subscriptions.

  * mqtt-5
  """

  let server_keep_alive: U16 val
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
    session_expiry_interval': U32 val = 0,
    receive_maximum': U16 val = 0,
    maximum_qos': Bool val = false,
    retain_available': Bool val = false,
    maximum_packet_size': U32 val = 0,
    assigned_client_identifier': (String val | None) = None,
    topic_alias_maximum': U16 val = 0,
    reason_string': (String val | None) = None,
    user_properties': (Map[String val, String val] val | None) = None,
    wildcard_subscription_available': Bool val = false,
    subscription_identifier_available': Bool val = false,
    shared_subscription_available': Bool val = false,
    server_keep_alive': U16 val = 0,
    response_information': (String val | None) = None,
    server_reference': (String val | None) = None,
    authentication_method': (String val | None) = None,
    authentication_data': (Array[U8 val] val | None) = None)
  =>
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
  fun apply(
    reader: Reader,
    header: U8 box,
    remaining: USize box,
    version: MqttVersion box = MqttVersion5)
  : MqttDecodeResultType[MqttConnAckPacket val] val ? =>
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
      var session_expiry_interval: U32 = 0
      var receive_maximum: U16 = 0
      var maximum_qos: Bool = false
      var retain_available: Bool = false
      var maximum_packet_size: U32 = 0
      var assigned_client_identifier: (String | None) = None
      var topic_alias_maximum: U16 = 0
      var reason_string: (String | None) = None
      var user_properties: Map[String val, String val] iso = recover iso Map[String val, String val] end
      var wildcard_subscription_available: Bool = false
      var subscription_identifier_available: Bool = false
      var shared_subscription_available: Bool = false
      var server_keep_alive: U16 = 0
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
  fun variable_header_size(
    data: MqttConnAckPacket box,
    maximum_packet_size: USize box = 0,
    version: MqttVersion box = MqttVersion5)
  : USize val =>
    var size: USize = 1 // flags
    size = size + 1 // reason code(mqtt-5) or return code (mqtt-3.1.1/mqtt-3.1)
    if \likely\ version() == MqttVersion5() then
      let properties_length = properties_size(data, if maximum_packet_size != 0 then maximum_packet_size - size else 0 end)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    data: MqttConnAckPacket box,
    maximum_packet_size: USize box = 0)
  : USize val =>
    var size: USize = 0
    size = size +
        if data.session_expiry_interval != 0 then
          MqttSessionExpiryInterval.size(data.session_expiry_interval)
        else
          0
        end
    size = size +
        if data.receive_maximum != 0 then
          MqttReceiveMaximum.size(data.receive_maximum)
        else
          0
        end
    size = size +
        if data.maximum_qos then
          MqttMaximumQoS.size(data.maximum_qos)
        else
          0
        end
    size = size +
        if data.retain_available then
          MqttRetainAvailable.size(data.retain_available)
        else
          0
        end
    size = size +
        if data.maximum_packet_size != 0 then
          MqttMaximumPacketSize.size(data.maximum_packet_size)
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
        if data.topic_alias_maximum != 0 then
          MqttTopicAliasMaximum.size(data.topic_alias_maximum)
        else
          0
        end
    size = size +
        if data.wildcard_subscription_available then
          MqttWildcardSubscriptionAvailable.size(data.wildcard_subscription_available)
        else
          0
        end
    size = size +
        if data.subscription_identifier_available then
          MqttSubscriptionIdentifierAvailable.size(data.subscription_identifier_available)
        else
          0
        end
    size = size +
        if data.shared_subscription_available then
          MqttSharedSubscriptionAvailable.size(data.shared_subscription_available)
        else
          0
        end
    size = size +
        if data.server_keep_alive != 0 then
          MqttServerKeepAlive.size(data.server_keep_alive)
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
      if (maximum_packet_size != 0) then
        if maximum_packet_size >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    if maximum_packet_size != 0 then
      match data.user_properties
      | \unlikely\ let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          let item_size = MqttUserProperty.size(item)
          if maximum_packet_size >= (size + item_size) then
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
  fun apply(
    data: MqttConnAckPacket box,
    maximum_packet_size: USize box = 0,
    version: MqttVersion box = MqttVersion5)
  : Array[U8 val] val =>
    var maximum_size: USize = 0
    var remaining: USize = 0
    if maximum_packet_size != 0 then
      var maximum: USize = maximum_packet_size - 1 - 1
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
      remaining = MqttConnAckMeasurer.variable_header_size(data, 0, version)
    end

    let total_size = MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = Array[U8 val](total_size)

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

      if data.session_expiry_interval != 0 then
        MqttSessionExpiryInterval.encode(buf, data.session_expiry_interval)
      end

      if data.receive_maximum != 0 then
        MqttReceiveMaximum.encode(buf, data.receive_maximum)
      end

      if data.maximum_qos then
        MqttMaximumQoS.encode(buf, data.maximum_qos)
      end

      if data.retain_available then
        MqttRetainAvailable.encode(buf, data.retain_available)
      end

      if data.maximum_packet_size != 0 then
        MqttMaximumPacketSize.encode(buf, data.maximum_packet_size)
      end

      match data.assigned_client_identifier
      | let assigned_client_identifier: String box =>
        MqttAssignedClientIdentifier.encode(buf, assigned_client_identifier)
      end

      if data.topic_alias_maximum != 0 then
        MqttTopicAliasMaximum.encode(buf, data.topic_alias_maximum)
      end

      if data.wildcard_subscription_available then
        MqttWildcardSubscriptionAvailable.encode(buf, data.wildcard_subscription_available)
      end

      if data.subscription_identifier_available then
        MqttSubscriptionIdentifierAvailable.encode(buf, data.subscription_identifier_available)
      end

      if data.shared_subscription_available then
        MqttSharedSubscriptionAvailable.encode(buf, data.shared_subscription_available)
      end

      if data.server_keep_alive != 0 then
        MqttServerKeepAlive.encode(buf, data.server_keep_alive)
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

    U8ArrayClone(buf)
