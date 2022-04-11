interface val _MqttQoS is (Equatable[MqttQoS] & Stringable)

primitive MqttQoS0 is _MqttQoS
  """
  At most once delivery
  """
  fun apply(): U8 val =>
    0x00

  fun eq(
    o: MqttQoS)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    "QoS0".clone()

primitive MqttQoS1 is _MqttQoS
  """
  At least once delivery
  """
  fun apply(): U8 val =>
    0x02

  fun eq(
    o: MqttQoS)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    "QoS1".clone()

primitive MqttQoS2 is _MqttQoS
  """
  Exactly once delivery
  """
  fun apply(): U8 val =>
    0x04

  fun eq(
    o: MqttQoS)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    "QoS2".clone()

primitive MqttQoSReserved is _MqttQoS
  """
  Reserved - must not be used
  """
  fun apply(): U8 val =>
    0x06

  fun eq(
    o: MqttQoS)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    "QoSReserved".clone()

type MqttQoS is ((MqttQoS0 | MqttQoS1 | MqttQoS2 | MqttQoSReserved) & _MqttQoS)

primitive _MqttQoSEncoder
  fun apply(
    qos: MqttQoS box)
  : U8 val =>
    qos()

primitive _MqttQoSDecoder
  fun apply(
    data: U8 box)
  : MqttQoS val =>
    match (data and 0x06)
    | MqttQoS0() => MqttQoS0
    | MqttQoS1() => MqttQoS1
    | MqttQoS2() => MqttQoS2
    else
      MqttQoSReserved
    end
