use "collections"

type MqttAuthReasonCode is
  ( MqttSuccess
  | MqttContinueAuthentication
  | MqttReauthenticate
  )

type MqttAuthPacket is
  ( MqttAuthReasonCode // 1. reason code
  , (String val | None) // 2. authentication method
  , (Array[U8] val | None) // 3. authentication data
  , (String val | None) // 4. reason string
  , (Array[MqttUserProperty] val | None) // 5. user properties
  )

primitive MqttAuth
  """
  Authentication exchange

  Direction:
    1. Client to Server
    2. Server to Client
  """
  fun apply(): U8 =>
    0xF0

  fun reason_code(
    pkt: MqttAuthPacket)
  : MqttAuthReasonCode =>
    """
    The Authenticate Reason Code

    * mqtt-5
    """
    pkt._1

  fun authentication_method(
    pkt: MqttAuthPacket)
  : (String val | None) =>
    """
    It containing the name of the authentication method.

    * mqtt-5
    """
    pkt._2

  fun authentication_data(
    pkt: MqttAuthPacket)
  : (Array[U8] val | None) =>
    """
    The contents of this data are defined by the authentication method.

    * mqtt-5
    """
    pkt._3

  fun reason_string(
    pkt: MqttAuthPacket)
  : (String val | None) =>
    """
    This Reason String is a human readable string designed for diagnostics and
    SHOULD NOT be parsed by the Client.

    * mqtt-5
    """
    pkt._4

  fun user_properties(
    pkt: MqttAuthPacket)
  : (Array[MqttUserProperty] val | None) =>
    """
    User Properties on the AUTH packet can be used to send subscription related
    properties from the Client to the Server.

    * mqtt-5
    """
    pkt._5

  fun build(
    reason_code': MqttAuthReasonCode val = MqttSuccess,
    authentication_method': (String val | None) = None,
    authentication_data': (Array[U8] val | None) = None,
    reason_string': (String val | None) = None,
    user_properties': (Array[MqttUserProperty] val | None) = None)
  : MqttAuthPacket =>
    ( reason_code'
    , authentication_method'
    , authentication_data'
    , reason_string'
    , user_properties'
    )

primitive _MqttAuthDecoder
  fun apply(
    buf: Array[U8] val,
    offset: USize = 0,
    limit: USize = 0,
    header: U8 = MqttAuth())
  : MqttAuthPacket? =>
    var authentication_method: (String val | None) = None
    var authentication_data: (Array[U8] val | None) = None
    var reason_string: (String val | None) = None
    var user_properties: (Array[MqttUserProperty] iso | None) = None
    var reason_code: MqttAuthReasonCode = MqttSuccess
    if offset < limit then
      var offset' = offset
      reason_code =
        match buf(offset')?
        | MqttSuccess() => MqttSuccess
        | MqttContinueAuthentication() => MqttContinueAuthentication
        | MqttReauthenticate() => MqttReauthenticate
        else
          MqttSuccess
        end
      offset' = offset' + 1
      (let property_length', let property_length_size) = _MqttVariableByteInteger.decode(buf, offset')?
      offset' = offset' + property_length_size
      let property_length = property_length'.usize()
      var decoded_length: USize = 0
      user_properties = recover iso Array[MqttUserProperty] end
      while decoded_length < property_length do
        let identifier = buf(offset' + decoded_length)?
        decoded_length = decoded_length + 1
        match identifier
        | _MqttAuthenticationMethod() =>
          (let authentication_method': String iso, let authentication_method_size: USize) = _MqttAuthenticationMethod.decode(buf, offset' + decoded_length)?
          authentication_method = consume authentication_method'
          decoded_length = decoded_length + authentication_method_size
        | _MqttAuthenticationData() =>
          (let authentication_data': Array[U8] iso, let authentication_data_size: USize) = _MqttAuthenticationData.decode(buf, offset' + decoded_length)?
          authentication_data = consume authentication_data'
          decoded_length = decoded_length + authentication_data_size
        | _MqttReasonString() =>
          (let reason_string': String iso, let reason_string_size: USize) = _MqttReasonString.decode(buf, offset' + decoded_length)?
          reason_string = consume reason_string'
          decoded_length = decoded_length + reason_string_size
        | _MqttUserProperty() =>
          (let user_property: MqttUserProperty, let user_property_size: USize) = _MqttUserProperty.decode(buf, offset' + decoded_length)?
          try (user_properties as Array[MqttUserProperty] iso).push(user_property) end
          decoded_length = decoded_length + user_property_size
        end
      end
    end
    MqttAuth.build(
      reason_code,
      authentication_method,
      authentication_data,
      reason_string,
      consume user_properties
    )

primitive _MqttAuthMeasurer
  fun variable_header_size(
    packet: MqttAuthPacket,
    maximum_packet_size: USize = 0)
  : USize =>
    """
    The Reason Code and Property Length can be omitted if the Reason Code is
    0x00 (Success) and there are no Properties. In this case the AUTH has a
    Variable Header Size of 0.
    """
    var size: USize = 0
    size = 1 // reason code
    let properties_length = properties_size(packet, if maximum_packet_size != 0 then maximum_packet_size - size else 0 end)
    if (properties_length == 0) and (MqttAuth.reason_code(packet) == MqttSuccess) then
      return 0
    end
    size = size + _MqttVariableByteInteger.size(properties_length.ulong()) + properties_length
    size

  fun properties_size(
    packet: MqttAuthPacket,
    maximum_packet_size: USize = 0)
  : USize =>
    var size: USize = 0

    match MqttAuth.authentication_method(packet)
    | let authentication_method: String =>
      size = size + _MqttAuthenticationMethod.size(authentication_method)
    end

    match MqttAuth.authentication_data(packet)
    | let authentication_data: Array[U8] val =>
      size = size + _MqttAuthenticationData.size(authentication_data)
    end

    match MqttAuth.reason_string(packet)
    | let reason_string': String val =>
      let length = _MqttReasonString.size(reason_string')
      if maximum_packet_size != 0 then
        if maximum_packet_size >= (size + length) then
          size = size + length
        end
      else
        size = size + length
      end
    end

    match MqttAuth.user_properties(packet)
    | let user_properties: Array[MqttUserProperty] val =>
      if maximum_packet_size != 0 then
        for property in user_properties.values() do
          let property_size = _MqttUserProperty.size(property)
          if maximum_packet_size >= (size + property_size) then
            size = size + property_size
          else
            break
          end
        end
      else
        for property in user_properties.values() do
          size = size + _MqttUserProperty.size(property)
        end
      end
    end

    size

primitive _MqttAuthEncoder
  fun apply(
    packet: MqttAuthPacket,
    maximum_packet_size: USize = 0,
    remaining: USize = 0)
  : Array[U8] iso^ =>
    let total_size = _MqttVariableByteInteger.size(remaining.ulong()) + remaining + 1

    var buf = recover iso Array[U8](total_size) end

    buf.push(MqttAuth() or 0x02)
    buf = _MqttVariableByteInteger.encode(consume buf, remaining.ulong())

    var properties_length: USize = _MqttAuthMeasurer.properties_size(packet, maximum_packet_size)
    if properties_length > 0 then
      buf.push(MqttAuth.reason_code(packet)())

      buf = _MqttVariableByteInteger.encode(consume buf, properties_length.ulong())

      match MqttAuth.authentication_method(packet)
      | let authentication_method: String val =>
        buf = _MqttAuthenticationMethod.encode(consume buf, authentication_method)
      end

      match MqttAuth.authentication_data(packet)
      | let authentication_data: Array[U8] val =>
        buf = _MqttAuthenticationData.encode(consume buf, authentication_data)
      end

      match MqttAuth.reason_string(packet)
      | let reason_string: String val =>
        if (buf.size() + _MqttReasonString.size(reason_string)) <= total_size then
          buf = _MqttReasonString.encode(consume buf, reason_string)
        end
      end

      match MqttAuth.user_properties(packet)
      | let user_properties: Array[MqttUserProperty] val =>
        for property in user_properties.values() do
          if (buf.size() + _MqttUserProperty.size(property)) <= total_size then
            buf = _MqttUserProperty.encode(consume buf, property)
          end
        end
      end
    else
      if MqttAuth.reason_code(packet) != MqttSuccess then
        buf.push(MqttAuth.reason_code(packet)())
      end
    end

    consume buf
