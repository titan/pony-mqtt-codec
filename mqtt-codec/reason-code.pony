interface val _MqttReasonCode is (Equatable[_MqttReasonCode] & Stringable)

primitive MqttSuccess is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, PUBREL, PUBCOMP, UNSUBACK, AUTH
  """
  fun apply(): U8 =>
    0

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttSuccess".clone()

primitive MqttNormalDisconnection is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttNormalDisconnection".clone()

primitive MqttGrantedQoS0 is _MqttReasonCode
  """
  SUBACK
  """
  fun apply(): U8 =>
    0

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttGrantedQoS0".clone()

primitive MqttGrantedQoS1 is _MqttReasonCode
  """
  SUBACK
  """
  fun apply(): U8 =>
    0x01

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttGrantedQoS1".clone()

primitive MqttGrantedQoS2 is _MqttReasonCode
  """
  SUBACK
  """
  fun apply(): U8 =>
    0x02

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttGrantedQoS2".clone()

primitive MqttDisconnectWithWillMessage is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x04

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttDisconnectWithWillMessage".clone()

primitive MqttNoMatchingSubscribers is _MqttReasonCode
  """
  PUBACK, PUBREC
  """
  fun apply(): U8 =>
    0x10

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttNoMatchingSubscribers".clone()

primitive MqttNoSubscriptionExisted is _MqttReasonCode
  """
  UNSUBACK
  """
  fun apply(): U8 =>
    0x11

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttNoSubscriptionExisted".clone()

primitive MqttContinueAuthentication is _MqttReasonCode
  """
  AUTH
  """
  fun apply(): U8 =>
    0x18

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttContinueAuthentication".clone()

primitive MqttReauthenticate is _MqttReasonCode
  """
  AUTH
  """
  fun apply(): U8 =>
    0x19

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttReauthenticate".clone()

primitive MqttUnspecifiedError is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x80

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttUnspecifiedError".clone()

primitive MqttMalformedPacket is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x81

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttMalformedPacket".clone()

primitive MqttProtocolError is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x82

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttProtocolError".clone()

primitive MqttImplementationSpecificError is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x83

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttImplementationSpecificError".clone()

primitive MqttUnsupportedProtocolVersion is _MqttReasonCode
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x84

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttUnsupportedProtocolVersion".clone()

primitive MqttClientIdentifierNotValid is _MqttReasonCode
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x85

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttClientIdentifierNotValid".clone()

primitive MqttBadUserNameOrPassword5 is _MqttReasonCode
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x86

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttBadUserNameOrPassword5".clone()

primitive MqttNotAuthorized5 is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x87

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttNotAuthorized5".clone()

primitive MqttServerUnavailable5 is _MqttReasonCode
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x88

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttServerUnavailable5".clone()

primitive MqttServerBusy is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x89

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttServerBusy".clone()

primitive MqttBanned is _MqttReasonCode
  """
  CONNACK
  """
  fun apply(): U8 =>
    0x8A

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttBanned".clone()

primitive MqttServerShuttingDown is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x8B

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttServerShuttingDown".clone()

primitive MqttBadAuthenticationMethod is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x8C

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttBadAuthenticationMethod".clone()

primitive MqttKeepAliveTimeout is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x8D

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttKeepAliveTimeout".clone()

primitive MqttSessionTakenOver is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x8E

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttSessionTakenOver".clone()

primitive MqttTopicFilterInvalid is _MqttReasonCode
  """
  SUBACK, UNSUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x8F

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttTopicFilterInvalid".clone()

primitive MqttTopicNameInvalid is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, DISCONNECT
  """
  fun apply(): U8 =>
    0x90

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttTopicNameInvalid".clone()

primitive MqttPacketIdentifierInUse is _MqttReasonCode
  """
  PUBACK, PUBREC, SUBACK, UNSUBACK
  """
  fun apply(): U8 =>
    0x91

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttPacketIdentifierInUse".clone()

primitive MqttPacketIdentifierNotFound is _MqttReasonCode
  """
  PUBREL, PUBCOMP
  """
  fun apply(): U8 =>
    0x92

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttPacketIdentifierNotFound".clone()

primitive MqttReceiveMaximumExceeded is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x93

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttReceiveMaximumExceeded".clone()

primitive MqttTopicAliasInvalid is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x94

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttTopicAliasInvalid".clone()

primitive MqttPacketTooLarge is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x95

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttPacketTooLarge".clone()

primitive MqttMessageRateTooHigh is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x96

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttMessageRateTooHigh".clone()

primitive MqttQuotaExceeded is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x97

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttQuotaExceeded".clone()

primitive MqttAdministrativeAction is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0x98

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttAdministrativeAction".clone()

primitive MqttPayloadFormatInvalid is _MqttReasonCode
  """
  CONNACK, PUBACK, PUBREC, DISCONNECT
  """
  fun apply(): U8 =>
    0x99

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttPayloadFormatInvalid".clone()

primitive MqttRetainNotSupported is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9A

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttRetainNotSupported".clone()

primitive MqttQoSNotSupported is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9B

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttQoSNotSupported".clone()

primitive MqttUseAnotherServer is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9C

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttUseAnotherServer".clone()

primitive MqttServerMoved is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9D

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttServerMoved".clone()

primitive MqttSharedSubscriptionsNotSupported is _MqttReasonCode
  """
  SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9E

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttSharedSubscriptionsNotSupported".clone()

primitive MqttConnectionRateExceeded is _MqttReasonCode
  """
  CONNACK, DISCONNECT
  """
  fun apply(): U8 =>
    0x9F

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttConnectionRateExceeded".clone()

primitive MqttMaximumConnectTime is _MqttReasonCode
  """
  DISCONNECT
  """
  fun apply(): U8 =>
    0xA0

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttMaximumConnectTime".clone()

primitive MqttSubscriptionIdentifiersNotSupported is _MqttReasonCode
  """
  SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0xA1

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttSubscriptionIdentifiersNotSupported".clone()

primitive MqttWildcardSubscriptionsNotSupported is _MqttReasonCode
  """
  SUBACK, DISCONNECT
  """
  fun apply(): U8 =>
    0xA2

  fun eq(
    o: _MqttReasonCode)
  : Bool =>
    o is this

  fun string(): String iso^ => "MqttWildcardSubscriptionsNotSupported".clone()
