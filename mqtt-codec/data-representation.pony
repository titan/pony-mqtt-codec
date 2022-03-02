use "buffered"
use "collections"

primitive MqttUtf8String
  fun decode(reader: Reader): (String val, USize val) ? =>
    let msb = reader.u8()?.usize()
    let lsb = reader.u8()?.usize()
    let len = (msb << 8) or lsb
    let buf: Array[U8] iso = recover iso Array[U8](len) end
    var idx: USize = 0
    while idx < len do
      buf.push(reader.u8() ?)
      idx = idx + 1
    end
    (String.from_iso_array(consume buf), 2 + len)

  fun encode(buf: Array[U8], data: String box): USize val =>
    let size' = data.size() and 0xFFFF
    let msb = (size' >> 8).u8()
    let lsb = (size' and 0xFF).u8()
    buf.push(msb)
    buf.push(lsb)
    for chr in data.values() do
      buf.push(chr)
    end
    2 + size'

  fun size(data: String box): USize val =>
    2 + (data.size() and 0xFFFF)

primitive MqttUtf8StringPair
  fun decode(reader: Reader): ((String val, String val), USize val) ? =>
    (let key, let key_consumed) = MqttUtf8String.decode(reader) ?
    (let value, let value_consumed) = MqttUtf8String.decode(reader) ?
    ((key, value), key_consumed + value_consumed)

  fun encode(buf: Array[U8 val], data: (String box, String box)): USize val =>
    let key = data._1
    let value = data._2
    let size1 = MqttUtf8String.encode(buf, key)
    let size2 = MqttUtf8String.encode(buf, value)
    size1 + size2

  fun size(data: (String box, String box)): USize val =>
    let key = data._1
    let value = data._2
    MqttUtf8String.size(key) + MqttUtf8String.size(value)

primitive MqttTwoByteInteger
  fun decode(reader: Reader): (U16 val, USize val) ? =>
    let msb = reader.u8()?.u16()
    let lsb = reader.u8()?.u16()
    ((msb << 8) or lsb, 2)

  fun encode(buf: Array[U8 val], data: U16 box): USize val =>
    let msb = ((data >> 8) and 0xFF).u8()
    let lsb = (data and 0xFF).u8()
    buf.push(msb)
    buf.push(lsb)
    2

  fun size(data: U16 box): USize val =>
    2

primitive MqttFourByteInteger
  fun decode(reader: Reader): (U32 val, USize val) ? =>
    let mmsb = reader.u8()?.u32()
    let mlsb = reader.u8()?.u32()
    let lmsb = reader.u8()?.u32()
    let llsb = reader.u8()?.u32()
    ((((mmsb << 24) or (mlsb << 16)) or (lmsb << 8)) or llsb, 4)

  fun encode(buf: Array[U8 val], data: U32 box): USize val =>
    let mmsb = ((data >> 24) and 0xFF).u8()
    let mlsb = ((data >> 16) and 0xFF).u8()
    let lmsb = ((data >> 8) and 0xFF).u8()
    let llsb = (data and 0xFF).u8()
    buf.push(mmsb)
    buf.push(mlsb)
    buf.push(lmsb)
    buf.push(llsb)
    4

  fun size(data: U32 box): USize val =>
    4

primitive MqttVariableByteInteger
  """
  The Variable Byte Integer is encoded using an encoding scheme which uses a
  single byte for values up to 127. Larger values are handled as follows. The
  least significant seven bits of each byte encode the data, and the most
  significant bit is used to indicate whether there are bytes following in the
  representation. Thus, each byte encodes 128 values and a "continuation bit".
  The maximum number of bytes in the Variable Byte Integer field is four.
  """

  fun encode(buf: Array[U8 val], data: ULong box): USize val =>
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
    idx

  fun decode_array(buf: Array[U8] val, offset: box->USize = 0): (ULong val, USize val) ? =>
    var x: ULong = 0
    var idx: USize = offset
    var byte: U8
    var multiplier: ULong = 0
    repeat
      byte = buf(idx)?
      x = x + ((byte and 0x7F).ulong() << multiplier)
      if multiplier > 21 then
        error
      end
      multiplier = multiplier + 7
      idx = idx + 1
    until (byte and 0x80) == 0 end
    (x, idx - offset)

  fun decode_reader(reader: Reader): (ULong val, USize val) ? =>
    var x: ULong = 0
    var idx: USize = 0
    var byte: U8
    var multiplier: ULong = 0
    repeat
      byte = reader.u8() ?
      x = x + ((byte and 0x7F).ulong() << multiplier)
      if multiplier > 21 then
        error
      end
      multiplier = multiplier + 7
      idx = idx + 1
    until (byte and 0x80) == 0 end
    (x, idx)

  fun size(data: ULong box): USize val =>
    if data < 128 then
      1
    elseif data < 16_384 then
      2
    elseif data < 2_097_152 then
      3
    else
      4
    end

primitive MqttBinaryData
  fun decode(reader: Reader): (Array[U8 val] val, USize val) ? =>
    (let len, let consumed) = MqttTwoByteInteger.decode(reader)?
    let len' = len.usize()
    let buf = recover iso Array[U8](len') end
    var idx: USize = 0
    while idx < len' do
      buf.push(reader.u8() ?)
      idx = idx + 1
    end
    (consume buf, consumed + len')

  fun encode(buf: Array[U8 val], data: Array[U8 val] box): USize val =>
    let size' = data.size() and 0xFFFF
    let msb = (size' >> 8).u8()
    let lsb = (size' and 0xFF).u8()
    buf.push(msb)
    buf.push(lsb)
    buf.copy_from(data, 0, buf.size(), size')
    size' + 2

  fun size(data: Array[U8 val] box): USize val =>
    let size' = data.size() and 0xFFFF
    size' + 2
