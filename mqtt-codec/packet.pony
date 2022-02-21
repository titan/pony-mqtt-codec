use "buffered"
use "itertools"

primitive MqttReversed
  fun apply(): U8 =>
    0x00

primitive MqttConnect
  """
  Connection request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0x10

  fun decode(reader: Reader, header: U8, remaining: USize): MqttDecodeResultType[MqttConnectPacket] ? =>
    MqttConnectDecoder(reader, header, remaining) ?

  fun encode(pkt: MqttConnectPacket box, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttConnectEncoder(pkt, version)

primitive MqttConnAck
  """
  Connect acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0x20

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttConnAckPacket] ? =>
    MqttConnAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttConnAckPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttConnAckEncoder(pkt, maximum_packet_size, version)

primitive MqttPublish
  """
  Publish message

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x30

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttPublishPacket] ? =>
    MqttPublishDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPublishPacket box, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttPublishEncoder(pkt, version)

primitive MqttPubAck
  """
  Publish acknowlegment(Qos 1)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x40

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttPubAckPacket] ? =>
    MqttPubAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubAckPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttPubAckEncoder(pkt, maximum_packet_size, version)

primitive MqttPubRec
  """
  Publish received(QoS 2 delivery part 1)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x50

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttPubRecPacket] ? =>
    MqttPubRecDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubRecPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttPubRecEncoder(pkt, maximum_packet_size, version)

primitive MqttPubRel
  """
  Publish release(QoS 2 delivery part 2)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x60

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttPubRelPacket] ? =>
    MqttPubRelDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubRelPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttPubRelEncoder(pkt, maximum_packet_size, version)

primitive MqttPubComp
  """
  Publish release(QoS 2 delivery part 3)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0x70

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttPubCompPacket] ? =>
    MqttPubCompDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubCompPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttPubCompEncoder(pkt, maximum_packet_size, version)

primitive MqttSubscribe
  """
  Subscribe request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0x80

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttSubscribePacket] ? =>
    MqttSubscribeDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttSubscribePacket box, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttSubscribeEncoder(pkt, version)

primitive MqttSubAck
  """
  Subscribe acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0x90

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttSubAckPacket] ? =>
    MqttSubAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttSubAckPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttSubAckEncoder(pkt, maximum_packet_size, version)

primitive MqttUnsubscribe
  """
  Unsubscribe request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0xA0

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttUnsubscribePacket] ? =>
    MqttUnsubscribeDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttUnsubscribePacket box, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttUnsubscribeEncoder(pkt, version)

primitive MqttUnsubAck
  """
  Unsubscribe acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0xB0

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttUnsubAckPacket] ? =>
    MqttUnsubAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttUnsubAckPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttUnsubAckEncoder(pkt, maximum_packet_size, version)

primitive MqttPingReq
  """
  PING request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0xC0

primitive MqttPingResp
  """
  PING response.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0xD0

primitive MqttDisconnect
  """
  Disconnect notification

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0xE0

  fun decode(reader: Reader, header: U8, remaining: USize, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttDisconnectPacket] ? =>
    MqttDisconnectDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttDisconnectPacket box, maximum_packet_size: (USize | None) = None, version: MqttVersion = MqttVersion5): Array[U8] val =>
    MqttDisconnectEncoder(pkt, maximum_packet_size,version)

primitive MqttAuth
  """
  Authentication exchange

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0xF0

  fun decode(reader: Reader, header: U8, remaining: USize): MqttDecodeResultType[MqttAuthPacket] ? =>
    MqttAuthDecoder(reader, header, remaining) ?

  fun encode(pkt: MqttAuthPacket box, maximum_packet_size: (USize | None) = None): Array[U8] val =>
    MqttAuthEncoder(pkt, maximum_packet_size)

type MqttControlPacketType is (MqttConnectPacket | MqttConnAckPacket | MqttPublishPacket | MqttPubAckPacket | MqttPubRecPacket | MqttPubRelPacket | MqttPubCompPacket | MqttSubscribePacket | MqttSubAckPacket | MqttUnsubscribePacket | MqttUnsubAckPacket | MqttPingReqPacket | MqttPingRespPacket | MqttDisconnectPacket | MqttAuthPacket)
