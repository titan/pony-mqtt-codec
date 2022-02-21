use "buffered"

primitive MqttDecodeDone

primitive MqttDecodeContinue

primitive MqttDecodeError

type MqttDecodeResultType[A] is ((MqttDecodeDone, A) | (MqttDecodeContinue, Array[U8] val) | (MqttDecodeError, String))

primitive MqttDecoder
  fun apply(data: Array[U8] val, version: MqttVersion = MqttVersion5): MqttDecodeResultType[MqttControlPacketType] ? =>
    (let remaining, let remainlen) = try MqttVariableByteInteger.decode_array(data, 1) ? else (0, 0) end
    let remaining': USize = remaining.usize()
    if remaining' > ((data.size() - 1) - remainlen) then
      return (MqttDecodeContinue, data)
    end
    let reader = Reader
    reader.append(data)
    let header = reader.u8() ?
    reader.skip(remainlen) ?
    match (header and 0xF0)
    | MqttConnect() =>
      MqttConnectDecoder(consume reader, header, remaining') ?
    | MqttConnAck() =>
      MqttConnAckDecoder(consume reader, header, remaining', version) ?
    | MqttPublish() =>
      MqttPublishDecoder(consume reader, header, remaining', version) ?
    | MqttPubAck() =>
      MqttPubAckDecoder(consume reader, header, remaining', version) ?
    | MqttPubRec() =>
      MqttPubRecDecoder(consume reader, header, remaining', version) ?
    | MqttPubRel() =>
      MqttPubRelDecoder(consume reader, header, remaining', version) ?
    | MqttPubComp() =>
      MqttPubCompDecoder(consume reader, header, remaining', version) ?
    | MqttSubscribe() =>
      MqttSubscribeDecoder(consume reader, header, remaining', version) ?
    | MqttSubAck() =>
      MqttSubAckDecoder(consume reader, header, remaining', version) ?
    | MqttUnsubscribe() =>
      MqttUnsubscribeDecoder(consume reader, header, remaining', version) ?
    | MqttUnsubAck() =>
      MqttUnsubAckDecoder(consume reader, header, remaining', version) ?
    | MqttPingReq() =>
      (MqttDecodeDone, MqttPingReqPacket)
    | MqttPingResp() =>
      (MqttDecodeDone, MqttPingRespPacket)
    | MqttDisconnect() =>
      MqttDisconnectDecoder(consume reader, header, remaining', version) ?
    | MqttAuth() =>
      MqttAuthDecoder(consume reader, header, remaining') ?
    else
      (MqttDecodeError, "Unknown control packet type: " + (header and 0xF0).string())
    end