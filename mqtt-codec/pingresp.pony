primitive _MqttPingRespEncoder
  fun apply(): Array[U8] iso^=>
    recover iso [MqttPingResp(); 0] end
