interface val _MqttVersion is (Equatable[MqttVersion] & Stringable)

primitive MqttVersion5 is _MqttVersion
  """
  Fifth version of the MQTT protocol.
  """
  fun apply()
  : U8 val =>
    5

  fun eq(
    o: MqttVersion)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    recover iso String(1).>append("5") end

primitive MqttVersion311 is _MqttVersion
  """
  Fourth version of the MQTT protocol.
  """
  fun apply(): U8 val =>
    4

  fun eq(
    o: MqttVersion)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    recover iso String(5).>append("3.1.1") end

primitive MqttVersion31 is _MqttVersion
  """
  Third version of the MQTT protocol.
  """
  fun apply(): U8 val =>
    3

  fun eq(
    o: MqttVersion)
  : Bool =>
    o is this

  fun string()
  : String iso^ =>
    recover iso String(3).>append("3.1") end

type MqttVersion is ((MqttVersion5 | MqttVersion311 | MqttVersion31) & _MqttVersion)
