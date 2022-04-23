primitive MqttEncoder
  fun _limit_packet_size(
    calculator: {(USize): USize},
    maximum_packet_size: USize = 0,
    payload_size: USize = 0)
  : (USize, USize) =>
    var maximum_size: USize = 0
    var remaining: USize = 0
    if maximum_packet_size != 0 then
      var maximum: USize = maximum_packet_size - 1 - 1 - payload_size
      remaining = calculator(maximum)
      var remaining_length = _MqttVariableByteInteger.size(remaining.ulong())
      maximum = maximum - remaining_length
      var delta: USize = 0
      repeat
        maximum = maximum - delta
        let remaining': USize = calculator(maximum) + payload_size
        let remaining_length': USize = _MqttVariableByteInteger.size(remaining'.ulong())
        delta = remaining_length - remaining_length'
        remaining = remaining'
        remaining_length = remaining_length'
      until delta == 0 end
      maximum_size = maximum
    else
      remaining = calculator(0) + payload_size
    end
    (maximum_size, remaining)

  fun auth(
    packet: MqttAuthPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttAuthMeasurer~variable_header_size(packet), maximum_packet_size)
    _MqttAuthEncoder(packet, maximum, remaining)

  fun connack(
    packet: MqttConnAckPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttConnAckMeasurer~variable_header_size(packet, version), maximum_packet_size)
    _MqttConnAckEncoder(packet, maximum, remaining, version)

  fun connect(
    packet: MqttConnectPacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    _MqttConnectEncoder(packet, version)

  fun disconnect(
    packet: MqttDisconnectPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttDisconnectMeasurer~variable_header_size(packet, version), maximum_packet_size)
    _MqttDisconnectEncoder(packet, maximum, remaining, version)

  fun pingreq(): Array[U8] iso^ =>
    _MqttPingReqEncoder()

  fun pingresp(): Array[U8] iso^ =>
    _MqttPingRespEncoder()

  fun puback(
    packet: MqttPubAckPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttPubAckMeasurer~variable_header_size(packet, version), maximum_packet_size)
    _MqttPubAckEncoder(packet, maximum, remaining, version)

  fun pubcomp(
    packet: MqttPubCompPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttPubCompMeasurer~variable_header_size(packet, version), maximum_packet_size)
    _MqttPubCompEncoder(packet, maximum, remaining, version)

  fun publish(
    packet: MqttPublishPacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    _MqttPublishEncoder(packet, version)

  fun pubrec(
    packet: MqttPubRecPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttPubRecMeasurer~variable_header_size(packet, version), maximum_packet_size)
    _MqttPubRecEncoder(packet, maximum, remaining, version)

  fun pubrel(
    packet: MqttPubRelPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttPubRelMeasurer~variable_header_size(packet, version), maximum_packet_size)
    _MqttPubRelEncoder(packet, maximum, remaining, version)

  fun suback(
    packet: MqttSubAckPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let payload_size = _MqttSubAckMeasurer.payload_size(packet)
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttSubAckMeasurer~variable_header_size(packet, version), maximum_packet_size, payload_size)
    _MqttSubAckEncoder(packet, maximum, remaining, version)

  fun subscribe(
    packet: MqttSubscribePacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    _MqttSubscribeEncoder(packet, version)

  fun unsuback(
    packet: MqttUnSubAckPacket,
    maximum_packet_size: USize = 0,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    let payload_size = _MqttUnSubAckMeasurer.payload_size(packet)
    (let maximum: USize, let remaining: USize) = _limit_packet_size(_MqttUnSubAckMeasurer~variable_header_size(packet, version), maximum_packet_size, payload_size)
    _MqttUnSubAckEncoder(packet, maximum, remaining, version)

  fun unsubscribe(
    packet: MqttUnSubscribePacket,
    version: MqttVersion = MqttVersion5)
  : Array[U8] iso^ =>
    _MqttUnSubscribeEncoder(packet, version)
