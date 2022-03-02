use "buffered"

primitive MqttUnspecifiedBytes
  fun apply(): U8 val =>
    0x00

primitive MqttCharacterData
  fun apply(): U8 val =>
    0x01

type MqttPayloadFormatIndicatorType is (MqttUnspecifiedBytes | MqttCharacterData)

primitive MqttPayloadFormatIndicator
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 val =>
    0x01

  fun decode(reader: Reader): (MqttPayloadFormatIndicatorType val, USize val) ? =>
    if reader.u8() ? == MqttCharacterData() then
      (MqttCharacterData, 1)
    else
      (MqttUnspecifiedBytes, 1)
    end

  fun encode(buf: Array[U8 val], data: MqttPayloadFormatIndicatorType box): USize val =>
    buf.push(apply())
    buf.push(data())
    2

  fun size(data: MqttPayloadFormatIndicatorType box): USize val =>
    2

primitive MqttMessageExpiryInterval
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 val =>
    0x02

  fun decode(reader: Reader): (U32 val, USize val) ? =>
    MqttFourByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U32 box): USize val =>
    buf.push(apply())
    let size' = MqttFourByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U32 box): USize val =>
    1 + MqttFourByteInteger.size(data)

primitive MqttContentType
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 val =>
    0x03

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttResponseTopic
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 val =>
    0x08

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttCorrelationData
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 val =>
    0x09

  fun decode(reader: Reader): (Array[U8 val] val, USize val) ? =>
    MqttBinaryData.decode(reader) ?

  fun encode(buf: Array[U8 val], data: Array[U8 val] box): USize val =>
    buf.push(apply())
    let size' = MqttBinaryData.encode(buf, data)
    1 + size'

  fun size(data: Array[U8 val] box): USize val =>
    1 + MqttBinaryData.size(data)

primitive MqttSubscriptionIdentifier
  """
  PUBLISH, SUBSCRIBE
  """
  fun apply(): U8 val =>
    0x0B

  fun decode(reader: Reader): (ULong, USize) ? =>
    MqttVariableByteInteger.decode_reader(reader) ?

  fun encode(buf: Array[U8 val], data: ULong box): USize val =>
    buf.push(apply())
    let size' = MqttVariableByteInteger.encode(buf, data)
    1 + size'

  fun size(data: ULong box): USize val =>
    1 + MqttVariableByteInteger.size(data)

primitive MqttSessionExpiryInterval
  """
  CONNECT, CONNACK, DISCONNECT
  """
  fun apply(): U8 val =>
    0x11

  fun decode(reader: Reader): (U32 val, USize val) ? =>
    MqttFourByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U32 box): USize val =>
    buf.push(apply())
    let size' = MqttFourByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U32 box): USize val =>
    1 + MqttFourByteInteger.size(data)

primitive MqttAssignedClientIdentifier
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x12

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttServerKeepAlive
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x13

  fun decode(reader: Reader): (U16 val, USize val) ? =>
    MqttTwoByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U16 box): USize val =>
    buf.push(apply())
    let size' = MqttTwoByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U16 box): USize val =>
    1 + MqttTwoByteInteger.size(data)

primitive MqttAuthenticationMethod
  """
  CONNECT, CONNACK, AUTH
  """
  fun apply(): U8 val =>
    0x15

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttAuthenticationData
  """
  CONNECT, CONNACK, AUTH
  """
  fun apply(): U8 val =>
    0x16

  fun decode(reader: Reader): (Array[U8 val] val, USize val) ? =>
    MqttBinaryData.decode(reader) ?

  fun encode(buf: Array[U8 val], data: Array[U8 val] box): USize val =>
    buf.push(apply())
    let size' = MqttBinaryData.encode(buf, data)
    1 + size'

  fun size(data: Array[U8 val] box): USize val =>
    1 + MqttBinaryData.size(data)

primitive MqttRequestProblemInformation
  """
  CONNECT
  """
  fun apply(): U8 val =>
    0x17

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2

