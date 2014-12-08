defmodule Tinymesh.Proto do

  use Bitwise

  defmodule PacketError do
    defexception [message: "default", field: "unknown", extra: []]
  end

  defmodule Error do
    defstruct type: nil,
              field: "",
              message: "",
              args: %{}
  end

  defmacro cmd(uid, type, packetnum) do
    quote do
      {:ok, %{
        "uid" => unquote(uid),
        "cmd_number" => unquote(packetnum),
        "type" => "command",
        "command" => unquote(type)
      }}
    end
  end
  defmacro cmd(uid, type, packetnum, extra) do
    quote do
      {:ok, Dict.merge(unquote(extra), %{
        "uid" => unquote(uid),
        "cmd_number" => unquote(packetnum),
        "type" => "command",
        "command" => unquote(type)
      })}
    end
  end

  defmacro ev(sid, uid, rssi, netlvl, hops, packetnum,
      latency, extra) do
    quote do
      {:ok, Dict.merge(unquote(extra), %{
        "sid" => unquote(sid),
        "uid" => unquote(uid),
        "rssi" => unquote(rssi),
        "network_lvl" => unquote(netlvl),
        "hops" => unquote(hops),
        "packet_number" => unquote(packetnum),
        "latency" => unquote(latency),
        "type" => "event"})}
    end
  end

  defmacrop p_init_gw_config(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3,  5, 0, 0>>)

  defmacrop p_get_nid(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 16, 0, 0>>)

  defmacrop p_get_status(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 17, 0, 0>>)

  defmacrop p_get_did_status(uid, packetnum),  do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 18, 0, 0>>)

  defmacrop p_get_config(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 19, 0, 0>>)

  defmacrop p_get_calibration(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 20, 0, 0>>)

  defmacrop p_force_reset(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 21, 0, 0>>)

  defmacrop p_get_path(uid, packetnum), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3, 22, 0, 0>>)

  defmacrop p_set_output(uid, packetnum, on, off), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3,  1, unquote(on), unquote(off)>>)

  defmacrop p_set_pwm(uid, packetnum, pwm), do:
    quote(do: <<10, unquote(uid) :: size(32)-little(), unquote(packetnum), 3,  2, unquote(pwm), 0>>)

  defmacrop p_set_config(uid, packetnum, cfg), do:
    quote(do: <<40, unquote(uid) :: size(32)-little(), unquote(packetnum), 3,  3, unquote(cfg) :: size(32)-binary()>>)

  defmacro p_serial_out(checksum, uid, packetnum, data), do:
    quote(do: <<unquote(checksum), unquote(uid) :: size(32)-little(), unquote(packetnum), 17, unquote(data) :: binary()>>)

  # Events
  defmacrop p_event(sid, uid, rssi, netlvl, hops, packetnum, latency) do
    quote do
      <<
      unquote(sid) :: size(32)-little(),
      unquote(uid) :: size(32)-little(),
      unquote(rssi) :: size(8),
      unquote(netlvl) :: size(8),
      unquote(hops) :: size(8),
      unquote(packetnum) :: size(16),
      unquote(latency) :: size(16)
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
        %Error{type: :packet_error,
               field: e.field,
               message: e.message,
               args: e.extra}
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

    {_, gpios} = Enum.reduce map, {7, %{}}, fn
      ({0, 0}, {n, acc}) -> {n - 1, acc}
      ({1, 0}, {n, acc}) -> {n - 1, Dict.put(acc, "gpio_#{n}", true)}
      ({_, 1}, {n, acc}) -> {n - 1, Dict.put(acc, "gpio_#{n}", false)}
    end

    cmd uid, "set_output", packetnum, %{"gpio" => gpios}
  end
  defp unserialize(p_set_pwm(uid, packetnum, pwm), _ctx) do
    cond do
      pwm > 0 and pwm < 100 ->
        cmd(uid, "set_pwm", packetnum, %{"pwm" => pwm})

      true ->
        %Error{type: :pwm_bounds,
               field: "pwm",
               message: "field `pwm` must be in range 0..100",
               args: %{packet: packetnum, uid: uid}}
    end
  end
  defp unserialize(p_serial_out(checksum, uid, packetnum, data), _ctx) do
    datasize = checksum - 7
    cond do
      byte_size(data) == datasize ->
        cmd(uid, "serial", packetnum, %{"data" => data})

      true ->
        %Error{type: :checksum,
               field: "data",
               message: "field `data` should have size #{datasize}, size was #{byte_size(data)}",
               args: %{packet: packetnum, uid: uid}}
    end
  end
  defp unserialize(p_set_config(uid, packetnum, cfg), _ctx) do
    case Tinymesh.Config.unserialize cfg, %{addr: true} do
      {:ok, config} ->
        cmd uid, "set_config", packetnum, %{"config" => config_to_hash(config)}

      {:error, _} = err ->
        err
    end
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

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "triggers" => triggers,
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/aio0_change event/aio1_change event/network_taken
  # event/network_free event/network_jammed event/network_shared
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
        when detail in [2, 3, 10, 11, 12, 13] do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/tamper
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 6 do

    duration = data >>> 8
    ended    = data &&& 255

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "duration" => duration,
      "ended" =>    ended,
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/reset
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 8 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "trigger" => reset_to_str(data &&& 255),
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 9 do
      #when detail === 9 and fw < <<1,64>> do # for pre 1.40 firmware

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "data" => data,
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 9 and fw < <<1,64>> do # for pre 1.40 firmware

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "trigger" => reset_to_str(data &&& 255),
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/zacima - ONLY for compatibility
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 14 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "msg_data" => data,
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "digital_io_0" => 1 &&& (dio >>> 0),
      "digital_io_1" => 1 &&& (dio >>> 1),
      "digital_io_2" => 1 &&& (dio >>> 2),
      "digital_io_3" => 1 &&& (dio >>> 3),
      "digital_io_4" => 1 &&& (dio >>> 4),
      "digital_io_5" => 1 &&& (dio >>> 5),
      "digital_io_6" => 1 &&& (dio >>> 6),
      "digital_io_7" => 1 &&& (dio >>> 7),
      "analog_io_0" => aio0,
      "analog_io_1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/ack - gw
  defp unserialize(<<20, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, 16, cmdnum, _>>, _ctx) do
    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(16),
      "cmd_number" => cmdnum
    }
  end

  defp unserialize(<<20, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, 17, cmdnum, reason>>, _ctx) do
    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(17),
      "cmd_number" => cmdnum,
      "reason" => nak_trigger_to_str(reason)
    }
  end

  # event/ack - node
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 16 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "cmd_number" => (data &&& 65280) >>> 8,
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/nak - node
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 17 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "cmd_number" => (data &&& 65280) >>> 8,
      "reason" => nak_trigger_to_str((data &&& 255)),
      "locator" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/nid - node
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 18 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "nid" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/next_receiver
  defp unserialize(p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
                   detail, data, address, temp, volt, dio, aio0, aio1, hw, fw), _ctx)
      when detail === 19 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "receiver" => address,
      "temp" => temp - 128,
      "volt" => ((volt * 0.03) * 100) * 0.01,
      "dio" => Enum.zip(
        ["gpio_0","gpio_1","gpio_2","gpio_3","gpio_4","gpio_5","gpio_6","gpio_7"],
        gpiomap(dio)) |> Enum.into(%{}),
      "aio0" => aio0,
      "aio1" => aio1,
      "hw" => encvsn(hw),
      "fw" => encvsn(fw)
    }
  end

  # event/path
  defp unserialize(<<chksum, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, detail,
                     rest :: binary()>>, _ctx)
      when detail === 32 and byte_size(rest) === chksum-18 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => detail_to_str(detail),
      "path" => unpack_path(rest)
    }
  end

  # event/config
  defp unserialize(<<chksum, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 2, detail,
                     rest :: binary()>>, _ctx)
      when detail === 33 and byte_size(rest) === chksum-18 do

    case Tinymesh.Config.unserialize rest do
      {:ok, config} ->
        ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
          "detail" => detail_to_str(detail),
          "config" => config_to_hash(config)
        }

      {:error, err} ->
        %Error{type: :config,
               field: "config",
               message: "failed to unserialize config",
               args: %{error: err}}
        err
    end
  end

  defp unserialize(<<chksum, p_event(sid, uid, rssi, netlvl, hops,
                     packetnum, latency), 16, block, buf :: binary()>>, _ctx)
      when byte_size(buf) === chksum - 18 do

    ev sid, uid, rssi, netlvl, hops, packetnum, latency, %{
      "detail" => "serial",
      "block" => block,
      "data" => buf
    }
  end

  # fallback and die
  defp unserialize(<<chksum, p_event(_, uid, _, _, _, packetnum, _), 2, rest :: binary>> = packet, _ctx) do
    <<detail>> = String.first rest

    cond do
      chksum !== byte_size(rest) + 17 ->
        %Error{type: :checksum,
               message: "packet should have size #{chksum}, size was #{byte_size(packet)}",
               args: %{packet: packetnum, type: :event, detail: detail, uid: uid}}

      #byte_size(rest) >= 3 -> # Only ACK/NAK have that short packet
      #  {:error, [:invalid_event, [{:packet, packetnum}, {:uid, uid}, {:detail, detail}]]}

      true ->
        %Error{type: :invalid_type,
               message: "invalid event detail '#{String.first rest}'",
               args: %{packet: packetnum, detail: detail, uid: uid}}
    end
  end
  defp unserialize(<<chksum, uid :: size(32)-little(), packetnum, 3, rest :: binary()>> = packet, _ctx) do
    cond do
      chksum !== byte_size(rest) + 6 ->
        %Error{type: :checksum,
               message: "packet should have size #{chksum}, size was #{byte_size(packet)}",
               args: %{packet: packetnum, type: :command, uid: uid}}

      "" == rest ->
        %Error{type: :no_type,
               message: "No type information in packet",
               args: %{packet: packetnum, type: :command, uid: uid}}

      true ->
        %Error{type: :invalid_type,
               message: "invalid command type '#{String.first rest}'",
               args: %{packet: packetnum, type: String.first(rest), uid: uid}}
    end
  end
  defp unserialize(_, _ctx) do
    %Error{type: :packet_error,
           message: "packet format could not be understood"}
  end

  def serialize(msg), do: serialize(msg, [])
  def serialize(msg, ctx), do:
    pack(msg["type"], msg["command"] || msg["detail"], msg, ctx)

  defp packitems(msg, keys, f), do: packitems(msg, keys, f, [])
  defp packitems(_msg, [], f, acc), do: apply(f, Enum.reverse(acc))
  defp packitems(msg, [k|rest], f, acc) do
    case Dict.get(msg, k) do
      nil ->
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

      val ->
        packitems(msg, rest, f, [val|acc])

    end
  end

  defp pack("command", "init_gw_config", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_init_gw_config(a,b)} end)
  defp pack("command", "get_nid", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_nid(a,b)} end)
  defp pack("command", "get_status", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_status(a,b)} end)
  defp pack("command", "get_did_status", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_did_status(a,b)} end)
  defp pack("command", "get_calibration", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_calibration(a,b)} end)
  defp pack("command", "get_config", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_config(a,b)} end)
  defp pack("command", "force_reset", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_force_reset(a,b)} end)
  defp pack("command", "get_path", msg, _ctx), do:
     packitems(msg, ["uid", "cmd_number"], fn(a,b) -> {:ok, p_get_path(a,b)} end)
  defp pack("command", "set_output", msg, _ctx), do:
    packitems(msg, ["uid", "cmd_number","gpio"], fn(a,b,gpios) ->
        on  = pack_dio gpios, true
        off = pack_dio gpios, false
        {:ok, p_set_output(a,b, on, off)}
    end)
  defp pack("command", "set_pwm", msg, _ctx), do:
    packitems(msg, ["uid", "cmd_number","pwm"], fn(a,b,pwm) ->
        {:ok, p_set_pwm(a,b, pwm)}
    end)
  defp pack("command", "set_config", msg, ctx) do
    opts = Dict.merge [addr: true], ctx[:configopts] || []
    packitems msg, ["uid", "cmd_number","config"], fn(a, b, config) ->
        case Tinymesh.Config.serialize config_to_proplist(config), opts do
          {:ok, buf} ->
            buf = String.slice (buf <> String.duplicate <<0>>, 32), 0, 32
            {:ok, p_set_config(a, b, buf)}

          {:error, err} ->
            %Error{type: :config,
                   field: "config",
                   message: "failed to serialize config",
                   args: %{error: err}}
        end
    end
  end
  defp pack("command", "serial", msg, _ctx), do:
    packitems(msg, ["uid", "cmd_number","data"], fn(a,b,data) ->
        {:ok, p_serial_out(7 + byte_size(data), a, b, data)}
    end)

  @gen "___gen___"
  @genev_keys ["sid", "uid", "rssi", "network_lvl", "hops", "packet_number",
               "latency", "detail", "data", "address", "temp", "volt", "dio",
               "aio0", "aio1", "hw", "fw"]

  defp pack("event", "io_change", msg, ctx) do
    case Enum.map ["triggers", "locator"], &Dict.get(msg, &1) do
      [nil, _] ->
        k = "triggers"
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

      [_, nil] ->
        k = "locator"
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

      [triggers, locator] ->
        changes = Enum.reduce(triggers, 0,
          fn(<<"gpio_", pin :: integer()>>, acc) ->
            :math.pow(2, pin - 48) + acc
          end) |> trunc

        msg = Dict.merge msg, [{"data", changes}, {"address", locator}]
        pack("event", @gen, msg, ctx)
    end
  end

  defp pack("event", detail, msg, ctx) when detail in [
      "aio0_change", "aio1_change", "network_taken", "network_free",
      "network_jammed", "network_shared"] do

    msg = Dict.merge %{"data" => 0, "address" => msg["locator"]}, msg
    pack("event", @gen, msg, ctx)
  end

  defp pack("event", "tamper", msg, ctx) do
    case Enum.map ["duration", "ended"], &Dict.get(msg, &1) do
      [nil, _] ->
        k = "duration"
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

      [_, nil] ->
        k = "ended"
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

      [duration, ended] ->
        data = (duration <<< 8) + ended
        msg = Dict.put Dict.put(msg, "address", msg["locator"]), "data", data
        pack("event", @gen, msg, ctx)
    end
  end

  defp pack("event", "reset", msg, ctx) do
    data = reset_to_int Dict.get(msg, "trigger")
    msg = Dict.put Dict.put(msg, "address", msg["locator"]), "data", data
    pack("event", @gen, msg, ctx)
  end

  defp pack("event", "ima", msg, ctx) do
    msg = Dict.put(msg, "address", msg["locator"])
    pack("event", @gen, msg, ctx)
  end

  defp pack("event", "zacima", msg, ctx) do
    gpios = Enum.filter msg, fn({"digital_io_" <> _, _}) -> true
                                                       _ -> false end

    msg = Dict.merge msg, [{"address", msg["locator"]},
                           {"data", msg["msg_data"]},
                           {"aio0", msg["analog_io_0"]},
                           {"aio1", msg["analog_io_1"]},
                           {"dio", gpios}]

    pack("event", @gen, msg, ctx)
  end

  defp pack("event", detail, msg, ctx) when detail in ["ack", "nak"] do
    if Dict.get(msg, "locator") do
      case Enum.map ["cmd_number", "reason", "locator"], &Dict.get(msg, &1) do
        [nil, _, _] ->
          k = "cmd_number"
          %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

        [_, _, nil] ->
          k = "locator"
          %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

        [_, nil, _] when detail == "nak" ->
          k = "reason"
          %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

        [cmdnum, nil, locator] when detail == "ack" ->
          data = :binary.decode_unsigned <<cmdnum, 0>>
          msg  = Dict.merge msg, [{"data", data}, {<<"address">>, locator}]
          pack("event", @gen, msg, ctx)

        [cmdnum, reason, locator] when detail == "nak" ->
          data = :binary.decode_unsigned <<cmdnum, nak_trigger_to_int(reason)>>
          msg = Dict.merge msg, [{"data", data}, {<<"address">>, locator}]
          pack("event", @gen, msg, ctx)
      end
    else
      keys = ["sid", "uid", "rssi", "network_lvl", "hops", "packet_number",
              "latency", "detail", "cmd_number"]
      reason = case msg["reason"] do
        nil -> 0
        r   -> nak_trigger_to_int(r)
      end
      packitems msg, keys, fn(sid, uid, rssi, network_lvl, hops,
                             packetnum, latency, detail, cmdnum) ->

        {:ok, <<20, p_event(sid, uid, rssi, network_lvl, hops,
                            packetnum, latency),
                2, detail_to_int(detail), cmdnum, reason>>}
      end
    end
  end

  defp pack("event", "nid", msg, ctx) do
    case Dict.fetch msg, k = "nid" do
      :error ->
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}

      {:ok, val} ->
        # Data field should always be 0 for event/nid
        msg = Dict.merge msg, [{"address", val}, {"data", 0}]
        pack("event", @gen, msg, ctx)
    end
  end

  defp pack("event", "next_receiver", msg, ctx) do
    case Dict.fetch msg, k = "receiver" do
      :error ->
        %Error{type: :missing_field,
               field: k,
               message: "Field `#{k}` missing, cannot serialize packet"}
      {:ok, val} ->
        msg = Dict.merge msg, [{"address", val}, {"data", 0}]
        pack("event", @gen, msg, ctx)
    end
  end

  defp pack("event", "path", msg, _ctx) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "path"],
      fn(sid, uid, rssi, network_lvl, hops, packetnum,
         latency, detail, path) ->

        path = pack_path path
        checksum = 18 + byte_size(path)
        {:ok, <<checksum, p_event(sid, uid, rssi, network_lvl, hops,
                                  packetnum, latency),
                2, detail_to_int(detail), path :: binary()>>}
      end
  end

  defp pack("event", "config", msg, _ctx) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "config"],
      fn(sid, uid, rssi, network_lvl, hops, packetnum,
         latency, detail, config) ->

        opts = %{ignorero: true, zerofill: 120}
        case Tinymesh.Config.serialize config_to_proplist(config), opts do
          {:ok, config} ->
            checksum = 18 + byte_size(config)
            {:ok, <<checksum, p_event(sid, uid, rssi, network_lvl, hops,
                                      packetnum, latency),
                    2, detail_to_int(detail), config :: binary()>>}

          {:error, err} ->
            %Error{type: :config,
                   field: "config",
                   message: "failed to serialize config",
                   args: %{error: err}}
        end
      end
  end

  defp pack("event", "calibration", msg, _ctx) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "calibration"],
      fn(sid, uid, rssi, network_lvl, hops, packetnum,
         latency, detail, config) ->

        %Error{type: :not_implemented,
               message: "`event/calibration` is not implemented",
               args: %{packet: packetnum, uid: uid}}
      end
  end

  defp pack("event", "serial", msg, _ctx) do
    packitems msg, ["sid", "uid", "rssi", "network_lvl", "hops",
                    "packet_number", "latency", "detail", "block", "data"],
      fn(sid, uid, rssi, network_lvl, hops, packetnum,
         latency, _detail, block, data) ->

        checksum = 18 + byte_size(data)
        {:ok, <<checksum, p_event(sid, uid, rssi, network_lvl, hops,
                                  packetnum, latency),
                16, block, data :: binary()>>}
      end
  end

  defp pack("event", @gen, msg, _ctx) do
    packitems msg, @genev_keys, fn(sid, uid, rssi, network_lvl, hops,
                                   packetnum, latency, detail, data,
                                   address, temp, volt, dio, aio0, aio1, hw, fw) ->

      # some special conversion is in order
      detail = detail_to_int detail
      dio = pack_dio dio
      {hw, fw} = {decvsn(hw), decvsn(fw)}
      volt = :erlang.trunc(volt / 0.03)
      temp = temp + 128

      {:ok, p_gen_ev(sid, uid, rssi, network_lvl, hops, packetnum,
                     latency, detail, data, address, temp, volt,
                     dio, aio0, aio1, hw, fw)}
    end
  end

