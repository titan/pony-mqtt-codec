use "buffered"
use "itertools"

primitive MqttReversed
  fun apply(): U8 val =>
    0x00

primitive MqttConnect
  """
  Connection request.

  Direction: Client to Server.
  """
  fun apply(): U8 val =>
    0x10

  fun decode(reader: Reader, header: U8 box, remaining: USize box): MqttDecodeResultType[MqttConnectPacket val] val ? =>
    MqttConnectDecoder(reader, header, remaining) ?

  fun encode(pkt: MqttConnectPacket box, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttConnectEncoder(pkt, version)

primitive MqttConnAck
  """
  Connect acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 val =>
    0x20

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttConnAckPacket val] val ? =>
    MqttConnAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttConnAckPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttConnAckEncoder(pkt, maximum_packet_size, version)

primitive MqttPublish
  """
  Publish message

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0x30

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttPublishPacket val] val ? =>
    MqttPublishDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPublishPacket box, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttPublishEncoder(pkt, version)

primitive MqttPubAck
  """
  Publish acknowlegment(Qos 1)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0x40

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttPubAckPacket val] val ? =>
    MqttPubAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubAckPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttPubAckEncoder(pkt, maximum_packet_size, version)

primitive MqttPubRec
  """
  Publish received(QoS 2 delivery part 1)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0x50

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttPubRecPacket val] val ? =>
    MqttPubRecDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubRecPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttPubRecEncoder(pkt, maximum_packet_size, version)

primitive MqttPubRel
  """
  Publish release(QoS 2 delivery part 2)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0x60

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttPubRelPacket val] val ? =>
    MqttPubRelDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubRelPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttPubRelEncoder(pkt, maximum_packet_size, version)

primitive MqttPubComp
  """
  Publish release(QoS 2 delivery part 3)

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0x70

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttPubCompPacket val] val ? =>
    MqttPubCompDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttPubCompPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttPubCompEncoder(pkt, maximum_packet_size, version)

primitive MqttSubscribe
  """
  Subscribe request.

  Direction: Client to Server.
  """
  fun apply(): U8 val =>
    0x80

  fun decode(reader: Reader, header: U8 box, remaining: box->USize, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttSubscribePacket val] val ? =>
    MqttSubscribeDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttSubscribePacket box, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttSubscribeEncoder(pkt, version)

primitive MqttSubAck
  """
  Subscribe acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 val =>
    0x90

  fun decode(reader: Reader, header: U8 box, remaining: box->USize, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttSubAckPacket val] val ? =>
    MqttSubAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttSubAckPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttSubAckEncoder(pkt, maximum_packet_size, version)

primitive MqttUnsubscribe
  """
  Unsubscribe request.

  Direction: Client to Server.
  """
  fun apply(): U8 val =>
    0xA0

  fun decode(reader: Reader, header: U8 box, remaining: box->USize, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttUnsubscribePacket val] val ? =>
    MqttUnsubscribeDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttUnsubscribePacket box, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttUnsubscribeEncoder(pkt, version)

primitive MqttUnsubAck
  """
  Unsubscribe acknowledgment.

  Direction: Server to Client.
  """
  fun apply(): U8 val =>
    0xB0

  fun decode(reader: Reader, header: U8 box, remaining: box->USize, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttUnsubAckPacket val] val ? =>
    MqttUnsubAckDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttUnsubAckPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttUnsubAckEncoder(pkt, maximum_packet_size, version)

primitive MqttPingReq
  """
  PING request.

  Direction: Client to Server.
  """
  fun apply(): U8 val =>
    0xC0

primitive MqttPingResp
  """
  PING response.

  Direction: Server to Client.
  """
  fun apply(): U8 val =>
    0xD0

primitive MqttDisconnect
  """
  Disconnect notification

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0xE0

  fun decode(reader: Reader, header: U8 box, remaining: USize box, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttDisconnectPacket val] val ? =>
    MqttDisconnectDecoder(reader, header, remaining, version) ?

  fun encode(pkt: MqttDisconnectPacket box, maximum_packet_size: (USize box | None) = None, version: MqttVersion box = MqttVersion5): Array[U8 val] val =>
    MqttDisconnectEncoder(pkt, maximum_packet_size,version)

primitive MqttAuth
  """
  Authentication exchange

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 val =>
    0xF0

  fun decode(reader: Reader, header: U8 box, remaining: USize box): MqttDecodeResultType[MqttAuthPacket val] val ? =>
    MqttAuthDecoder(reader, header, remaining) ?

  fun encode(pkt: MqttAuthPacket box, maximum_packet_size: (USize box | None) = None): Array[U8 val] val =>
    MqttAuthEncoder(pkt, maximum_packet_size)

type MqttControlPacketType is (MqttConnectPacket | MqttConnAckPacket | MqttPublishPacket | MqttPubAckPacket | MqttPubRecPacket | MqttPubRelPacket | MqttPubCompPacket | MqttSubscribePacket | MqttSubAckPacket | MqttUnsubscribePacket | MqttUnsubAckPacket | MqttPingReqPacket | MqttPingRespPacket | MqttDisconnectPacket | MqttAuthPacket)