primitive MqttWillDelayInterval
  """
  Will Properties
  """
  fun apply(): U8 val =>
    0x18

  fun decode(reader: Reader): (U32 val, USize val) ? =>
    MqttFourByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U32 box): USize val =>
    buf.push(apply())
    let size' = MqttFourByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U32 box): USize val =>
    1 + MqttFourByteInteger.size(data)

primitive MqttRequestResponseInformation
  """
  CONNECT
  """
  fun apply(): U8 val =>
    0x19

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2

primitive MqttResponseInformation
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x1A

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttServerReference
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 val =>
    0x1C

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttReasonString
  """
  CONNACK, PUBACK, PUBREC, PUBREL, PUBCOMP, SUBACK, UNSUBACK, DISCONNECT, AUTH
  """
  fun apply(): U8 val =>
    0x1F

  fun decode(reader: Reader): (String, USize) ? =>
    MqttUtf8String.decode(reader) ?

  fun encode(buf: Array[U8 val], data: String box): USize val =>
    buf.push(apply())
    let size' = MqttUtf8String.encode(buf, data)
    1 + size'

  fun size(data: String box): USize val =>
    1 + MqttUtf8String.size(data)

primitive MqttReceiveMaximum
  """
  CONNECT, CONNACK
  """
  fun apply(): U8 val =>
    0x21

  fun decode(reader: Reader): (U16 val, USize val) ? =>
    MqttTwoByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U16 box): USize val =>
    buf.push(apply())
    let size' = MqttTwoByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U16 box): USize val =>
    1 + MqttTwoByteInteger.size(data)

primitive MqttTopicAliasMaximum
  """
  CONNECT, CONNACK
  """
  fun apply(): U8 val =>
    0x22

  fun decode(reader: Reader): (U16 val, USize val) ? =>
    MqttTwoByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U16 box): USize val =>
    buf.push(apply())
    let size' = MqttTwoByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U16 box): USize val =>
    1 + MqttTwoByteInteger.size(data)

primitive MqttTopicAlias
  """
  PUBLISH
  """
  fun apply(): U8 val =>
    0x23

  fun decode(reader: Reader): (U16 val, USize val) ? =>
    MqttTwoByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U16 box): USize val =>
    buf.push(apply())
    let size' = MqttTwoByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U16 box): USize val =>
    1 + MqttTwoByteInteger.size(data)

primitive MqttMaximumQoS
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x24

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2

primitive MqttRetainAvailable
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x25

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2

primitive MqttUserProperty
  """
  CONNECT, CONNACK, PUBLISH, Will Properties, PUBACK, PUBREC, PUBREL, PUBCOMP, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK, DISCONNECT, AUTH
  """
  fun apply(): U8 val =>
    0x26

  fun decode(reader: Reader): ((String val, String val), USize val) ? =>
    MqttUtf8StringPair.decode(reader) ?

  fun encode(buf: Array[U8 val], data: (String box, String box)): USize val =>
    buf.push(apply())
    let size' = MqttUtf8StringPair.encode(buf, data)
    1 + size'

  fun size(data: (String box, String box)): USize val =>
    1 + MqttUtf8StringPair.size(data)

primitive MqttMaximumPacketSize
  """
  CONNECT, CONNACK
  """
  fun apply(): U8 val =>
    0x27

  fun decode(reader: Reader): (U32 val, USize val) ? =>
    MqttFourByteInteger.decode(reader) ?

  fun encode(buf: Array[U8 val], data: U32 box): USize val =>
    buf.push(apply())
    let size' = MqttFourByteInteger.encode(buf, data)
    1 + size'

  fun size(data: U32 box): USize val =>
    1 + MqttFourByteInteger.size(data)

primitive MqttWildcardSubscriptionAvailable
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x28

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2

primitive MqttSubscriptionIdentifierAvailable
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x29

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2

primitive MqttSharedSubscriptionAvailable
  """
  CONNACK
  """
  fun apply(): U8 val =>
    0x2A

  fun decode(reader: Reader): (Bool val, USize val) ? =>
    (reader.u8() ? == 1, 1)

  fun encode(buf: Array[U8 val], data: Bool box): USize val =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    2

  fun size(data: Bool box): USize val =>
    2
