use "buffered"
use "collections"

type MqttUnsubAckReasonCode is (MqttSuccess | MqttNoSubscriptionExisted | MqttUnspecifiedError | MqttImplementationSpecificError | MqttNotAuthorized5 | MqttTopicFilterInvalid | MqttPacketIdentifierInUse)

class MqttUnsubAckPacket
  let packet_identifier: U16
  """
  The Packet Identifier from the UNSUBSCRIBE Packet that is being acknowledged.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let reason_codes: Array[MqttUnsubAckReasonCode]
  """
  It contains a list of Reason Codes. Each Reason Code corresponds to a Topic
  Filter in the UNSUBSCRIBE packet being acknowledged. The order of Reason Codes
  in the UNSUBACK packet MUST match the order of Topic Filters in the
  UNSUBSCRIBE packet.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let reason_string: (String | None)
  """
  This Reason String is a human readable string designed for diagnostics and
  SHOULD NOT be parsed by the Client.

  * mqtt-5
  """

  let user_properties: (Map[String, String] | None)
  """
  This property can be used to provide additional diagnostic or other
  information.

  * mqtt-5
  """

  new create(
      packet_identifier': U16,
      reason_codes': Array[MqttUnsubAckReasonCode],
      reason_string': (String | None) = None,
      user_properties': (Map[String, String] | None) = None
  ) =>
      packet_identifier = packet_identifier'
      reason_codes = reason_codes'
      reason_string = reason_string'
      user_properties = user_properties'

primitive MqttUnsubAckDecoder
  fun apply(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttUnsubAckPacket] ? =>
    var consumed: USize = 0

    (let packet_identifier: U16, let consumed1: USize) = MqttTwoByteInteger.decode(reader) ?
    consumed = consumed1

    var reason_string: (String | None) = None
    var user_properties: (Map[String, String] | None) = None

    if \likely\ version() == MqttVersion5() then
      (let property_length', let consumed2: USize) = MqttVariableByteInteger.decode_reader(reader) ?
      consumed = consumed + consumed2
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      user_properties = Map[String, String]()
      while decoded_length < property_length do
        let identifier = reader.u8() ?
        decoded_length = decoded_length + 1
        match identifier
        | MqttReasonString() =>
          (let reason_string', let consumed3) = MqttReasonString.decode(reader) ?
          reason_string = reason_string'
          decoded_length = decoded_length + consumed3
        | MqttUserProperty() =>
          (let user_property', let consumed3) = MqttUserProperty.decode(reader) ?
          try (user_properties as Map[String, String]).insert(user_property'._1, user_property'._2) end
          decoded_length = decoded_length + consumed3
        end
      end
      consumed = consumed + property_length
    end
    var reason_codes: Array[MqttUnsubAckReasonCode] = Array[MqttUnsubAckReasonCode](remaining - consumed)
    while consumed < remaining do
      let code =
        match reader.u8() ?
        | MqttSuccess() => MqttSuccess
        | MqttNoSubscriptionExisted() => MqttNoSubscriptionExisted
        | MqttImplementationSpecificError() => MqttImplementationSpecificError
        | MqttNotAuthorized5() => MqttNotAuthorized5
        | MqttTopicFilterInvalid() => MqttTopicFilterInvalid
        | MqttPacketIdentifierInUse() => MqttPacketIdentifierInUse
        else
          MqttUnspecifiedError
        end
      reason_codes.push(code)
      consumed = consumed + 1
    end
    let packet = MqttUnsubAckPacket(
      packet_identifier,
      reason_codes,
      reason_string,
      user_properties
    )
    (MqttDecodeDone, packet)

primitive MqttUnsubAckMeasurer
  fun variable_header_size(data: MqttUnsubAckPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): USize val =>
    var size: USize = 2 // packet identifier
    let payload_size' = payload_size(data)
    if \likely\ version() == MqttVersion5() then
      let properties_length = properties_size(data, try (maximum_packet_size as USize) - size - payload_size' else None end)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(data: MqttUnsubAckPacket box, maximum_packet_size: (USize | None) = None): USize val =>
    var size: USize = 0

    match data.reason_string
    | let reason_string': String =>
      let length = MqttReasonString.size(reason_string')
      match maximum_packet_size
      | let maximum_packet_size': USize =>
        if (size + length) < maximum_packet_size' then
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
          if (size + item_size) < maximum_packet_size' then
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

  fun payload_size(data: MqttUnsubAckPacket box): USize val =>
    var size: USize = data.reason_codes.size()
    size

primitive MqttUnsubAckEncoder
  fun apply(data: MqttUnsubAckPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    let payload_size = MqttUnsubAckMeasurer.payload_size(data)

    var maximum_size: (USize | None) = None
    var remaining: USize = 0
    match maximum_packet_size
    | let maximum_packet_size': USize =>
      var maximum: USize = maximum_packet_size' - 1 - 1 - payload_size
      remaining = MqttUnsubAckMeasurer.variable_header_size(data, maximum, version)
      var remaining_length = MqttVariableByteInteger.size(remaining.ulong())
      maximum = maximum - remaining_length
      var delta: USize = 0
      repeat
        maximum = maximum - delta
        let remaining': USize = MqttUnsubAckMeasurer.variable_header_size(data, maximum, version) + payload_size
        let remaining_length': USize = MqttVariableByteInteger.size(remaining'.ulong())
        delta = remaining_length - remaining_length'
        remaining = remaining'
        remaining_length = remaining_length'
      until delta == 0 end
      maximum_size = maximum
    else
      remaining = MqttUnsubAckMeasurer.variable_header_size(data, None, version) + payload_size
    end

    let total_size = MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf' = recover iso Array[U8](total_size) end
    var buf: Array[U8] trn^ = consume buf'

    buf.push(MqttUnsubAck())
    MqttVariableByteInteger.encode(buf, remaining.ulong())
    MqttTwoByteInteger.encode(buf, data.packet_identifier)

    if \likely\ version() == MqttVersion5() then
      var properties_length: USize = MqttUnsubAckMeasurer.properties_size(data, maximum_size)

      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.reason_string
      | let reason_string: String =>
        if (buf.size() + MqttReasonString.size(reason_string)) <= (total_size - payload_size) then
          MqttReasonString.encode(buf, reason_string)
        end
      end

      match data.user_properties
      | let user_properties: Map[String, String] box =>
        for item in user_properties.pairs() do
          if (buf.size() + MqttUserProperty.size(item)) <= (total_size - payload_size) then
            MqttUserProperty.encode(buf, item)
          end
        end
      end
    end

    for item in data.reason_codes.values() do
      buf.push(item())
    end

    buf
