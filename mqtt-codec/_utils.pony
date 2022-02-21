use "format"
use "itertools"

primitive HexDump
  fun apply(buf: Array[U8] box): String val =>
    " ".join(Iter[U8](buf.values()).map[String]({(x: U8): String => Format.int[U8](x where width = 2, align = AlignRight, fmt = FormatHexBare, fill = 0x30)}))
