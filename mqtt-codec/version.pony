primitive MqttVersion5
  """
  Fifth version of the MQTT protocol.
  """
  fun apply(): U8 =>
    5

primitive MqttVersion311
  """
  Fourth version of the MQTT protocol.
  """
  fun apply(): U8 =>
    4

primitive MqttVersion31
  """
  Third version of the MQTT protocol.
  """
  fun apply(): U8 =>
    3

type MqttVersion is (MqttVersion5 | MqttVersion311 | MqttVersion31)
