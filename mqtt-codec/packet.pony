type MqttUserProperty is (String val, String val) // key => value

primitive MqttReversed
  fun apply(): U8 =>
    0x00

primitive MqttPingReq
  """
  PING request.

  Direction: Client to Server.
  """
  fun apply(): U8 =>
    0xC0

primitive MqttPingResp
  """
  PING response.

  Direction: Server to Client.
  """
  fun apply(): U8 =>
    0xD0

type MqttControlType is
  ( (MqttReversed, None)
  | (MqttConnect, MqttConnectPacket)
  | (MqttConnAck, MqttConnAckPacket)
  | (MqttPublish, MqttPublishPacket)
  | (MqttPubAck, MqttPubAckPacket)
  | (MqttPubRec, MqttPubRecPacket)
  | (MqttPubRel, MqttPubRelPacket)
  | (MqttPubComp, MqttPubCompPacket)
  | (MqttSubscribe, MqttSubscribePacket)
  | (MqttSubAck, MqttSubAckPacket)
  | (MqttUnSubscribe, MqttUnSubscribePacket)
  | (MqttUnSubAck, MqttUnSubAckPacket)
  | (MqttPingReq, None)
  | (MqttPingResp, None)
  | (MqttDisconnect, MqttDisconnectPacket)
  | (MqttAuth, MqttAuthPacket)
  )
