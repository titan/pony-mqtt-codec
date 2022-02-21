primitive MqttSuccess
  """
  CONNACK, PUBACK, PUBREC, PUBREL, PUBCOMP, UNSUBACK, AUTH
  """
  fun apply(): U8 =>
    0

primitive MqttNormalDisconnection
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0

primitive MqttGrantedQoS0
  """
  SUBACK
  """
  fun apply(): U8 =>
    0

primitive MqttGrantedQoS1
  """
  SUBACK
  """
  fun apply(): U8 =>
    0x01

primitive MqttGrantedQoS2
  """
  SUBACK
  """
  fun apply(): U8 =>
    0x02

primitive MqttDisconnectWithWillMessage
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x04

primitive MqttNoMatchingSubscribers
  """
  PUBACK, PUBREC
  """
  fun apply(): U8 =>
    0x10

primitive MqttNoSubscriptionExisted
  """
  UNSUBACK
  """
  fun apply(): U8 =>
    0x11

primitive MqttContinueAuthentication
  """
  AUTH
  """
  fun apply(): U8 =>
    0x18

primitive MqttReauthenticate
  """
  AUTH
  """
  fun apply(): U8 =>
    0x19

primitive MqttUnspecifiedError
  """
  CONNACK, PUBACK, PUBREC, SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x80

primitive MqttMalformedPacket
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x81

primitive MqttProtocolError
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x82

primitive MqttImplementationSpecificError
  """
  CONNACK, PUBACK, PUBREC, SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x83

primitive MqttUnsupportedProtocolVersion
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x84

primitive MqttClientIdentifierNotValid
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x85

primitive MqttBadUserNameOrPassword5
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x86

primitive MqttNotAuthorized5
  """
  CONNACK, PUBACK, PUBREC, SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x87

primitive MqttServerUnavailable5
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x88

primitive MqttServerBusy
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x89

primitive MqttBanned
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x8A

primitive MqttServerShuttingDown
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x8B

primitive MqttBadAuthenticationMethod
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x8C

primitive MqttKeepAliveTimeout
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x8D

primitive MqttSessionTakenOver
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x8E

primitive MqttTopicFilterInvalid
  """
  SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x8F

primitive MqttTopicNameInvalid
  """
  CONNACK, PUBACK, PUBREC, DISCONNECT
  """
  fun apply(): U8 =>
    0x90

primitive MqttPacketIdentifierInUse
  """
  PUBACK, PUBREC, SUBACK, UNSUBACK
  """
  fun apply(): U8 =>
    0x91

primitive MqttPacketIdentifierNotFound
  """
  PUBREL, PUBCOMP
  """
  fun apply(): U8 =>
    0x92

primitive MqttReceiveMaximumExceeded
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x93

primitive MqttTopicAliasInvalid
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x94

primitive MqttPacketTooLarge
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x95

primitive MqttMessageRateTooHigh
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x96

primitive MqttQuotaExceeded
  """
  CONNACK, PUBACK, PUBREC, SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x97

primitive MqttAdministrativeAction
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x98

primitive MqttPayloadFormatInvalid
  """
  CONNACK, PUBACK, PUBREC, DISCONNECT
  """
  fun apply(): U8 =>
    0x99

primitive MqttRetainNotSupported
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9A

primitive MqttQoSNotSupported
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9B

primitive MqttUseAnotherServer
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9C

primitive MqttServerMoved
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9D

primitive MqttSharedSubscriptionsNotSupported
  """
  SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9E

primitive MqttConnectionRateExceeded
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9F

primitive MqttMaximumConnectTime
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0xA0

primitive MqttSubscriptionIdentifiersNotSupported
  """
  SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0xA1

primitive MqttWildcardSubscriptionsNotSupported
  """
  SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0xA2
