defmodule Tinymesh.Proto do

  use Bitwise

  defexception PacketError, message: "default", field: "unknown", extra: []

  defmacro cmd(uid, type, packetnum) do
    quote do
      {:ok, [
        {"uid", unquote(uid)},
        {"cmd_number", unquote(packetnum)},
        {"type", "command"},
        {"command", unquote(type)}
      ]}
    end
  end
  defmacro cmd(uid, type, packetnum, extra) do
    quote do
      {:ok, [
        {"uid", unquote(uid)},
        {"cmd_number", unquote(packetnum)},
        {"type", "command"},
        {"command", unquote(type)},
        unquote_splicing(extra)
      ]}
    end
  end

  defmacro ev(sid, uid, rssi, netlvl, hops, packetnum,
      latency, extra) do
    quote do
      {:ok, [
        {"sid", unquote(sid)},
        {"uid", unquote(uid)},
        {"rssi", unquote(rssi)},
        {"network_lvl", unquote(netlvl)},
        {"hops", unquote(hops)},
        {"packet_number", unquote(packetnum)},
        {"latency", unquote(latency)},
        {"type", "event"},
        unquote_splicing(extra)
      ]}
    end
  end

  defmacrop p_init_gw_config(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3,  5, 0, 0>>)

  defmacrop p_get_nid(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 16, 0, 0>>)

  defmacrop p_get_status(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 17, 0, 0>>)

  defmacrop p_get_did_status(uid, packetnum),  do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 18, 0, 0>>)

  defmacrop p_get_config(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 19, 0, 0>>)

  defmacrop p_get_calibration(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 20, 0, 0>>)

  defmacrop p_force_reset(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 21, 0, 0>>)

  defmacrop p_get_path(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3, 22, 0, 0>>)

  defmacrop p_set_output(uid, packetnum, on, off), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3,  1, unquote(on), unquote(off)>>)

  defmacrop p_set_pwm(uid, packetnum, pwm), do:
    quote(do: <<10, unquote(uid) :: [size(32), little()], unquote(packetnum), 3,  2, unquote(pwm), 0>>)

  defmacrop p_set_config(uid, packetnum, cfg), do:
    quote(do: <<40, unquote(uid) :: [size(32), little()], unquote(packetnum), 3,  3, unquote(cfg) :: [size(32), binary()]>>)

  defmacro p_serial_out(checksum, uid, packetnum, data), do:
    quote(do: <<unquote(checksum), unquote(uid) :: [size(32), little()], unquote(packetnum), 17, unquote(data) :: binary()>>)

  # Events
  defmacrop p_event(sid, uid, rssi, netlvl, hops, packetnum, latency) do
    quote do
      <<
      unquote(sid) :: [size(32), little()],
      unquote(uid) :: [size(32), little()],
      unquote(rssi) :: [size(8)],
      unquote(netlvl) :: [size(8)],
      unquote(hops) :: [size(8)],
      unquote(packetnum) :: [size(16)],
      unquote(latency) :: [size(16)]
      >>
    end
  end

  defmacrop p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                 detail, data, address, temp, volt, dio, aio0, aio1, hw, fw) do
    quote do
       <<35, p_event(unquote(sid),unquote(uid),unquote(rssi),unquote(netlvl),
                     unquote(hops),unquote(packetnum),unquote(latency)),
         2,
         unquote(detail) :: size(8),
         unquote(data) :: size(16),
         unquote(address) :: size(32),
         unquote(temp) :: size(8),
         unquote(volt) :: size(8),
         unquote(dio)  :: size(8),
         unquote(aio0)  :: size(16),
         unquote(aio1)  :: size(16),
         unquote(hw)  :: size(16),
         unquote(fw)  :: size(16)
         >>
    end
  end


  def unserialize(buf) do
    try do
      unserialize buf, ""
    rescue
      e in PacketError ->
        {:error, [:packet_error, [
          {:field, e.field}, {:message, e.message} | e.extra]]}
    end
  end

  defp unserialize(p_init_gw_config(uid, packetnum), _ctx), do:
    cmd(uid, "init_gw_config", packetnum)

  defp unserialize(p_get_nid(uid, packetnum), _ctx), do:
    cmd(uid, "get_nid", packetnum)

  defp unserialize(p_get_status(uid, packetnum), _ctx), do:
    cmd(uid, "get_status", packetnum)

  defp unserialize(p_get_did_status(uid, packetnum), _ctx), do:
    cmd(uid, "get_did_status", packetnum)

  defp unserialize(p_get_config(uid, packetnum), _ctx), do:
    cmd(uid, "get_config", packetnum)

  defp unserialize(p_get_calibration(uid, packetnum), _ctx), do:
    cmd(uid, "get_calibration", packetnum)

  defp unserialize(p_force_reset(uid, packetnum), _ctx), do:
    cmd(uid, "force_reset", packetnum)

  defp unserialize(p_get_path(uid, packetnum), _ctx), do:
    cmd(uid, "get_path", packetnum)

  defp unserialize(p_set_output(uid, packetnum, on, off), _ctx) do
    <<on7 :: size(1), on6 :: size(1), on5 :: size(1), on4 :: size(1),
      on3 :: size(1), on2 :: size(1), on1 :: size(1), on0 :: size(1)>> = <<on>>

    <<off7 :: size(1), off6 :: size(1), off5 :: size(1), off4 :: size(1),
      off3 :: size(1), off2 :: size(1), off1 :: size(1), off0 :: size(1)>> = <<off>>

    map = Enum.zip [on7, on6, on5, on4, on3, on2, on1, on0],
                   [off7, off6, off5, off4, off3, off2, off1, off0]

    {_, gpios} = Enum.reduce map, {7, []}, fn
      ({0, 0}, {n, acc}) -> {n - 1, acc}
      ({1, 0}, {n, acc}) -> {n - 1, [{"gpio_#{n}", true} | acc]}
      ({_, 1}, {n, acc}) -> {n - 1, [{"gpio_#{n}", false} | acc]}
    end

    cmd uid, "set_output", packetnum, [{"gpio", gpios}]
  end
  defp unserialize(p_set_pwm(uid, packetnum, pwm), _ctx) do
    cond do
      pwm > 0 and pwm < 100 ->
        cmd(uid, "set_pwm", packetnum, [{"pwm", pwm}])

      true ->
        {:error, [:pwm_bounds, [{:packet, packetnum}, {:uid, uid}]]}
    end
  end
  defp unserialize(p_serial_out(checksum, uid, packetnum, data), _ctx) do
    datasize = checksum - 7
    cond do
      size(data) == datasize ->
        cmd(uid, "serial", packetnum, [{"data", data}])

      true ->
        {:error, [:serial_data_size, [{:packet, packetnum}, {:uid, uid}]]}
    end
  end
  defp unserialize(p_set_config(_uid, _packetnum, _cfg), _ctx) do
  end


  # Events

  # event/io_change
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 1 do

    {_, triggers} = Enum.reduce gpiomap(data &&& 255), {0, []}, fn
      (1, {p, acc}) -> {p+1, ["gpio_#{p}"|acc]};
      (0, {p, acc}) -> {p+1, acc}
    end

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)}, {"triggers", triggers},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}]
  end

  # event/aio0_change event/aio1_change event/network_taken
  # event/network_free event/network_jammed event/network_shared
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
        when detail in [2, 3, 10, 11, 12, 13] do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}]
  end

  # event/tamper
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 6 do

    duration = data >>> 8
    ended    = data &&& 255

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"duration", duration},
      {"ended",    ended},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/reset
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 8 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"trigger", reset_to_str(data &&& 255)},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 9 do
      #when detail === 9 and fw < <<1,64>> do # for pre 1.40 firmware

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"data", data},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 9 and fw < <<1,64>> do # for pre 1.40 firmware

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"trigger", reset_to_str(data &&& 255)},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/zacima - ONLY for compatibility
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 14 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"msg_data", data},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"digital_io_0", 1 &&& (dio >>> 0)},
      {"digital_io_1", 1 &&& (dio >>> 1)},
      {"digital_io_2", 1 &&& (dio >>> 2)},
      {"digital_io_3", 1 &&& (dio >>> 3)},
      {"digital_io_4", 1 &&& (dio >>> 4)},
      {"digital_io_5", 1 &&& (dio >>> 5)},
      {"digital_io_6", 1 &&& (dio >>> 6)},
      {"digital_io_7", 1 &&& (dio >>> 7)},
      {"analog_io_0", aio0},
      {"analog_io_1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/ack - gw
  defp unserialize(<<20, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, 16, cmdnum, _>>, _ctx) do
    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(16)},
      {"cmd_number", cmdnum}
    ]
  end

  defp unserialize(<<20, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, 17, cmdnum, reason>>, _ctx) do
    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(17)},
      {"cmd_number", cmdnum},
      {"reason", nak_trigger_to_str(reason)}
    ]
  end

  # event/ack - node
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 16 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"cmd_number", (data &&& 65280) >>> 8},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/nak - node
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 17 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"cmd_number", (data &&& 65280) >>> 8},
      {"reason", nak_trigger_to_str((data &&& 255))},
      {"locator", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/nid - node
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 18 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"nid", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/next_receiver
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 19 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"receiver", address},
      {"temp", temp - 128},
      {"volt", ((volt * 0.03) * 100) * 0.01},
      {"dio", Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio))},
      {"aio0", aio0},
      {"aio1", aio1},
      {"hw", encvsn(hw)},
      {"fw", encvsn(fw)}
    ]
  end

  # event/path
  defp unserialize(<<chksum, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, detail,
                     rest :: binary()>>, _ctx)
      when detail === 32 and size(rest) === chksum-17 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
      {"detail", detail_to_str(detail)},
      {"path", unpack_path(rest)}
    ]
  end

  # event/config
  defp unserialize(<<chksum, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, detail,
                     rest :: binary()>>, _ctx)
      when detail === 33 and size(rest) === chksum-18 do

    case Tinymesh.Config.unserialize rest do
      {:ok, config} ->
        ev sid, uid, rssi, netlvl, hops, packetnum, latency, [
          {"detail", detail_to_str(detail)},
          {"config", config_to_hash(config)}]

      {:error, _} = err ->
        err
    end
  end

  # fallback and die
  defp unserialize(<<chksum, p_event(_, uid, _, _, _, packetnum, _), 2, rest :: binary>>, _ctx) do
    <<detail>> = String.first rest

    cond do
      chksum !== size(rest) + 17 ->
        {:error, [:checksum, [{:packet, packetnum}, {:uid, uid}, {:detail, detail}]]}

      size(rest) >= 3 -> # Only ACK/NAK have that short packet
        {:error, [:invalid_event, [{:packet, packetnum}, {:uid, uid}, {:detail, detail}]]}

      true ->
        <<t>> = String.first rest
        {:error, [:invalid_type, [{:packet, packetnum}, {:uid, uid}, {:type, t}]]}
    end
  end
  defp unserialize(<<chksum, uid :: [size(32), little()], packetnum, 3, rest :: binary()>>, _ctx) do
    cond do
      chksum !== size(rest) + 6 ->
        {:error, [:checksum, [{:packet, packetnum}, {:uid, uid}]]}

      size(rest) < 3 ->
        {:error, [:no_type, [{:packet, packetnum}, {:uid, uid}]]}

      true ->
        <<t>> = String.first rest
        {:error, [:invalid_type, [{:packet, packetnum}, {:uid, uid}, {:type, t}]]}
    end
  end

  def serialize(msg), do:
    pack(msg["type"], msg["command"] || msg["detail"], msg)

  defp packitems(msg, keys, f), do: packitems(msg, keys, f, [])
  defp packitems(_msg, [], f, acc), do: apply(f, Enum.reverse(acc))
  defp packitems(msg, [k|rest], f, acc) do
    case Dict.get(msg, k) do
      nil ->
        {:error, [:missing_field, [{:field, k}]]}

      val ->
        packitems(msg, rest, f, [val|acc])

    end
  end

  defp pack("command", "init_gw_config", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_init_gw_config(a,b)} end)
  defp pack("command", "get_nid", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_nid(a,b)} end)
  defp pack("command", "get_status", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_status(a,b)} end)
  defp pack("command", "get_did_status", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_did_status(a,b)} end)
  defp pack("command", "get_calibration", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_calibration(a,b)} end)
  defp pack("command", "get_config", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_config(a,b)} end)
  defp pack("command", "force_reset", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_force_reset(a,b)} end)
  defp pack("command", "get_path", msg), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_path(a,b)} end)
  defp pack("command", "set_output", msg), do:
    packitems(msg, ["uid", "cmd_number","gpio"], fn(a,b,gpios) ->
        on  = pack_dio gpios, true
        off = pack_dio gpios, false
        {:ok, p_set_output(a,b, on, off)}
    end)
  defp pack("command", "set_pwm", msg), do:
    packitems(msg, ["uid", "cmd_number","pwm"], fn(a,b,pwm) ->
        {:ok, p_set_pwm(a,b, pwm)}
    end)
  defp pack("command", "serial", msg), do:
    packitems(msg, ["uid", "cmd_number","data"], fn(a,b,data) ->
        {:ok, p_serial_out(7 + size(data), a, b, data)}
    end)

  @gen "___gen___"
  @genev_keys ["sid", "uid", "rssi", "network_lvl", "hops", "packet_number",
               "latency", "detail", "data", "address", "temp", "volt", "dio",
               "aio0", "aio1", "hw", "fw"]

  defp pack("event", "io_change", msg) do
    case Enum.map ["triggers", "locator"], &Dict.get(msg, &1) do
      [nil, _] -> {:error, [:missing_field, [{:field, "triggers"}]]}
      [_, nil] -> {:error, [:missing_field, [{:field, "locator"}]]}
      [triggers, locator] ->
        changes = Enum.reduce(triggers, 0,
          fn(<<"gpio_", pin :: integer()>>, acc) ->
            :math.pow(2, pin - 48) + acc
          end) |> trunc

        msg = Dict.merge msg, [{"data", changes}, {"address", locator}]
        pack("event", @gen, msg)
    end
  end

  defp pack("event", detail, msg) when detail in [
      "aio0_change", "aio1_change", "network_taken", "network_free",
      "network_jammed", "network_shared"] do

    msg = Dict.merge [{"data", 0}, {"address", msg["locator"]}], msg
    pack("event", @gen, msg)
  end

  defp pack("event", "tamper", msg) do
    case Enum.map ["duration", "ended"], &Dict.get(msg, &1) do
      [nil, _] -> {:error, [:missing_field, [{:field, "duration"}]]}
      [_, nil] -> {:error, [:missing_field, [{:field, "ended"}]]}
      [duration, ended] ->
        data = (duration <<< 8) + ended
        msg = Dict.put Dict.put(msg, "address", msg["locator"]), "data", data
        pack("event", @gen, msg)
    end
  end

  defp pack("event", "reset", msg) do
    data = reset_to_int Dict.get(msg, "trigger")
    msg = Dict.put Dict.put(msg, "address", msg["locator"]), "data", data
    pack("event", @gen, msg)
  end

  defp pack("event", "ima", msg) do
    msg = Dict.put(msg, "address", msg["locator"])
    pack("event", @gen, msg)
  end

  defp pack("event", "zacima", msg) do
    gpios = Enum.filter msg, fn({"digital_io_" <> _, _}) -> true
                                                       _ -> false end

    msg = Dict.merge msg, [{"address", msg["locator"]},
                           {"data", msg["msg_data"]},
                           {"aio0", msg["analog_io_0"]},
                           {"aio1", msg["analog_io_1"]},
                           {"dio", gpios}]

    pack("event", @gen, msg)
  end

  defp pack("event", detail, msg) when detail in ["ack", "nak"] do
    if Dict.get(msg, "locator") do
      case Enum.map ["cmd_number", "reason", "locator"], &Dict.get(msg, &1) do
        [nil, _, _] -> {:error, [:missing_field, [{:field, "cmd_number"}]]}
        [_, _, nil] -> {:error, [:missing_field, [{:field, "locator"}]]}
        [_, nil, _] when detail == "nak" ->
          {:error, [:missing_field, [{:field, "reason"}]]}

        [cmdnum, nil, locator] when detail == "ack" ->
          data = :binary.decode_unsigned <<cmdnum, 0>>
          msg  = Dict.merge msg, [{"data", data}, {<<"address">>, locator}]
          pack("event", @gen, msg)

        [cmdnum, reason, locator] when detail == "nak" ->
          data = :binary.decode_unsigned <<cmdnum, nak_trigger_to_int(reason)>>
          msg = Dict.merge msg, [{"data", data}, {<<"address">>, locator}]
          pack("event", @gen, msg)
      end
    else
      keys = ["sid", "uid", "rssi", "network_lvl", "hops", "packet_number",
              "latency", "detail", "cmd_number"]
      reason = case msg["reason"] do
        nil -> 0
        r   -> nak_trigger_to_int(r)
      end
      packitems msg, keys, fn(sid, uid, rssi, network_lvl, hops,
                             packet_num, latency, detail, cmdnum) ->

        {:ok, <<20, p_event(sid, uid, rssi, network_lvl, hops,
                            packet_num, latency),
                2, detail_to_int(detail), cmdnum, reason>>}
      end
    end
  end

  defp pack("event", "nid", msg) do
    case Dict.fetch msg, "nid" do
      :error -> {:error, [:missing_field, [{:field, "nid"}]]}
      {:ok, val} ->
        # Data field should always be 0 for event/nid
        msg = Dict.merge msg, [{"address", val}, {"data", 0}]
        pack("event", @gen, msg)
    end
  end

  defp pack("event", "next_receiver", msg) do
    case Dict.fetch msg, "receiver" do
      :error -> {:error, [:missing_field, [{:field, "receiver"}]]}
      {:ok, val} ->
        msg = Dict.merge msg, [{"address", val}, {"data", 0}]
        pack("event", @gen, msg)
    end
  end

  defp pack("event", "path", msg) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "path"],
      fn(sid, uid, rssi, network_lvl, hops, packet_num,
         latency, detail, path) ->

        path = pack_path path
        checksum = 17 + size(path)
        {:ok, <<checksum, p_event(sid, uid, rssi, network_lvl, hops,
                                  packet_num, latency),
                2, detail_to_int(detail), path :: binary()>>}
      end
  end

  defp pack("event", "config", msg) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "config"],
      fn(sid, uid, rssi, network_lvl, hops, packet_num,
         latency, detail, config) ->

        vsn = config["device"]["fw_version"]
        case Tinymesh.Config.serialize config_to_proplist(config), vsn, true do
          {:ok, config} ->
            config = strip_config_address config
            checksum = 18 + size(config)
            {:ok, <<checksum, p_event(sid, uid, rssi, network_lvl, hops,
                                      packet_num, latency),
                    2, detail_to_int(detail), config :: binary()>>}

          {:error, _} = err ->
            err
        end
      end
  end

  defp pack("event", "calibration", msg) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "calibration"],
      fn(sid, uid, rssi, network_lvl, hops, packet_num,
         latency, detail, config) ->

        case Tinymesh.Config.serialize config_to_proplist(config) do
          {:ok, calibration} ->
            calibration = strip_config_address calibration
            checksum = 18 + size(calibration)
            {:ok, <<checksum, p_event(sid, uid, rssi, network_lvl, hops,
                                      packet_num, latency),
                    2, detail_to_int(detail), calibration :: binary()>>}

          {:error, _} = err ->
            err
        end
      end
  end

  defp pack("event", @gen, msg) do
    packitems msg, @genev_keys, fn(sid, uid, rssi, network_lvl, hops,
                                   packet_num, latency, detail, data,
                                   address, temp, volt, dio, aio0, aio1, hw, fw) ->

      # some special conversion is in order
      detail = detail_to_int detail
      dio = pack_dio dio
      {hw, fw} = {decvsn(hw), decvsn(fw)}
      volt = :erlang.trunc(volt / 0.03)
      temp = temp + 128

      {:ok, p_gen_ev(sid, uid, rssi, network_lvl, hops, packet_num,
                     latency, detail, data, address, temp, volt,
                     dio, aio0, aio1, hw, fw)}
    end
  end

