use "buffered"
use "collections"

type MqttPubAckReasonCode is (MqttSuccess | MqttNoMatchingSubscribers | MqttUnspecifiedError | MqttImplementationSpecificError | MqttNotAuthorized | MqttTopicNameInvalid | MqttPacketIdentifierInUse | MqttQuotaExceeded | MqttPayloadFormatInvalid)

class MqttPubAckPacket
  let packet_identifier: U16 val
  """
  Packet Identifier from the PUBLISH packet that is being acknowledged

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let reason_code: MqttPubAckReasonCode val
  """
  PUBACK Reason Code

  * mqtt-5
  """

  let reason_string: (String val | None)
  """
  It represents the reason associated with this response. This Reason String is
  a human readable string designed for diagnostics and is not intended to be
  parsed by the receiver.

  * mqtt-5
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  This property can be used to provide additional diagnostic or other
  information.

  * mqtt-5
  """

  new iso create(
    packet_identifier': U16 val,
    reason_code': MqttPubAckReasonCode val = MqttSuccess,
    reason_string': (String val | None) = None,
    user_properties': (Map[String val, String val] val | None) = None)
  =>
    packet_identifier = packet_identifier'
    reason_code = reason_code'
    reason_string = reason_string'
    user_properties = user_properties'

primitive MqttPubAckDecoder
  fun apply(
    reader: Reader,
    header: U8 box,
    remaining: USize box,
    version: MqttVersion box = MqttVersion5)
  : MqttDecodeResultType[MqttPubAckPacket val] val ? =>
    (let packet_identifier: U16, _) = MqttTwoByteInteger.decode(reader) ?
    if \likely\ version == MqttVersion5 then
      let reason_code: MqttPubAckReasonCode =
        match reader.u8() ?
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
      (let property_length', _) = MqttVariableByteInteger.decode_reader(reader) ?
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      var reason_string: (String | None) = None
      var user_properties: Map[String val, String val] iso = recover iso Map[String val, String val] end
      while decoded_length < property_length do
        let identifier = reader.u8() ?
        decoded_length = decoded_length + 1
        match identifier
        | MqttReasonString() =>
          (let reason_string', let consumed) = MqttReasonString.decode(reader) ?
          reason_string = reason_string'
          decoded_length = decoded_length + consumed
        | MqttUserProperty() =>
          (let user_property', let consumed) = MqttUserProperty.decode(reader) ?
          user_properties.insert(user_property'._1, user_property'._2)
          decoded_length = decoded_length + consumed
        end
      end
      let packet =
        MqttPubAckPacket(
          packet_identifier,
          reason_code,
          reason_string,
          consume user_properties
        )
      (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)
    else
      let packet =
        MqttPubAckPacket(
          packet_identifier
        )
      (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)
    end

primitive MqttPubAckMeasurer
  fun variable_header_size(
    data: MqttPubAckPacket box,
    maximum_packet_size: USize box = 0,
    version: MqttVersion box = MqttVersion5)
  : USize val =>
    var size: USize = 2 // packet identifier
    if \likely\ version == MqttVersion5 then
      size = size + 1 // reason code
      let properties_length = properties_size(data, if maximum_packet_size != 0 then maximum_packet_size - size else 0 end)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    data: MqttPubAckPacket box,
    maximum_packet_size: USize box = 0)
  : USize val =>
    var size: USize = 0

    match data.reason_string
    | let reason_string: String box =>
      let length = MqttReasonString.size(reason_string)
      if maximum_packet_size != 0 then
        if maximum_packet_size >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match data.user_properties
    | let user_properties: Map[String val, String val] box =>
      if maximum_packet_size != 0 then
        for item in user_properties.pairs() do
          let item_size = MqttUserProperty.size(item)
          if maximum_packet_size >= (size + item_size) then
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

primitive MqttPubAckEncoder
  fun apply(
    data: MqttPubAckPacket box,
    maximum_packet_size: USize box = 0,
    version: MqttVersion box = MqttVersion5)
  : Array[U8 val] val =>
    var maximum_size: USize = 0
    var remaining: USize = 0
    if maximum_packet_size != 0 then
      var maximum: USize = maximum_packet_size - 1 - 1
      remaining = MqttPubAckMeasurer.variable_header_size(data, maximum, version)
      var remaining_length = MqttVariableByteInteger.size(remaining.ulong())
      maximum = maximum - remaining_length
      var delta: USize = 0
      repeat
        maximum = maximum - delta
        let remaining': USize = MqttPubAckMeasurer.variable_header_size(data, maximum, version)
        let remaining_length': USize = MqttVariableByteInteger.size(remaining'.ulong())
        delta = remaining_length - remaining_length'
        remaining = remaining'
        remaining_length = remaining_length'
      until delta == 0 end
      maximum_size = maximum
    else
      remaining = MqttPubAckMeasurer.variable_header_size(data, 0, version)
    end

    let total_size = MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = Array[U8 val](total_size)

    buf.push(MqttPubAck() and 0xF0)
    MqttVariableByteInteger.encode(buf, remaining.ulong())
    MqttTwoByteInteger.encode(buf, data.packet_identifier)

    if \likely\ version == MqttVersion5 then
      buf.push(data.reason_code())

      var properties_length: USize = MqttPubAckMeasurer.properties_size(data, maximum_size)
      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.reason_string
      | \unlikely\ let reason_string: String box =>
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
    end

    U8ArrayClone(buf)
