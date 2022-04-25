primitive _MqttUtf8String
  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (String iso^, USize)? =>
    if (offset + 1) >= limit then
      error
    end
    let msb = buf(offset)?.usize()
    let lsb = buf(offset + 1)?.usize()
    let len = (msb << 8) or lsb
    if (len + 2) > limit then
      error
    end
    let data: Array[U8] iso = recover iso Array[U8](len) end
    data.copy_from(buf, offset + 2, 0, len)
    (String.from_iso_array(consume data), 2 + len)

  fun encode(
    buf: Array[U8] iso,
    data: String val)
  : Array[U8] iso^ =>
    let size' = data.size() and 0xFFFF
    let msb = (size' >> 8).u8()
    let lsb = (size' and 0xFF).u8()
    buf.push(msb)
    buf.push(lsb)
    buf.append(data)
    consume buf

  fun size(
    data: String box)
  : USize =>
    2 + (data.size() and 0xFFFF)

primitive _MqttUtf8StringPair
  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : ((String iso^, String iso^), USize)? =>
    if (offset + 1) >= limit then
      error
    end
    (let key, let key_consumed) = _MqttUtf8String.decode(buf, offset, limit)?
    (let value, let value_consumed) = _MqttUtf8String.decode(buf, offset + key_consumed, limit)?
    ((consume key, consume value), key_consumed + value_consumed)

  fun encode(
    buf: Array[U8] iso,
    data: (String val, String val))
  : Array[U8] iso^ =>
    let key = data._1
    let value = data._2
    let buf1 = _MqttUtf8String.encode(consume buf, key)
    _MqttUtf8String.encode(consume buf1, value)

  fun size(
    data: (String val, String val))
  : USize =>
    let key = data._1
    let value = data._2
    _MqttUtf8String.size(key) + _MqttUtf8String.size(value)

primitive _MqttTwoByteInteger
  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U16, USize)? =>
    if (offset + 1) >= limit then
      error
    end
    let msb = buf(offset)?.u16()
    let lsb = buf(offset + 1)?.u16()
    ((msb << 8) or lsb, 2)

  fun encode(
    buf: Array[U8] iso,
    data: U16)
  : Array[U8] iso^ =>
    let msb = ((data >> 8) and 0xFF).u8()
    let lsb = (data and 0xFF).u8()
    buf.push(msb)
    buf.push(lsb)
    consume buf

  fun size(
    data: U16)
  : USize =>
    2

primitive _MqttFourByteInteger
  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (U32, USize)? =>
    if (offset + 3) >= limit then
      error
    end
    let mmsb = buf(offset)?.u32()
    let mlsb = buf(offset + 1)?.u32()
    let lmsb = buf(offset + 2)?.u32()
    let llsb = buf(offset + 3)?.u32()
    ((((mmsb << 24) or (mlsb << 16)) or (lmsb << 8)) or llsb, 4)

  fun encode(
    buf: Array[U8] iso,
    data: U32)
  : Array[U8] iso^ =>
    let mmsb = ((data >> 24) and 0xFF).u8()
    let mlsb = ((data >> 16) and 0xFF).u8()
    let lmsb = ((data >> 8) and 0xFF).u8()
    let llsb = (data and 0xFF).u8()
    buf.push(mmsb)
    buf.push(mlsb)
    buf.push(lmsb)
    buf.push(llsb)
    consume buf

  fun size(
    data: U32)
  : USize =>
    4

primitive _MqttVariableByteInteger
  """
  The Variable Byte Integer is encoded using an encoding scheme which uses a
  single byte for values up to 127. Larger values are handled as follows. The
  least significant seven bits of each byte encode the data, and the most
  significant bit is used to indicate whether there are bytes following in the
  representation. Thus, each byte encodes 128 values and a "continuation bit".
  The maximum number of bytes in the Variable Byte Integer field is four.
  """

  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (ULong, USize)? =>
    var x: ULong = 0
    var idx: USize = offset
    var byte: U8
    var multiplier: ULong = 0
    repeat
      if idx >= limit then
        error
      end
      byte = buf(idx)?
      x = x + ((byte and 0x7F).ulong() << multiplier)
      if multiplier > 21 then
        error
      end
      multiplier = multiplier + 7
      idx = idx + 1
    until (byte and 0x80) == 0 end
    (x, idx - offset)

  fun encode(
    buf: Array[U8] iso,
    data: ULong)
  : Array[U8] iso^ =>
    var x = data
    var idx: USize = 0
    var y: U8 = 0
    repeat
      y = x.u8() and 0x7F
      x = x >> 7
      if x > 0 then
        y = y or 0x80
      end
      buf.push(y)
      idx = idx + 1
    until x == 0 end
    consume buf

  fun size(
    data: ULong)
  : USize =>
    if data < 128 then
      1
    elseif data < 16_384 then
      2
    elseif data < 2_097_152 then
      3
    else
      4
    end

primitive _MqttBinaryData
  fun decode(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize)
  : (Array[U8] iso^, USize)? =>
    if (offset + 1) >= limit then
      error
    end
    (let len: U16, let consumed: USize) = _MqttTwoByteInteger.decode(buf, offset, limit)?
    if (offset + consumed) > limit then
      error
    end
    let len' = len.usize()
    if (offset + consumed + len') > limit then
      error
    end
    let data = recover iso Array[U8](len') end
    data.copy_from(buf, offset + consumed, 0, len')
    (consume data, consumed + len')

  fun encode(
    buf: Array[U8] iso,
    data: Array[U8] val)
  : Array[U8] iso^ =>
    let size' = data.size() and 0xFFFF
    let msb = (size' >> 8).u8()
    let lsb = (size' and 0xFF).u8()
    buf.push(msb)
    buf.push(lsb)
    buf.copy_from(data, 0, buf.size(), size')
    consume buf

  fun size(
    data: Array[U8] val)
  : USize =>
    let size' = data.size() and 0xFFFF
    size' + 2
