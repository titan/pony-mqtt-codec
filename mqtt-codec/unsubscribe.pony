use "collections"

type MqttUnSubscribePacket is
  ( U16 // 1. packet_identifier
  , (Array[MqttUserProperty] val | None) // 2. user_properties
  , Array[String val] val // 3. topic_filters
  )

primitive MqttUnSubscribe
  """
  UnSubscribe request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0xA0

  fun packet_identifier(
    packet: MqttUnSubscribePacket)
  : U16 =>
    """
    The Packet Identifier field.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._1

  fun user_properties(
    packet: MqttUnSubscribePacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    User Properties on the SUBSCRIBE packet can be used to send subscription
    related properties from the Client to the Server.

    * mqtt-5
    """
    packet._2

  fun topic_filters(
    packet: MqttUnSubscribePacket)
  : Array[String val] val =>
    """
    It contains the list of Topic Filters that the Client wishes to unsubscribe
    from.

    * mqtt-5
    * mqtt-3.1.1
    * mqtt-3.1
    """
    packet._3

  fun build(
    packet_identifier': U16,
    topic_filters': Array[String val] val,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttUnSubscribePacket =>
    ( packet_identifier'
    , user_properties'
    , topic_filters'
    )

primitive _MqttUnSubscribeDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttUnSubscribe(),
    version: MqttVersion = MqttVersion5)
  : MqttUnSubscribePacket? =>
    var offset' = offset
    (let packet_identifier: U16, let packet_identifier_size: USize) = _MqttTwoByteInteger.decode(buf, offset')?
    offset' = offset' + packet_identifier_size
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
        | _MqttUserProperty() =>
          (let user_property, let user_property_size) = _MqttUserProperty.decode(buf, offset' + decoded_length)?
          try (user_properties as Array[MqttUserProperty] iso).push(consume user_property) end
          decoded_length = decoded_length + user_property_size
        end
      end
      offset' = offset' + decoded_length
    end
    var topic_filters: Array[String val] iso = recover iso Array[String val] end
    while offset' < limit do
      (let topic_filter: String iso, let topic_filter_size) = _MqttUtf8String.decode(buf, offset')?
      offset' = offset' + topic_filter_size
      topic_filters.push(consume topic_filter)
    end
    MqttUnSubscribe.build(
      packet_identifier,
      consume topic_filters,
      consume user_properties
    )

primitive _MqttUnSubscribeMeasurer
  fun variable_header_size(
    packet: MqttUnSubscribePacket,
    version: MqttVersion = MqttVersion5)
  : USize =>
    var size: USize = 0
    size = _MqttTwoByteInteger.size(MqttUnSubscribe.packet_identifier(packet))
    if \likely\ version == MqttVersion5 then
      let properties_length = properties_size(packet)
      size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    end
    size

  fun properties_size(
    packet: MqttUnSubscribePacket)
  : USize =>
    var size: USize = 0

    match MqttUnSubscribe.user_properties(packet)
    | let user_properties: Array[MqttUserProperty] val =>
      for property in user_properties.values() do
        size = size + _MqttUserProperty.size(property)
      end
    end

    size

  fun payload_size(
    packet: MqttUnSubscribePacket)
  : USize =>
    var size: USize = 0
    for topic_filter in MqttUnSubscribe.topic_filters(packet).values() do
      size = size + _MqttUtf8String.size(topic_filter)
    end
    size

primitive _MqttUnSubscribeEncoder
  fun apply(
    packet: MqttUnSubscribePacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let size = (_MqttUnSubscribeMeasurer.variable_header_size(packet, version) + _MqttUnSubscribeMeasurer.payload_size(packet)).ulong()

    var buf = recover iso Array[U8](_MqttVariableByteInteger.size(size) + size.usize() + 1) end

    buf.push((MqttUnSubscribe() and 0xF0) or 0x02)

    buf = _MqttVariableByteInteger.encode(consume buf, size)
    buf = _MqttTwoByteInteger.encode(consume buf, MqttUnSubscribe.packet_identifier(packet))

    if \likely\ version == MqttVersion5 then
      let properties_length: USize = _MqttUnSubscribeMeasurer.properties_size(packet)
      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttUnSubscribe.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] box =>
        for property in user_properties.values() do
          buf = _MqttUserProperty.encode(consume buf, property)
        end
      end
    end

    for property in MqttUnSubscribe.topic_filters(packet).values() do
      buf = _MqttUtf8String.encode(consume buf, property)
    end

    consume buf
