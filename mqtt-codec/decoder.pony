use "buffered"

primitive MqttDecodeDone

primitive MqttDecodeContinue

primitive MqttDecodeError

type MqttDecodeResultType[A] is ((MqttDecodeDone, A, (Array[U8 val] val | None)) | (MqttDecodeContinue, Array[U8 val] val) | (MqttDecodeError, String val, Array[U8 val] val))

primitive MqttDecoder
  fun apply(data: Array[U8 val] val, version: MqttVersion box = MqttVersion5): MqttDecodeResultType[MqttControlPacketType val] val ? =>
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
      (MqttDecodeDone, MqttPingReqPacket, if reader.size() > 0 then reader.block(reader.size()) ? else None end)
    | MqttPingResp() =>
      (MqttDecodeDone, MqttPingRespPacket, if reader.size() > 0 then reader.block(reader.size()) ? else None end)
    | MqttDisconnect() =>
      MqttDisconnectDecoder(consume reader, header, remaining', version) ?
    | MqttAuth() =>
      MqttAuthDecoder(consume reader, header, remaining') ?
    else
      (MqttDecodeError, "Unknown control packet type: " + (header and 0xF0).string(), reader.block(reader.size()) ?)
    end
