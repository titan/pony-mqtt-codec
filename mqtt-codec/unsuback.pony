use "collections"

type MqttUnSubAckReasonCode is
  ( MqttSuccess
  | MqttNoSubscriptionExisted
  | MqttUnspecifiedError
  | MqttImplementationSpecificError
  | MqttNotAuthorized5
  | MqttTopicFilterInvalid
  | MqttPacketIdentifierInUse
  )

type MqttUnSubAckPacket is
  ( U16 // packet_identifier
  , (Array[MqttUnSubAckReasonCode] val | None) // reason_codes
  , (String val | None) // reason_string
  , (Array[MqttUserProperty] val | None) // user_properties
  )

primitive MqttUnSubAck
  """
  UnSubscribe acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0xB0

  fun packet_identifier(
    packet: MqttUnSubAckPacket)
  : U16 =>
    """
    The Packet Identifier from the UNSUBSCRIBE Packet that is being
    acknowledged.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun reason_codes(
    packet: MqttUnSubAckPacket)
  : (Array[MqttUnSubAckReasonCode] val | None) =>
    """
    It contains a list of Reason Codes. Each Reason Code corresponds to a Topic
    Filter in the UNSUBSCRIBE packet being acknowledged. The order of Reason
    Codes in the UNSUBACK packet MUST match the order of Topic Filters in the
    UNSUBSCRIBE packet.

    * mqtt-5
    """
    packet._2

  fun reason_string(
    packet: MqttUnSubAckPacket)
  : (String val | None) =>
    """
    This Reason String is a human readable string designed for diagnostics and
    SHOULD NOT be parsed by the Client.

    * mqtt-5
    """
    packet._3

  fun user_properties(
    packet: MqttUnSubAckPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    This property can be used to provide additional diagnostic or other
    information.

    * mqtt-5
    """
    packet._4

  fun build(
    packet_identifier': U16,
    reason_codes': (Array[MqttUnSubAckReasonCode] val | None) = None,
    reason_string': (String val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttUnSubAckPacket =>
    ( packet_identifier'
    , reason_codes'
    , reason_string'
    , user_properties'
    )

primitive _MqttUnSubAckDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttUnSubAck(),
    version: MqttVersion = MqttVersion5)
  : MqttUnSubAckPacket? =>
    var offset' = offset

    (let packet_identifier: U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + packet_identifier_size

    var reason_string: (String | None) = None
    var user_properties: (Array[MqttUserProperty] iso | None) = None
    var reason_codes: (Array[MqttUnSubAckReasonCode] iso | None) = None

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
      reason_codes = recover iso Array[MqttUnSubAckReasonCode val](limit - offset') end
      while offset' < limit do
        let code =
          match buf(offset')?
          | MqttSuccess() => MqttSuccess
          | MqttNoSubscriptionExisted() => MqttNoSubscriptionExisted
          | MqttImplementationSpecificError() => MqttImplementationSpecificError
          | MqttNotAuthorized5() => MqttNotAuthorized5
          | MqttTopicFilterInvalid() => MqttTopicFilterInvalid
          | MqttPacketIdentifierInUse() => MqttPacketIdentifierInUse
          else
            MqttUnspecifiedError
          end
        offset' = offset' + 1
        try (reason_codes as Array[MqttUnSubAckReasonCode] iso).push(code) end
      end
    end
    MqttUnSubAck.build(
      packet_identifier,
      consume reason_codes,
      reason_string,
      consume user_properties
    )

primitive _MqttUnSubAckMeasurer
  fun variable_header_size(
    packet: MqttUnSubAckPacket,
    version: MqttVersion = MqttVersion5,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 2 // packet identifier
    let payload_size' = payload_size(packet, version)
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet, if maximum_packet_size != 0 then maximum_packet_size - size - payload_size' else 0 end)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttUnSubAckPacket,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 0

    match MqttUnSubAck.reason_string(packet)
    | let reason_string': String val =>
      let length = _MqttReasonString.size(reason_string')
      if maximum_packet_size != 0 then
        if maximum_packet_size >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match MqttUnSubAck.user_properties(packet)
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
    packet: MqttUnSubAckPacket,
    version: MqttVersion = MqttVersion5)
  : USize =>
    var size: USize = 0
    if \likely\ version == MqttVersion5 then
      match MqttUnSubAck.reason_codes(packet)
      | let reason_codes: Array[MqttUnSubAckReasonCode] val =>
        size = reason_codes.size()
      end
    end
    size

primitive _MqttUnSubAckEncoder
  fun apply(
    packet: MqttUnSubAckPacket,
    maximum_packet_size: USize = 0,
    remaining: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let payload_size = _MqttUnSubAckMeasurer.payload_size(packet, version)

    let total_size = _MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = recover iso Array[U8](total_size) end

    buf.push(MqttUnSubAck())
    buf = _MqttVariableByteInteger.encode(consume buf, remaining.ulong())
    buf = _MqttTwoByteInteger.encode(consume buf, MqttUnSubAck.packet_identifier(packet))

    if \likely\ version == MqttVersion5 then
      var properties_length: USize = _MqttUnSubAckMeasurer.properties_size(packet, maximum_packet_size)

      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttUnSubAck.reason_string(packet)
      | let reason_string: String val =>
        if (buf.size() + _MqttReasonString.size(reason_string)) <= (total_size - payload_size) then
          buf = _MqttReasonString.encode(consume buf, reason_string)
        end
      end

      match MqttUnSubAck.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          if (buf.size() + _MqttUserProperty.size(property)) <= (total_size - payload_size) then
            buf = _MqttUserProperty.encode(consume buf, property)
          end
        end
      end

      match MqttUnSubAck.reason_codes(packet)
      | let reason_codes: Array[MqttUnSubAckReasonCode] val =>
        for property in reason_codes.values() do
          buf.push(property())
        end
      end
    end

    consume buf