#  defmacrop p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
#                 detail, data, address, temp, volt, dio, aio0, aio1, hw, fw) do

  defp pack(type, subtype, msg), do:
    {:error, [:invalid_type, [
        {:type, "#{type}/#{subtype}"},
        {:packet, msg["packet_number"] || msg["cmd_number"]},
        {:uid, msg["uid"]}]]}

  defp pack_dio(dio), do: pack_dio(dio, 1)
  defp pack_dio(dio, match), do: pack_dio2(dio, match, 0)

  defp pack_dio2([], _, acc), do: trunc(acc)
  defp pack_dio2([{"digital_io_" <> <<pin>>, m}|rest], m, acc) do
    pack_dio2(rest, m, :math.pow(2, pin - 48) + acc)
  end
  defp pack_dio2([{"gpio_" <> <<pin>>, m}|rest], m, acc) do
    pack_dio2(rest, m, :math.pow(2, pin - 48) + acc)
  end
  defp pack_dio2([{_, _}|rest], m, acc) do
    pack_dio2(rest, m, acc)
  end


  defp encvsn(vsn) do
    <<x :: size(8), y :: size(4), z :: size(4)>> = <<vsn :: size(16)>>
    "#{x}.#{y}#{z}"
  end

  defp decvsn(<<x, ".", y, z>>) do
    :binary.decode_unsigned(<<x - 48, (y-48) :: size(4), (z-48) :: size(4)>>)
  end

  defp gpiomap(dio) do
    [1 &&& (dio >>> 0),
     1 &&& (dio >>> 1),
     1 &&& (dio >>> 2),
     1 &&& (dio >>> 3),
     1 &&& (dio >>> 4),
     1 &&& (dio >>> 5),
     1 &&& (dio >>> 6),
     1 &&& (dio >>> 7)]
  end

  defp unpack_path(path), do: unpack_path(path, 1, [])
  defp unpack_path("", _, acc), do: acc
  defp unpack_path(<<rssi, uid :: [little(), size(32)], rest :: binary()>>, hop, acc) do
    unpack_path(rest, hop + 1, [{"#{hop}", [rssi, uid]} | acc])
  end

  defp pack_path(paths), do: pack_path(Enum.sort(paths) |> Enum.reverse, "")
  defp pack_path([], acc), do: acc
  defp pack_path([{_, [rssi, uid]} | rest], acc) do
    pack_path(rest, <<rssi, uid :: [little(), size(32)], acc :: binary()>>)
  end

  defp config_to_hash(config),  do: config_to_hash(config, [])
  defp config_to_hash([], acc), do: acc
  defp config_to_hash([{k, v} | rest], acc) do
    config_to_hash(rest, set_deep(acc, k, v))
  end

  defp set_deep(dict, [k], v), do: Dict.put(dict, k, v)
  defp set_deep(dict, [k|rest], v) do
    Dict.put dict, k, set_deep(dict[k] || [], rest, v)
  end

  defp config_to_proplist(dict), do: config_to_proplist(dict, [], [])
  defp config_to_proplist([], _kacc, dict), do: dict
  defp config_to_proplist([{k, v} | rest], kacc, dict) when is_list(v) do
    config_to_proplist rest, kacc, config_to_proplist(v, [k| kacc], dict)
  end
  defp config_to_proplist([{k, v} | rest], kacc, dict) do
    config_to_proplist rest, kacc, Dict.put(dict, Enum.reverse([k|kacc]), v)
  end

  defp strip_config_address(buf), do: strip_config_address(buf, String.duplicate(<<0>>, 120))
  defp strip_config_address("", acc), do: acc
  defp strip_config_address(<<at, v, rest :: binary>>, acc) do
    <<a :: [size(at), binary()], _, b :: binary>> = acc
    asize = size(a)
    strip_config_address rest, <<a :: [binary(), size(asize)], v, b :: binary()>>
  end

  defp detail_to_int("io_change"),      do: 1
  defp detail_to_int("aio0_change"),    do: 2
  defp detail_to_int("aio1_change"),    do: 3
  defp detail_to_int("tamper"),         do: 6
  defp detail_to_int("reset"),          do: 8
  defp detail_to_int("ima"),            do: 9
  defp detail_to_int("network_taken"),  do: 10
  defp detail_to_int("network_free"),   do: 11
  defp detail_to_int("network_jammed"), do: 12
  defp detail_to_int("network_shared"), do: 13
  defp detail_to_int("zacima"),         do: 14
  defp detail_to_int("ack"),            do: 16
  defp detail_to_int("nak"),            do: 17
  defp detail_to_int("nid"),            do: 18
  defp detail_to_int("next_receiver"),  do: 19
  defp detail_to_int("path"),           do: 32
  defp detail_to_int("config"),         do: 33
  defp detail_to_int("calibration"),    do: 34
  defp detail_to_int(n), do:
    raise(PacketError, field: "detail", message: "invalid event detail '#{n}' (-> int)")

  defp detail_to_str( 1), do: "io_change"
  defp detail_to_str( 2), do: "aio0_change"
  defp detail_to_str( 3), do: "aio1_change"
  defp detail_to_str( 6), do: "tamper"
  defp detail_to_str( 8), do: "reset"
  defp detail_to_str( 9), do: "ima"
  defp detail_to_str(10), do: "network_taken"
  defp detail_to_str(11), do: "network_free"
  defp detail_to_str(12), do: "network_jammed"
  defp detail_to_str(13), do: "network_shared"
  defp detail_to_str(14), do: "zacima"
  defp detail_to_str(16), do: "ack"
  defp detail_to_str(17), do: "nak"
  defp detail_to_str(18), do: "nid"
  defp detail_to_str(19), do: "next_receiver"
  defp detail_to_str(32), do: "path"
  defp detail_to_str(33), do: "config"
  defp detail_to_str(34), do: "calibration"
  defp detail_to_str(n), do:
    raise(PacketError, field: "detail", message: "invalid event detail '#{n}' (-> str)")

  defp nak_trigger_to_str( 1), do: "packet_length"
  defp nak_trigger_to_str( 2), do: "bad_gw_config"
  defp nak_trigger_to_str( 3), do: "bad_gw_packet_format"
  defp nak_trigger_to_str( 4), do: "bad_gw_command"
  defp nak_trigger_to_str(16), do: "bad_node_config_length"
  defp nak_trigger_to_str(17), do: "bad_node_config"
  defp nak_trigger_to_str(18), do: "bad_node_packet_format"
  defp nak_trigger_to_str(19), do: "bad_node_command"
  defp nak_trigger_to_str(n), do:
    raise(PacketError, field: "reason", message: "invalid nak reason '#{n}' (-> str)")

  defp nak_trigger_to_int("packet_length"),          do:  1
  defp nak_trigger_to_int("bad_gw_config"),          do:  2
  defp nak_trigger_to_int("bad_gw_packet_format"),   do:  3
  defp nak_trigger_to_int("bad_gw_command"),         do:  4
  defp nak_trigger_to_int("bad_node_config_length"), do: 16
  defp nak_trigger_to_int("bad_node_config"),        do: 17
  defp nak_trigger_to_int("bad_node_packet_format"), do: 18
  defp nak_trigger_to_int("bad_node_command"),       do: 19
  defp nak_trigger_to_int(n), do:
    raise(PacketError, field: "reason", message: "invalid nak reason '#{n}' (-> int)")

  defp reset_to_int("power"),           do: 1
  defp reset_to_int("pin"),             do: 2
  defp reset_to_int("sleep_or_config"), do: 3
  defp reset_to_int("command"),         do: 4
  defp reset_to_int("watchdog"),        do: 5
  defp reset_to_int(n), do:
    raise(PacketError, field: "trigger", message: "invalid reset type '#{n}' (-> int")

  defp reset_to_str(1), do: "power"
  defp reset_to_str(2), do: "pin"
  defp reset_to_str(3), do: "sleep_or_config"
  defp reset_to_str(4), do: "command"
  defp reset_to_str(5), do: "watchdog"
  defp reset_to_str(n), do:
    raise(PacketError, field: "trigger", message: "invalid reset type '#{n}' (-> str)")
end
