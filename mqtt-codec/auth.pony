use "buffered"
use "collections"

type MqttAuthReasonCode is (MqttSuccess | MqttContinueAuthentication | MqttReauthenticate)

class MqttAuthPacket
  let reason_code: (MqttAuthReasonCode val | None)
  """
  The Authenticate Reason Code

  * mqtt-5
  """

  let authentication_method: (String val | None)
  """
  It containing the name of the authentication method.

  * mqtt-5
  """

  let authentication_data: (Array[U8 val] val | None)
  """
  The contents of this data are defined by the authentication method.

  * mqtt-5
  """

  let reason_string: (String val | None)
  """
  This Reason String is a human readable string designed for diagnostics and
  SHOULD NOT be parsed by the Client.

  * mqtt-5
  """

  let user_properties: (Map[String val, String val] val | None)
  """
  User Properties on the AUTH packet can be used to send subscription related
  properties from the Client to the Server.

  * mqtt-5
  """

  new iso create(
      reason_code': (MqttAuthReasonCode val | None) = None,
      authentication_method': (String val | None) = None,
      authentication_data': (Array[U8 val] val| None) = None,
      reason_string': (String val | None) = None,
      user_properties': (Map[String val, String val] val | None) = None
  ) =>
      reason_code = reason_code'
      authentication_method = authentication_method'
      authentication_data = authentication_data'
      reason_string = reason_string'
      user_properties = user_properties'

