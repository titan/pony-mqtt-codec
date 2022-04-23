use "collections"

type MqttSubAckReasonCode is
  ( MqttGrantedQoS0
  | MqttGrantedQoS1
  | MqttGrantedQoS2
  | MqttUnspecifiedError
  | MqttImplementationSpecificError
  | MqttNotAuthorized
  | MqttTopicFilterInvalid
  | MqttPacketIdentifierInUse
  | MqttQuotaExceeded
  | MqttSharedSubscriptionsNotSupported
  | MqttSubscriptionIdentifiersNotSupported
  | MqttWildcardSubscriptionsNotSupported
  )

type MqttSubAckPacket is
  ( U16 // 1. packet_identifier
  , Array[MqttSubAckReasonCode] val // 2. reason_codes
  , (String val | None) // 3. reason_string
  , (Array[MqttUserProperty] val |  None) // 4. user properties
  )

primitive MqttSubAck
  """
  Subscribe acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0x90

  fun packet_identifier(
    packet: MqttSubAckPacket)
  : U16 =>
    """
    The Packet Identifier from the SUBSCRIBE Packet that is being acknowledged.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun reason_codes(
    packet: MqttSubAckPacket)
  : Array[MqttSubAckReasonCode] val =>
    """
    It contains a list of Reason Codes. Each Reason Code corresponds to a Topic
    Filter in the SUBSCRIBE packet being acknowledged. The order of Reason
    Codes in the SUBACK packet MUST match the order of Topic Filters in the
    SUBSCRIBE packet.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._2

  fun reason_string(
    packet: MqttSubAckPacket)
  : (String val | None) =>
    """
    This Reason String is a human readable string designed for diagnostics and
    SHOULD NOT be parsed by the Client.

    * mqtt-5
    """
    packet._3

  fun user_properties(
    packet: MqttSubAckPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    This property can be used to provide additional diagnostic or other
    information.

    * mqtt-5
    """
    packet._4

  fun build(
    packet_identifier': U16,
    reason_codes': Array[MqttSubAckReasonCode] val,
    reason_string': (String val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttSubAckPacket =>
    ( packet_identifier'
    , reason_codes'
    , reason_string'
    , user_properties'
    )

primitive _MqttSubAckDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttSubAck(),
    version: MqttVersion = MqttVersion5)
  : MqttSubAckPacket? =>
    var offset' = offset
    (let packet_identifier: U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + packet_identifier_size
    var reason_string: (String | None) = None
    var user_properties: (Array[MqttUserProperty] iso | None) = None
    if \likely\ version == MqttVersion5 then
      (let property_length', let property_length_size: USize) = _MqttVariableByteInteger.decode(buf, offset')?
      offset' = offset' + property_length_size
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      user_properties = recover iso Array[MqttUserProperty] end
      while decoded_length < property_length do
        let identifier = buf(offset' + decoded_length)?
        decoded_length = decoded_length + 1
        match identifier
        | _MqttReasonString() =>
          (let reason_string', let reason_string_size) = _MqttReasonString.decode(buf, offset' + decoded_length)?
          reason_string = consume reason_string'
          decoded_length = decoded_length + reason_string_size
        | _MqttUserProperty() =>
          (let user_property, let user_property_size) = _MqttUserProperty.decode(buf, offset' + decoded_length)?
          try (user_properties as Array[MqttUserProperty] iso).push(consume user_property) end
          decoded_length = decoded_length + user_property_size
        end
      end
      offset' = offset' + decoded_length
    end
    var reason_codes: Array[MqttSubAckReasonCode] iso = recover iso Array[MqttSubAckReasonCode](limit - offset') end
    while offset' < limit do
      let code =
        match buf(offset')?
        | MqttGrantedQoS0() => MqttGrantedQoS0
        | MqttGrantedQoS1() => MqttGrantedQoS1
        | MqttGrantedQoS2() => MqttGrantedQoS2
        | MqttImplementationSpecificError() => MqttImplementationSpecificError
        | MqttNotAuthorized() => MqttNotAuthorized
        | MqttTopicFilterInvalid() => MqttTopicFilterInvalid
        | MqttPacketIdentifierInUse() => MqttPacketIdentifierInUse
        | MqttQuotaExceeded() => MqttQuotaExceeded
        | MqttSharedSubscriptionsNotSupported() => MqttSharedSubscriptionsNotSupported
        | MqttSubscriptionIdentifiersNotSupported() => MqttSubscriptionIdentifiersNotSupported
        | MqttWildcardSubscriptionsNotSupported() => MqttWildcardSubscriptionsNotSupported
        else
          MqttUnspecifiedError
        end
      offset' = offset' + 1
      reason_codes.push(code)
    end

    MqttSubAck.build(
      packet_identifier,
      consume reason_codes,
      reason_string,
      consume user_properties
    )

primitive _MqttSubAckMeasurer
  fun variable_header_size(
    packet: MqttSubAckPacket,
    version: MqttVersion = MqttVersion5,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 2 // packet identifier
    let payload_size' = payload_size(packet)
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet, if maximum_packet_size != 0 then maximum_packet_size - size - payload_size' else 0 end)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttSubAckPacket,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 0

    match MqttSubAck.reason_string(packet)
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

    match MqttSubAck.user_properties(packet)
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

  fun payload_size(
    packet: MqttSubAckPacket)
  : USize =>
    var size: USize = MqttSubAck.reason_codes(packet).size()
    size

primitive _MqttSubAckEncoder
  fun apply(
    packet: MqttSubAckPacket,
    maximum_packet_size: USize = 0,
    remaining: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let payload_size = _MqttSubAckMeasurer.payload_size(packet)

    let total_size = _MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = recover iso Array[U8](total_size) end

    buf.push(MqttSubAck() and 0xF0)
    buf = _MqttVariableByteInteger.encode(consume buf, remaining.ulong())
    buf = _MqttTwoByteInteger.encode(consume buf, MqttSubAck.packet_identifier(packet))

    if \likely\ version == MqttVersion5 then

      var properties_length: USize = _MqttSubAckMeasurer.properties_size(packet, maximum_packet_size)

      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttSubAck.reason_string(packet)
      | let reason_string: String val =>
        if (buf.size() + _MqttReasonString.size(reason_string)) <= (total_size - payload_size) then
          buf = _MqttReasonString.encode(consume buf, reason_string)
        end
      end

      match MqttSubAck.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          if (buf.size() + _MqttUserProperty.size(property)) <= (total_size - payload_size) then
            buf = _MqttUserProperty.encode(consume buf, property)
          end
        end
      end
    end

    for property in MqttSubAck.reason_codes(packet).values() do
      buf.push(property())
    end

    consume buf
