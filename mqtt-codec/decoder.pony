primitive MqttDecodeDone

primitive MqttDecodeContinue

primitive MqttDecodeError

type MqttDecodeResultType[A] is
  ( (MqttDecodeDone, A, (Array[U8] iso^ | None))
  | (MqttDecodeContinue, Array[U8] iso^)
  | (MqttDecodeError, String val)
  )

primitive MqttDecoder
  fun apply(
    data: Array[U8] iso,
    version: MqttVersion = MqttVersion5)
  : MqttDecodeResultType[MqttControlType]? =>
    let datasize: USize = data.size()
    let data': Array[U8] iso =
      try
        recover iso
          match datasize
          | 0 => [0; 0]
          | 1 => [0; 0]
          | 2 => [data(0)?; data(1)?]
          | 3 => [data(0)?; data(1)?; data(2)?]
          | 4 => [data(0)?; data(1)?; data(2)?; data(3)?]
          else
            [data(0)?; data(1)?; data(2)?; data(3)?; data(4)?]
          end
        end
      else
        [0; 0]
      end
    (let remaining', let remaining_size) = try _MqttVariableByteInteger.decode(consume data', 1, datasize)? else (0, 1) end
    let remaining: USize = remaining'.usize()
    match remaining.isize() - (datasize - 1 - remaining_size).isize()
    | let x: ISize if x > 0 =>
      return (MqttDecodeContinue, consume data)
    | let x: ISize if x == 0 =>
      let header = data(0)?
      let limit = 1 + remaining + remaining_size
      _dispatch(consume data, 1 + remaining_size, limit, header, None, version)?
    else
      let header = data(0)?
      let limit = 1 + remaining + remaining_size
      let remained_size = datasize - limit
      (let data'', let remained) = (consume data).chop(limit)
      _dispatch(consume data'', 1 + remaining_size, limit, header, consume remained, version)?
    end

  fun _dispatch(
    buf: Array[U8] iso,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = 0,
    remained: (Array[U8] iso | None) = None,
    version: MqttVersion = MqttVersion5)
  : MqttDecodeResultType[MqttControlType]? =>
    match (header and 0xF0)
    | MqttConnect() =>
      (MqttDecodeDone, (MqttConnect, _MqttConnectDecoder(consume buf, offset, limit, header)?), remained)
    | MqttConnAck() =>
      (MqttDecodeDone, (MqttConnAck, _MqttConnAckDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttPublish() =>
      (MqttDecodeDone, (MqttPublish, _MqttPublishDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttPubAck() =>
      (MqttDecodeDone, (MqttPubAck, _MqttPubAckDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttPubRec() =>
      (MqttDecodeDone, (MqttPubRec, _MqttPubRecDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttPubRel() =>
      (MqttDecodeDone, (MqttPubRel, _MqttPubRelDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttPubComp() =>
      (MqttDecodeDone, (MqttPubComp, _MqttPubCompDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttSubscribe() =>
      (MqttDecodeDone, (MqttSubscribe, _MqttSubscribeDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttSubAck() =>
      (MqttDecodeDone, (MqttSubAck, _MqttSubAckDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttUnSubscribe() =>
      (MqttDecodeDone, (MqttUnSubscribe, _MqttUnSubscribeDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttUnSubAck() =>
      (MqttDecodeDone, (MqttUnSubAck, _MqttUnSubAckDecoder(consume buf, offset, limit, header, version)?), remained)
    | MqttPingReq() =>
      (MqttDecodeDone, (MqttPingReq, None), remained)
    | MqttPingResp() =>
      (MqttDecodeDone, (MqttPingResp, None), remained)
    | MqttDisconnect() =>
      (MqttDecodeDone, (MqttDisconnect, _MqttDisconnectDecoder(consume buf, offset, limit,  header, version)?), remained)
    | MqttAuth() =>
      (MqttDecodeDone, (MqttAuth, _MqttAuthDecoder(consume buf, offset, limit, header)?), remained)
    else
      (MqttDecodeError, "Unknown control packet type: " + (header and 0xF0).string())
    end
