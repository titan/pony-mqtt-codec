primitive MqttUnspecifiedBytes
  fun apply(): U8 => 0x00

primitive MqttCharacterData
  fun apply(): U8 => 0x01

type MqttPayloadFormatIndicatorType is (MqttUnspecifiedBytes | MqttCharacterData)

primitive _MqttPayloadFormatIndicator
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 =>
    0x01

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (MqttPayloadFormatIndicatorType, USize)? =>
    if offset >= limit then
      error
    end
    if buf(offset)? == MqttCharacterData() then
      (MqttCharacterData, 1)
    else
      (MqttUnspecifiedBytes, 1)
    end

  fun encode(
    buf: Array[U8] iso,
    data: MqttPayloadFormatIndicatorType)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(data())
    consume buf

  fun size(
    data: MqttPayloadFormatIndicatorType)
  : USize =>
    2

primitive _MqttMessageExpiryInterval
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 =>
    0x02

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U32, USize)? =>
    _MqttFourByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U32)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttFourByteInteger.encode(consume buf, data)

  fun size(
    data: U32)
  : USize =>
    1 + _MqttFourByteInteger.size(data)

primitive _MqttContentType
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 =>
    0x03

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttResponseTopic
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 =>
    0x08

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttCorrelationData
  """
  PUBLISH, Will Properties
  """
  fun apply(): U8 =>
    0x09

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Array[U8] iso^, USize)? =>
    _MqttBinaryData.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: Array[U8] val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttBinaryData.encode(consume buf, data)

  fun size(
    data: Array[U8] val)
  : USize =>
    1 + _MqttBinaryData.size(data)

primitive _MqttSubscriptionIdentifier
  """
  PUBLISH, SUBSCRIBE
  """
  fun apply(): U8 =>
    0x0B

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (ULong, USize)? =>
    _MqttVariableByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: ULong)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttVariableByteInteger.encode(consume buf, data)

  fun size(
    data: ULong)
  : USize =>
    1 + _MqttVariableByteInteger.size(data)

primitive _MqttSessionExpiryInterval
  """
  CONNECT, CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x11

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U32, USize)? =>
    _MqttFourByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U32)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttFourByteInteger.encode(consume buf, data)

  fun size(
    data: U32)
  : USize =>
    1 + _MqttFourByteInteger.size(data)

primitive _MqttAssignedClientIdentifier
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x12

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf,  offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttServerKeepAlive
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x13

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U16, USize)? =>
    _MqttTwoByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U16)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttTwoByteInteger.encode(consume buf, data)

  fun size(
    data: U16)
  : USize =>
    1 + _MqttTwoByteInteger.size(data)

primitive _MqttAuthenticationMethod
  """
  CONNECT, CONNACK, AUTH
  """
  fun apply(): U8 =>
    0x15

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttAuthenticationData
  """
  CONNECT, CONNACK, AUTH
  """
  fun apply(): U8 =>
    0x16

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Array[U8] iso^, USize)? =>
    _MqttBinaryData.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: Array[U8] val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttBinaryData.encode(consume buf, data)

  fun size(
    data: Array[U8] val)
  : USize =>
    1 + _MqttBinaryData.size(data)

primitive _MqttRequestProblemInformation
  """
  CONNECT
  """
  fun apply(): U8 =>
    0x17

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2

primitive _MqttWillDelayInterval
  """
  Will Properties
  """
  fun apply(): U8 =>
    0x18

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U32, USize)? =>
    _MqttFourByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U32)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttFourByteInteger.encode(consume buf, data)

  fun size(
    data: U32)
  : USize =>
    1 + _MqttFourByteInteger.size(data)

primitive _MqttRequestResponseInformation
  """
  CONNECT
  """
  fun apply(): U8 =>
    0x19

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2

primitive _MqttResponseInformation
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x1A

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttServerReference
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x1C

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttReasonString
  """
  CONNACK, PUBACK, PUBREC, PUBREL, PUBCOMP, SUBACK, UNSUBACK, DISCONNECT, AUTH
  """
  fun apply(): U8 =>
    0x1F

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    _MqttUtf8String.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8String.encode(consume buf, data)

  fun size(
    data: String val)
  : USize =>
    1 + _MqttUtf8String.size(data)

primitive _MqttReceiveMaximum
  """
  CONNECT, CONNACK
  """
  fun apply(): U8 =>
    0x21

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U16, USize)? =>
    _MqttTwoByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U16)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttTwoByteInteger.encode(consume buf, data)

  fun size(
    data: U16)
  : USize =>
    1 + _MqttTwoByteInteger.size(data)

primitive _MqttTopicAliasMaximum
  """
  CONNECT, CONNACK
  """
  fun apply(): U8 =>
    0x22

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U16, USize)? =>
    _MqttTwoByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U16)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttTwoByteInteger.encode(consume buf, data)

  fun size(
    data: U16)
  : USize =>
    1 + _MqttTwoByteInteger.size(data)

primitive _MqttTopicAlias
  """
  PUBLISH
  """
  fun apply(): U8 =>
    0x23

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U16, USize)? =>
    _MqttTwoByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U16)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttTwoByteInteger.encode(consume buf, data)

  fun size(
    data: U16)
  : USize =>
    1 + _MqttTwoByteInteger.size(data)

primitive _MqttMaximumQoS
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x24

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2

primitive _MqttRetainAvailable
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x25

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2

primitive _MqttUserProperty
  """
  CONNECT, CONNACK, PUBLISH, Will Properties, PUBACK, PUBREC, PUBREL, PUBCOMP, SUBSCRIBE, SUBACK, UNSUBSCRIBE, UNSUBACK, DISCONNECT, AUTH
  """
  fun apply(): U8 =>
    0x26

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : ((String iso^, String iso^), USize)? =>
    _MqttUtf8StringPair.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: (String val, String val))
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttUtf8StringPair.encode(consume buf, data)

  fun size(
    data: (String val, String val))
  : USize =>
    1 + _MqttUtf8StringPair.size(data)

primitive _MqttMaximumPacketSize
  """
  CONNECT, CONNACK
  """
  fun apply(): U8 =>
    0x27

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U32, USize)? =>
    _MqttFourByteInteger.decode(buf, offset, limit)?

  fun encode(
    buf: Array[U8] iso,
    data: U32)
  : Array[U8] iso^ =>
    buf.push(apply())
    _MqttFourByteInteger.encode(consume buf, data)

  fun size(
    data: U32)
  : USize =>
    1 + _MqttFourByteInteger.size(data)

primitive _MqttWildcardSubscriptionAvailable
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x28

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2

primitive _MqttSubscriptionIdentifierAvailable
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x29

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2

primitive _MqttSharedSubscriptionAvailable
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x2A

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Bool, USize)? =>
    if offset >= limit then
      error
    end
    (buf(offset)? == 1, 1)

  fun encode(
    buf: Array[U8] iso,
    data: Bool)
  : Array[U8] iso^ =>
    buf.push(apply())
    buf.push(if data then 1 else 0 end)
    consume buf

  fun size(
    data: Bool)
  : USize =>
    2