class MqttAuthDecoder
  fun apply(reader: Reader, header: U8 box, remaining: USize box): MqttDecodeResultType[MqttAuthPacket val] val ? =>
    var authentication_method: (String | None) = None
    var authentication_data: (Array[U8 val] val | None) = None
    var reason_string: (String | None) = None
    var user_properties: (Map[String val, String val] iso | None) = None
    var reason_code: (MqttAuthReasonCode | None) = MqttSuccess
    if remaining > 0 then
      reason_code =
        match reader.u8() ?
        | MqttSuccess() => MqttSuccess
        | MqttContinueAuthentication() => MqttContinueAuthentication
        | MqttReauthenticate() => MqttReauthenticate
        else
          None
        end
      (let property_length', _) = MqttVariableByteInteger.decode_reader(reader) ?
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      user_properties = recover iso Map[String val, String val] end
      while decoded_length < property_length do
        let identifier = reader.u8() ?
        decoded_length = decoded_length + 1
        match identifier
        | MqttAuthenticationMethod() =>
          (let authentication_method': String, let consumed: USize) = MqttAuthenticationMethod.decode(reader) ?
          authentication_method = authentication_method'
          decoded_length = decoded_length + consumed
        | MqttAuthenticationData() =>
          (let authentication_data': Array[U8 val] val, let consumed: USize) = MqttAuthenticationData.decode(reader) ?
          authentication_data = authentication_data'
          decoded_length = decoded_length + consumed
        | MqttReasonString() =>
          (let reason_string': String, let consumed: USize) = MqttReasonString.decode(reader) ?
          reason_string = reason_string'
          decoded_length = decoded_length + consumed
        | MqttUserProperty() =>
          (let user_property': (String val, String val), let consumed: USize) = MqttUserProperty.decode(reader) ?
          try (user_properties as Map[String val, String val] iso).insert(user_property'._1, user_property'._2) end
          decoded_length = decoded_length + consumed
        end
      end
    end
    let packet =
      MqttAuthPacket(
        reason_code,
        authentication_method,
        authentication_data,
        reason_string,
        consume user_properties
      )
    (MqttDecodeDone, packet, if reader.size() > 0 then reader.block(reader.size()) ? else None end)

primitive MqttAuthMeasurer
  fun variable_header_size(data: MqttAuthPacket box, maximum_packet_size: (USize box | None) = None): USize val =>
    """
    The Reason Code and Property Length can be omitted if the Reason Code is
    0x00 (Success) and there are no Properties. In this case the AUTH has a
    Variable Header Size of 0.
    """
    var size: USize = 0
    size = 1 // reason code
    let properties_length = properties_size(data, try (maximum_packet_size as USize box) - size else None end)
    if properties_length == 0 then
      match data.reason_code
      | let reason_code: MqttAuthReasonCode val =>
        if reason_code() == MqttSuccess() then
          return 0
        end
      else
        return 0
      end
    end
    size = size + MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    size

  fun properties_size(data: MqttAuthPacket box, maximum_packet_size: (USize box | None) = None): USize val =>
    var size: USize = 0

    size = size +
        match data.authentication_method
        | let authentication_method': String box =>
          MqttAuthenticationMethod.size(authentication_method')
        else
          0
        end

    size = size +
        match data.authentication_data
        | let authentication_data': Array[U8 val] box =>
          MqttAuthenticationData.size(authentication_data')
        else
          0
        end

    match data.reason_string
    | let reason_string': String box =>
      let length = MqttReasonString.size(reason_string')
      match maximum_packet_size
      | let maximum_packet_size': USize box =>
        if maximum_packet_size' >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match data.user_properties
    | let user_properties: Map[String val, String val] box =>
      match maximum_packet_size
      | let maximum_packet_size': USize box =>
        for item in user_properties.pairs() do
          let item_size = MqttUserProperty.size(item)
          if maximum_packet_size' >= (size + item_size) then
            size = size + item_size
          else
            break
          end
        end
      else
        for item in user_properties.pairs() do
          size = size + MqttUserProperty.size(item)
        end
      end
    end

    size

primitive MqttAuthEncoder
  fun apply(data: MqttAuthPacket box, maximum_packet_size: (USize box | None) = None): Array[U8 val] val =>
    var maximum_size: (USize | None) = None
    var remaining: USize = 0
    match maximum_packet_size
    | let maximum_packet_size': USize box =>
      var maximum: USize = maximum_packet_size' - 1 - 1
      remaining = MqttAuthMeasurer.variable_header_size(data, maximum)
      var remaining_length = MqttVariableByteInteger.size(remaining.ulong())
      maximum = maximum - remaining_length
      var delta: USize = 0
      repeat
        maximum = maximum - delta
        let remaining': USize = MqttAuthMeasurer.variable_header_size(data, maximum)
        let remaining_length': USize = MqttVariableByteInteger.size(remaining'.ulong())
        delta = remaining_length - remaining_length'
        remaining = remaining'
        remaining_length = remaining_length'
      until delta == 0 end
      maximum_size = maximum
    else
      remaining = MqttAuthMeasurer.variable_header_size(data, None)
    end

    let total_size = MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = Array[U8 val](total_size)

    buf.push(MqttAuth() or 0x02)
    MqttVariableByteInteger.encode(buf, remaining.ulong())

    var properties_length: USize = MqttAuthMeasurer.properties_size(data, maximum_size)
    if properties_length > 0 then
      match data.reason_code
      | let reason_code: MqttAuthReasonCode =>
        buf.push(reason_code())
      else
        buf.push(MqttSuccess())
      end

      MqttVariableByteInteger.encode(buf, properties_length.ulong())

      match data.authentication_method
      | let authentication_method: String box =>
        MqttAuthenticationMethod.encode(buf, authentication_method)
      end

      match data.authentication_data
      | let authentication_data: Array[U8 val] box =>
        MqttAuthenticationData.encode(buf, authentication_data)
      end

      match data.reason_string
      | let reason_string: String box =>
        if (buf.size() + MqttReasonString.size(reason_string)) <= total_size then
          MqttReasonString.encode(buf, reason_string)
        end
      end

      match data.user_properties
      | let user_properties: Map[String val, String val] box =>
        for item in user_properties.pairs() do
          if (buf.size() + MqttUserProperty.size(item)) <= total_size then
            MqttUserProperty.encode(buf, item)
          end
        end
      end
    else
      match data.reason_code
      | let reason_code: MqttAuthReasonCode box =>
        if reason_code() != MqttSuccess() then
          buf.push(reason_code())
        end
      end
    end

    U8ArrayClone(buf)