#  defmacrop p_gen_ev(sid, uid, rssi, netlvl, hops, packetnum, latency,
#                 detail, data, address, temp, volt, dio, aio0, aio1, hw, fw) do

  defp pack(type, subtype, msg, _ctx) do
    packetnum = msg["packet_number"] || msg["cmd_number"]
    %Error{type: :invalid_type,
           message: "invalid command type #{type}/#{subtype}",
           args: %{packet: packetnum, type: "#{type}/#{subtype}", uid: msg["uid"]}}
  end

  defp pack_dio(dio), do: pack_dio(dio, 1)
  defp pack_dio(dio, match) do
    {_, res} = Enum.reduce dio, {match, 0}, fn
      ({"digital_io_" <> <<pin>>, match}, {match, acc}) ->
        {match, :math.pow(2, (pin-48)) + acc}

      ({"gpio_" <> <<pin>>, match}, {match, acc}) ->
        {match, :math.pow(2, (pin-48)) + acc}

      ({_,_}, acc) ->
        acc
    end

    trunc res
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

  defp unpack_path(path), do: unpack_path(path, 1, %{})
  defp unpack_path("", _, acc), do: acc
  defp unpack_path(<<rssi, uid :: little()-size(32), rest :: binary()>>, hop, acc) do
    unpack_path(rest, hop + 1, Dict.put(acc, "#{hop}", [rssi, uid]))
  end

  defp pack_path(paths), do: pack_path(Enum.sort(paths) |> Enum.reverse, "")
  defp pack_path([], acc), do: acc
  defp pack_path([{_, [rssi, uid]} | rest], acc) do
    pack_path(rest, <<rssi, uid :: little()-size(32), acc :: binary()>>)
  end

  def config_to_hash(config),  do:
    Enum.reduce(config, %{}, &reduce_config/2)
  def reduce_config({k, v}, acc), do: set_deep(acc, k, v)

  defp set_deep(dict, [k], v), do: Dict.put(dict, k, v)
  defp set_deep(dict, [k|rest], v) do
    Dict.put dict, k, set_deep(dict[k] || %{}, rest, v)
  end

  def config_to_proplist(dict, initpath \\ [], initacc \\ %{}) do
    {_, res} = Enum.reduce dict, {initpath, initacc}, fn
      ({k, %{} = v}, {path, acc}) ->
        {path, config_to_proplist(v, [k | path], acc)}

      ({k, v}, {path, acc}) ->
        {path, Dict.put(acc, Enum.reverse([k | path]), v)}
    end
    res
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

  defp nak_trigger_to_str( 0), do: "unknown"
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

  defp nak_trigger_to_str("unknown"),                do:  0
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
