use "itertools"
use "pony_test"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestUtf8String)
    test(_TestUtf8StringPair)
    test(_TestTwoByteInteger)
    test(_TestFourByteInteger)
    test(_TestVariableByteInteger)
    test(_TestBinaryData)
    test(_TestDecoder)
    test(_TestConnect)
    test(_TestConnAck)
    test(_TestPublish)
    test(_TestPubAck)
    test(_TestPubRec)
    test(_TestPubRel)
    test(_TestPubComp)
    test(_TestSubscribe)
    test(_TestSubAck)
    test(_TestUnSubscribe)
    test(_TestUnSubAck)
    test(_TestDisconnect)
    test(_TestAuth)

primitive _TestUtils
  fun assert_user_properties_eq(
    h: TestHelper,
    expect: Array[MqttUserProperty] val,
    actual: Array[MqttUserProperty] val,
    msg: String = "",
    loc: SourceLoc = __loc)
  : Bool =>
    var ok = true

    if expect.size() != actual.size() then
      ok = false
    else
      try
        var i: USize = 0
        while i < expect.size() do
          if (expect(i)?._1 != actual(i)?._1) or (expect(i)?._2 != actual(i)?._2) then
            ok = false
            break
          end

          i = i + 1
        end
      else
        ok = false
      end
    end

    if not ok then
      h.fail(_format_loc(loc) + "Assert EQ failed. " + msg + " Expected ("
        + _print_user_properties(expect) + ") == (" + _print_user_properties(actual) + ")")
    end

    ok

  fun _print_user_properties(
    properties: Array[MqttUserProperty] val)
  : String =>
    """
    Generate a printable string of the contents of the given readseq to use in
    error messages.

    The type parameter of this function is the type parameter of the
    elements in the ReadSeq.
    """
    "[len=" + properties.size().string() + ": " + ", ".join(Iter[MqttUserProperty](properties.values()).map[String val]({(x: MqttUserProperty): String val => "(" + x._1 + ", " + x._2 + ")" })) + "]"

  fun _format_loc(
    loc: SourceLoc)
  : String =>
    loc.file() + ":" + loc.line().string() + ": "
