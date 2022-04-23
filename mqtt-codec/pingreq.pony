primitive _MqttPingReqEncoder
  fun apply(): Array[U8] iso^ =>
    recover iso [MqttPingReq(); 0] end
