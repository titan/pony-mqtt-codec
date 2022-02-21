primitive MqttPingReqPacket
  fun encode(): Array[U8] val =>
    [MqttPingReq(); 0]
