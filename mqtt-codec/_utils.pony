use "format"
use "itertools"

primitive _HexDump
  fun apply(buf: Array[U8] box): String val =>
    " ".join(Iter[U8](buf.values()).map[String]({(x: U8): String => Format.int[U8](x where width = 2, align = AlignRight, fmt = FormatHexBare, fill = 0x30)}))

primitive U8ArrayClone
  fun apply(
    src: Array[U8 val] ref)
  : Array[U8 val] val =>
    let result: Array[U8 val] iso = recover iso Array[U8 val](src.size()) end
    for item in src.values() do
      result.push(item)
    end
    consume result
