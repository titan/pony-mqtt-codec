use "buffered"
use "collections"

class MqttUnsubscribePacket
  let packet_identifier: U16 val
  """
  The Packet Identifier field.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  User Properties on the SUBSCRIBE packet can be used to send subscription
  related properties from the Client to the Server.

  * mqtt-5
  """

  let topic_filters: Array[String val] val
  """
  It contains the list of Topic Filters that the Client wishes to unsubscribe
  from.

  * mqtt-5
  * mqtt-3.1.1
  * mqtt-3.1
  """

  new iso create(
    packet_identifier': U16 val,
    topic_filters': Array[String val] val,
    user_properties': (Map[String val, String val] val | None) = None)
  =>
    packet_identifier = packet_identifier'
    topic_filters = topic_filters'
    user_properties = user_properties'

primitive MqttUnsubscribeDecoder
  fun apply(
    reader: Reader,
    header: U8 box,
    remaining: box->USize,
    version: MqttVersion box = MqttVersion5)
  : MqttDecodeResultType[MqttUnsubscribePacket val] val ? =>
    var consumed: USize = 0
    (let packet_identifier: U16, let consumed1: USize) = MqttTwoByteInteger.decode(reader) ?
    consumed = consumed + consumed1
    var user_properties: (Map[String val, String val] iso | None) = None
    if \likely\ version == MqttVersion5 then
      (let property_length', let consumed2: USize) = MqttVariableByteInteger.decode_reader(reader) ?
      consumed = consumed + consumed2
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      user_properties = recover iso Map[String val, String val] end
      while decoded_length < property_length do
        let identifier = reader.u8() ?
        decoded_length = decoded_length + 1
        match identifier
        | MqttUserProperty() =>
          (let user_property', let consumed3) = MqttUserProperty.decode(reader) ?
          try (user_properties as Map[String val, String val] iso).insert(user_property'._1, user_property'._2) end
          decoded_length = decoded_length + consumed3
        end
      end
      consumed = consumed + property_length
    end
    var topic_filters: Array[String val] iso = recover iso Array[String val] end
    while consumed < remaining do
      (let topic_filter: String, let consumed4) = MqttUtf8String.decode(reader) ?
      consumed = consumed + consumed4
      topic_filters.push(topic_filter)
    end
    let packet =
      MqttUnsubscribePacket(
        packet_identifier,
        consume topic_filters,
        consume user_properties
      )
    (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)

primitive MqttUnsubscribeMeasurer
  fun variable_header_size(
    data: MqttUnsubscribePacket box,
    version: MqttVersion box = MqttVersion5)
  : USize val =>
    var size: USize = 0
    size = MqttTwoByteInteger.size(data.packet_identifier)
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(data)
      size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    data: MqttUnsubscribePacket box)
  : USize val =>
    var size: USize = 0

    match data.user_properties
    | let user_properties: Map[String val, String val] box =>
      for item in user_properties.pairs() do
        size = size + MqttUserProperty.size(item)
      end
    end

    size

  fun payload_size(
    data: MqttUnsubscribePacket box)
  : USize val =>
    var size: USize = 0
    for topic_filter in data.topic_filters.values() do
      size = size + MqttUtf8String.size(topic_filter)
    end
    size

primitive MqttUnsubscribeEncoder
  fun apply(
    data: MqttUnsubscribePacket box,
    version: MqttVersion box = MqttVersion5)
  : Array[U8 val] val =>
    let size = (MqttUnsubscribeMeasurer.variable_header_size(data, version) + MqttUnsubscribeMeasurer.payload_size(data)).ulong()

    var buf = Array[U8 val](MqttVariableByteInteger.size(size) + size.usize() + 1)

    buf.push(MqttUnsubscribe() or 0x02)

    MqttVariableByteInteger.encode(buf, size)
    MqttTwoByteInteger.encode(buf, data.packet_identifier)

    if \likely\ version == MqttVersion5 then
      let properties_length: USize = MqttUnsubscribeMeasurer.properties_size(data)
      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.user_properties
      | let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          MqttUserProperty.encode(buf, item)
        end
      end
    end

    for item in data.topic_filters.values() do
      MqttUtf8String.encode(buf, item)
    end

    U8ArrayClone(buf)
