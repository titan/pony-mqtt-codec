"""
If a well formed CONNECT Packet is received by the Server, but the Server is
unable to process it for some reason, then the Server SHOULD attempt to send a
CONNACK packet containing the appropriate non-zero Connect return code from
this table.

Mqtt-3.1.1 and Mqtt-3.1 only
"""

primitive MqttConnectionAccepted
  fun apply(): U8 val =>
    0x00

primitive MqttUnacceptableProtocolVersion
  fun apply(): U8 val =>
    0x01

primitive MqttIdentifierRejected
  fun apply(): U8 val =>
    0x02

primitive MqttServerUnavailable
  fun apply(): U8 val =>
    0x03

primitive MqttBadUserNameOrPassword
  fun apply(): U8 val =>
    0x04

primitive MqttNotAuthorized
  fun apply(): U8 val =>
    0x05

type MqttConnectReturnCode is (MqttConnectionAccepted | MqttUnacceptableProtocolVersion | MqttIdentifierRejected | MqttServerUnavailable | MqttBadUserNameOrPassword | MqttNotAuthorized)
