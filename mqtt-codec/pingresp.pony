primitive MqttPingRespPacket
  fun encode(): Array[U8] val =>
    [MqttPingResp(); 0]
