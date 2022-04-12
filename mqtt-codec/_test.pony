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
    test(_TestUnsubscribe)
    test(_TestUnsubAck)
    test(_TestDisconnect)
    test(_TestAuth)
