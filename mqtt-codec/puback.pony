use "collections"

type MqttPubAckReasonCode is
  ( MqttSuccess
  | MqttNoMatchingSubscribers
  | MqttUnspecifiedError
  | MqttImplementationSpecificError
  | MqttNotAuthorized
  | MqttTopicNameInvalid
  | MqttPacketIdentifierInUse
  | MqttQuotaExceeded
  | MqttPayloadFormatInvalid
  )

type MqttPubAckPacket is
  ( U16 // 1. packet_identifier
  , MqttPubAckReasonCode // 2. reason_code
  , (String val | None) // 3. reason_string
  , (Array[MqttUserProperty] val | None) // 4. user_properties
  )

primitive MqttPubAck
  """
  Publish acknowlegment(Qos 1)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x40

  fun packet_identifier(
    packet: MqttPubAckPacket)
  : U16 =>
    """
    Packet Identifier from the PUBLISH packet that is being acknowledged

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun reason_code(
    packet: MqttPubAckPacket)
  : MqttPubAckReasonCode =>
    """
    PUBACK Reason Code

    * mqtt-5
    """
    packet._2

  fun reason_string(
    packet: MqttPubAckPacket)
  : (String val | None) =>
    """
    It represents the reason associated with this response. This Reason String
    is a human readable string designed for diagnostics and is not intended to
    be parsed by the receiver.

    * mqtt-5
    """
    packet._3

  fun user_properties(
    packet: MqttPubAckPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    This property can be used to provide additional diagnostic or other
    information.

    * mqtt-5
    """
    packet._4

  fun build(
    packet_identifier': U16,
    reason_code': MqttPubAckReasonCode = MqttSuccess,
    reason_string': (String val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttPubAckPacket =>
    ( packet_identifier'
    , reason_code'
    , reason_string'
    , user_properties'
    )

primitive _MqttPubAckDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttPubAck(),
    version: MqttVersion = MqttVersion5)
  : MqttPubAckPacket? =>
    var offset' = offset
    (let packet_identifier: U16, let packet_identifier_size) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + packet_identifier_size
    if \likely\ version == MqttVersion5 then
      let reason_code: MqttPubAckReasonCode =
        match buf(offset')?
        | MqttSuccess() => MqttSuccess
        | MqttNoMatchingSubscribers() => MqttNoMatchingSubscribers
        | MqttImplementationSpecificError() => MqttImplementationSpecificError
        | MqttNotAuthorized() => MqttNotAuthorized
        | MqttTopicNameInvalid() => MqttTopicNameInvalid
        | MqttPacketIdentifierInUse() => MqttPacketIdentifierInUse
        | MqttQuotaExceeded() => MqttQuotaExceeded
        | MqttPayloadFormatInvalid() => MqttPayloadFormatInvalid
        else
          MqttUnspecifiedError
        end
      offset' = offset' + 1
      (let property_length', let property_length_size) = _MqttVariableByteInteger.decode(buf, offset')?
      offset' = offset' + property_length_size
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      var reason_string: (String | None) = None
      var user_properties: Array[MqttUserProperty] iso = recover iso Array[MqttUserProperty] end
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
          user_properties.push(consume user_property)
          decoded_length = decoded_length + user_property_size
        end
      end
      MqttPubAck.build(
        packet_identifier,
        reason_code,
        reason_string,
        consume user_properties
      )
    else
      MqttPubAck.build(
        packet_identifier
      )
    end

primitive _MqttPubAckMeasurer
  fun variable_header_size(
    packet: MqttPubAckPacket,
    version: MqttVersion = MqttVersion5,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 2 // packet identifier
    if \likely\ version == MqttVersion5 then
      size = size + 1 // reason code
      let properties_length = properties_size(packet, if maximum_packet_size != 0 then maximum_packet_size - size else 0 end)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttPubAckPacket,
    maximum_packet_size: USize = 0)
  : USize val =>
    var size: USize = 0

    match MqttPubAck.reason_string(packet)
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

    match MqttPubAck.user_properties(packet)
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

primitive _MqttPubAckEncoder
  fun apply(
    packet: MqttPubAckPacket,
    maximum_packet_size: USize = 0,
    remaining: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let total_size = _MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = recover iso Array[U8](total_size) end

    buf.push(MqttPubAck() and 0xF0)
    buf = _MqttVariableByteInteger.encode(consume buf, remaining.ulong())
    buf = _MqttTwoByteInteger.encode(consume buf, MqttPubAck.packet_identifier(packet))

    if \likely\ version == MqttVersion5 then
      buf.push(MqttPubAck.reason_code(packet)())

      var properties_length: USize = _MqttPubAckMeasurer.properties_size(packet, maximum_packet_size)
      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttPubAck.reason_string(packet)
      | \unlikely\ let reason_string: String val =>
        if (buf.size() + _MqttReasonString.size(reason_string)) <= total_size then
          buf = _MqttReasonString.encode(consume buf, reason_string)
        end
      end

      match MqttPubAck.user_properties(packet)
      | \unlikely\ let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          if (buf.size() + _MqttUserProperty.size(property)) <= total_size then
            buf = _MqttUserProperty.encode(consume buf, property)
          end
        end
      end
    end

    consume buf
