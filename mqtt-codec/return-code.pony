"""
If a well formed CONNECT Packet is received by the Server, but the Server is
unable to process it for some reason, then the Server SHOULD attempt to send a
CONNACK packet containing the appropriate non-zero Connect return code from
this table.

Mqtt-3.1.1 and Mqtt-3.1 only
"""

interface val _MqttReturnCode is (Equatable[_MqttReturnCode] & Stringable)

primitive MqttConnectionAccepted is _MqttReturnCode
  fun apply(): U8 val =>
    0x00

  fun eq(
    o: _MqttReturnCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttConnectionAccepted".clone()

primitive MqttUnacceptableProtocolVersion is _MqttReturnCode
  fun apply(): U8 val =>
    0x01

  fun eq(
    o: _MqttReturnCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttUnacceptableProtocolVersion".clone()

primitive MqttIdentifierRejected is _MqttReturnCode
  fun apply(): U8 val =>
    0x02

  fun eq(
    o: _MqttReturnCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttIdentifierRejected".clone()

primitive MqttServerUnavailable is _MqttReturnCode
  fun apply(): U8 val =>
    0x03

  fun eq(
    o: _MqttReturnCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttServerUnavailable".clone()

primitive MqttBadUserNameOrPassword is _MqttReturnCode
  fun apply(): U8 val =>
    0x04

  fun eq(
    o: _MqttReturnCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttBadUserNameOrPassword".clone()

primitive MqttNotAuthorized is _MqttReturnCode
  fun apply(): U8 val =>
    0x05

  fun eq(
    o: _MqttReturnCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttNotAuthorized".clone()

type MqttConnectReturnCode is
  ( MqttConnectionAccepted
  | MqttUnacceptableProtocolVersion
  | MqttIdentifierRejected
  | MqttServerUnavailable
  | MqttBadUserNameOrPassword
  | MqttNotAuthorized
  )
