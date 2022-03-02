primitive MqttQoS0
  """
  At most once delivery
  """
  fun apply(): U8 val =>
    0x00

primitive MqttQoS1
  """
  At least once delivery
  """
  fun apply(): U8 val =>
    0x02

primitive MqttQoS2
  """
  Exactly once delivery
  """
  fun apply(): U8 val =>
    0x04

primitive MqttQoSReserved
  """
  Reserved - must not be used
  """
  fun apply(): U8 val =>
    0x06

type MqttQoS is (MqttQoS0 | MqttQoS1 | MqttQoS2 | MqttQoSReserved)

primitive _MqttQoSEncoder
  fun apply(qos: MqttQoS box): U8 val =>
    qos()

primitive _MqttQoSDecoder
  fun apply(data: U8 box): MqttQoS val =>
    match (data and 0x06)
    | MqttQoS0() => MqttQoS0
    | MqttQoS1() => MqttQoS1
    | MqttQoS2() => MqttQoS2
    else
      MqttQoSReserved
    end
