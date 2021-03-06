defmodule Tinymesh.Config.Packer do
  defmodule Error do
    defexception parameter: nil, addr: nil, message: "", type: nil
  end

  Module.register_attribute __MODULE__, :config,
    accumulate: true,
    persist: true

  @protovsn "1.41"

  @config {"rf.channel",                  %{addr:  0, range: 1..83}}
  @config {"rf.power",                    %{addr:  1, range: 1..5}}
  @config {"rf.data_rate",                %{addr:  2, range: 1..6}}
  @config {"net.rssi_threshold",          %{addr:  4, range: 160..210}}
  @config {"net.rssi_cc_assesment",       %{addr:  5, range: 100..210}}
  @config {"net.hiam_time",               %{addr:  6, range: 1..10}}
  @config {"ima.time",                    %{addr:  7, range: 1..255}}
  @config {"ima.time_base",               %{addr: 85,  range: 1..255}}
  @config {"ima.on_connect",              %{addr: 94,  enum: [0,1]}}
  @config {"ima.data_field",              %{addr: 106, enum: [0,1,2], since: "1.40"}}
  @config {"ima.address_field",           %{addr: 107, enum: [0,1,2,3], since: "1.40"}}
  @config {"ima.trig_hold",               %{addr: 108, range: 0..255,   since: "1.40"}}

  @config {"net.connect_check_time",      %{addr:  8, range: 4..20}}
  @config {"net.max_jump_level",          %{addr:  9, range: 1..255}}
  @config {"net.max_jump_count",          %{addr: 10, range: 1..255}}
  @config {"net.max_packet_latency",      %{addr: 11, range: 1..255}}
  @config {"net.max_packet_latency_base", %{addr: 84, enum: [0, 1]}}

  @config {"net.tx_retry_limit",          %{addr: 12, range: 1..255}}

  @config {"uart.timeout",                %{addr: 13, range: 1..255}}

  @config {"device.protocol_mode",        %{addr:  3, enum: [0, 1]}}
  @config {"device.type",                 %{addr: 14, enum: [1,2],   before: "1.40"}}
  @config {"device.type",                 %{addr: 14, enum: [1,2,3], multi: true, since:  "1.40"}}
  @config {"device.locator",              %{addr: 44, enum: [0,1]}}
  @config {"device.uid",                  %{addr: 45, size: 4, range: 0..4294967295}}
  @config {"device.sid",                  %{addr: 49, size: 4, range: 0..4294967295}}

  @config {"net.excellent_rssi",          %{addr: 15, range: 0..255, since: "1.37"}}

  @config {"gpio_0.config",               %{addr: 16, enum:  [0,1,2,4]}}
  @config {"gpio_0.trigger",              %{addr: 24, enum:  [0,1,2,3]}}
  @config {"gpio_0.analogue_high_trig",   %{addr: 33, range: 0..2047, size: 2}}
  @config {"gpio_0.analogue_low_trig",    %{addr: 35, range: 0..2047, size: 2}}
  @config {"gpio_0.analogue_sample_rate", %{addr: 37, range: 0..255}}
  @config {"gpio_1.config",               %{addr: 17, enum:  [0,1,2,4]}}
  @config {"gpio_1.trigger",              %{addr: 25, enum:  [0,1,2,3]}}
  @config {"gpio_1.analogue_high_trig",   %{addr: 38, range: 0..2047, size: 2}}
  @config {"gpio_1.analogue_low_trig",    %{addr: 40, range: 0..2047, size: 2}}
  @config {"gpio_1.analogue_sample_rate", %{addr: 42, range: 0..255}}
  @config {"gpio_2.config",               %{addr: 18, enum:  [0,1,4]}}
  @config {"gpio_2.trigger",              %{addr: 26, enum:  [0,1,2,3]}}
  @config {"gpio_3.config",               %{addr: 19, enum:  [0,1,4]}}
  @config {"gpio_3.trigger",              %{addr: 27, enum:  [0,1,2,3]}}
  @config {"gpio_4.config",               %{addr: 20, enum:  [0,1,4]}}
  @config {"gpio_4.trigger",              %{addr: 28, enum:  [0,1,2,3]}}
  @config {"gpio_5.config",               %{addr: 21, enum:  [0,1,4]}}
  @config {"gpio_5.trigger",              %{addr: 29, enum:  [0,1,2,3]}}
  @config {"gpio_6.config",               %{addr: 22, enum:  [0,1,4]}}
  @config {"gpio_6.trigger",              %{addr: 30, enum:  [0,1,2,3]}}
  @config {"gpio_7.config",               %{addr: 23, enum:  [0,1,3,4]}}
  @config {"gpio_7.trigger",              %{addr: 31, enum:  [0,1,2,3]}}
  @config {"gpio_7.pwm_default",          %{addr: 95, range: 0..100}}

  @config {"gpio.input_debounce",         %{addr: 32, range: 0..255}}
  @config {"uart.cts_hold_time",          %{addr: 43, range: 1..255}}

  @config {"uart.baud_rate",              %{addr: 53, enum: [1,2,3,4,5,6,7,8,9,10,11]}}
  @config {"uart.bits",                   %{addr: 54, enum: [8,9],   since: "1.21"}}
  @config {"uart.parity",                 %{addr: 55, enum: [0,1],   since: "1.21"}}
  @config {"uart.stop_bits",              %{addr: 56, enum: [1,2],   since: "1.21"}}
  @config {"uart.flow_control",           %{addr: 58, range: 1..59,  since: "1.31"}}
  @config {"uart.buffer_margin",          %{addr: 59, range: 0..100, since: "1.31"}}

  @config {"device.part",                 %{addr: 60, def?: false, size: 12, type: :binary, delimiter: [nil, ","],     ro: true}}
  @config {"device.hw_revision",          %{addr: 70, def?: false, size: 5,  type: :vsn,    delimiter: [",", ","],     ro: true}}
  @config {"device.fw_revision",          %{addr: 75, def?: false, size: 5,  type: :vsn,    delimiter: [",", <<255>>], ro: true}}

  @config {"security.level",              %{addr: 81, enum: [0,1,2], since: "1.31"}}

  # ima under ima.ste
  @config {"end_device.keepalive",        %{addr: 86,  range: 0..255,                since: "1.40"}}
  @config {"end_device.wakeon",           %{addr: 87,  range: 0..15,                 since: "1.40"}}
  @config {"end_device.wakeon_port",      %{addr: 109, enum:  [0,1,2,3,4,5,6,7,255], since: "1.40"}}

  @config {"device.indicators_timeout",   %{addr: 89, range: 0..255, since: "1.40"}}

  @config {"device.sniff_neighbours",     %{addr: 90, enum: [0, 1],  since: "1.40"}}
  @config {"device.command_ack",          %{addr: 91, enum: [0, 1], since: "1.20"}}

  @config {"device.sleep_or_rts_pin",     %{addr: 93, enum: [0, 1], since: "1.40"}}

  # pwm_default located in gpio_7.pwm_default

  @config {"pulse_counter.mode",          %{addr: 96, enum: [0,1,3], since: "1.40"}}
  @config {"pulse_counter.debounce",      %{addr: 97, range: 0..255, since: "1.40"}}

  @config {"net.connect_change_margin",   %{addr: 98, range: 0..255, since: "1.37"}}

  @config {"cluster.device_limit",        %{addr:  99, range: 5..100, since: "1.34"}}
  @config {"cluster.rssi_threshold",      %{addr: 100, range: 40..100, since: "1.34"}}

  @config {"device.detect_busy_network",  %{addr: 101, enum: [0,1,2], since: "1.20"}}

  @config {"rf_jamming.detect",           %{addr: 102, range: 0..100,               since: "1.34"}}
  @config {"rf_jamming.port",             %{addr: 103, enum: [0,1,2,3,4,5,6,7,255], since: "1.34"}}

  @config {"pulse_counter.feedback_port", %{addr: 104, enum: [0,1,2,3,4,5,6,7,255], since: "1.40"}}
  @config {"pulse_counter.feedback",      %{addr: 105, enum: [0,2],                 since: "1.40"}}

  # ima under ima.*
  # end device awake port under end_device.wakeon_port

  @config {"group.membership",            %{addr: 113, set: [], size: 8, since:  "1.40"}}
  @config {"net.command_accept_time",     %{addr: 121, range: 0..255}}
  @config {"net.command_retries",         %{addr: 122, range: 0..127}}

  @config {"rf.mac_rnd_mask_1",           %{addr: 124, enum: [116,63,31,15,7,3], since: "1.38"}}
  @config {"rf.mac_rnd_mask_2",           %{addr: 123, enum: [116,63,31,15,7,3], since: "1.38"}}

  # Save documentation on compile so it can be picked up by external tools
  @after_compile __MODULE__
  def __after_compile__(_env, _bytecode) do
    config = Module.get_attribute __MODULE__, :config

    doc = ["""
    ## Configuration Options
    {: data-path=proto.configuration }

    **Note:** This documentation was generated for version
    #{@protovsn}". If your version of the firmware is newer, look for
    the updated version of this documentation at the bottom of this page.

    ## Parameters
    """]

    since = fn
      (nil) -> ""
      (vsn) -> "(since: #{vsn})"
    end
    buf = doc ++ Enum.map(config, fn
      ({field, e = %{type: :vsn}})      -> "  * `#{field}` - string: <major.minor> #{since.(e[:since])}"
      ({field, e = %{type: :binary}})   -> "  * `#{field}` - string #{since.(e[:since])}"
      ({field, e = %{enum: vals}})      -> "  * `#{field}` - enum: #{Enum.join(vals, ", ")} #{since.(e[:since])}"
      ({field, e = %{set: _, size: n}}) -> "  * `#{field}` - set (max size: #{n} #{since.(e[:since])}"
      ({field, e = %{range: range}})    -> "  * `#{field}` - integer: #{inspect range} #{since.(e[:since])}"
    end) |> Enum.join("\n")

    :ok = File.write "./doc/Configuration.md", buf
  end

  @doc """
  Unpacks a configuration blob into a map
  """
  for {strkey, props} <- @config do
    key = String.split strkey, "."
    {addr, size} = {props[:addr], props[:size]}

    endian = props[:endian] || :big
    compact = case props do
      %{range: _} ->
        quote(do: fn(vals) ->
          :binary.decode_unsigned(:erlang.iolist_to_binary(vals), unquote(endian))
        end)

      %{enum: _} ->
        quote(do: fn(vals) ->
          :binary.decode_unsigned(:erlang.iolist_to_binary(vals), unquote(endian))
        end)

      %{type: type} when type in [:vsn, :binary] ->
        quote(do: fn(vals) -> List.to_string(vals) end)

      %{set: _} ->
        quote(do: fn(vals) -> vals end)

      %{} ->
        quote(do: fn(vals) -> :binary.decode_unsigned(vals, unquote(endian)) end)
    end

    # if size := 1 then no magic required. otherwise collect data
    # into `partial` and add it to `res` once the entire field is
    # there
    def? = nil === props[:def?] || props[:def?]
    cond do
      1 === (size || 1) and def? ->
        def unpack({unquote(addr), val}, {res, partial}, _opts) do
          {Map.put(res, unquote(key), val), partial}
        end

      def? ->
        addresses = quote(do: unquote(addr)..unquote(addr+size-1))

        def unpack({paddr, val}, {res, partial}, _opts) when paddr in unquote(addresses) do
          {psize, elem} = partial[unquote(strkey)] || {1, List.duplicate(nil, unquote(size))}

          # check if compact able
          elem = List.replace_at elem, paddr - unquote(addr), val

          if unquote(size) == psize do
            {Map.put(res, unquote(key), unquote(compact).(elem)), Map.delete(partial, unquote(strkey))}
          else
            {res, Map.put(partial, unquote(strkey), {psize+1, elem})}
          end
        end

      true ->
        true
    end
  end
  # Part number and HW/FW revision
  def unpack({addr, val}, {res, partial}, _opts) when addr in 60..80 do
    {psize, elem} = partial["__part"] || {1, List.duplicate(nil, 21)}

    elem = List.replace_at elem, addr - 60, val
    cond do
      psize === 21 ->
        try do
          partend = Enum.find_index elem, fn(44) -> true; (_) -> false end

          {part, [44 | rest]} = Enum.split elem, partend
          hwend = Enum.find_index rest, fn(44) -> true; (_) -> false end
          {hw, [44 | rest]} = Enum.split rest, hwend
          fw = Enum.take_while rest, fn(255) -> false; (_) -> true end

          res = Map.merge res, %{
            ["device", "part"] => List.to_string(part),
            ["device", "fw_revision"] => List.to_string(fw),
            ["device", "hw_revision"] => List.to_string(hw)
          }

          {res, partial}
        rescue
          _e in ArithmeticError ->
            raise Error,
              type: :format,
              parameter: "device.*",
              message: "error parsing device.{part,fw_revision,hw_revision}"
        end

      true ->
        {res, Map.put(partial, "__part", {psize + 1, elem})}
    end
  end
  def unpack({_addr, _val},  acc, _opts) do
    acc
  end



  defpack = fn
    (key, props, x) when x in [nil, true] ->
        encparams = {props[:endian] || :big, props[:size] || 1}
        def pack({unquote(key), val}, acc, opts) do
          maybe_add_addr(val, unquote(props[:addr]), acc, unquote(encparams), opts)
        end

    (key, props, guards) ->
        encparams = {props[:endian] || :big, props[:size] || 1}
        def pack({unquote(key), val}, acc, %{vsn: vsn} = opts) when unquote(guards) do
          maybe_add_addr(val, unquote(props[:addr]), acc, unquote(encparams), opts)
        end
    end

  @doc """
  Packs individual fields
  """
  for {strkey, props} <- @config do
    # pack the following types implicitly: range, set, enum
    # and check `:type` for `:vsn`, `binary`
    key = String.split strkey, "."

    guards = case {props[:since], props[:before]} do
      {nil, nil} ->
        true

      {since, nil} ->
        quote(do: var!(vsn) in [:ignore, nil] or var!(vsn) >= unquote(since))

      {nil, before} ->
        quote(do: var!(vsn) in [:ignore, nil] or var!(vsn) <= unquote(before))

      {since, before} ->
        quote(do: var!(vsn) in [:ignore, nil] or var!(vsn) >= unquote(since) and var!(vsn) <= unquote(before))
    end

    def? = nil === props[:def?] || props[:def?]
    if def? do
      if props[:ro] do
        def pack({unquote(key), _val}, _acc, %{ignorero: false}) do
          raise Error,
            type: :bounds,
            parameter: unquote(strkey),
            message: "changing read-only value"
        end
      end

      case props do
        %{range: range} ->
          {_,_,args} = Macro.escape range
          range = quote(do: unquote(args[:first])..unquote(args[:last]))

          def pack({unquote(key), val}, _acc, _opts) when not val in unquote(range) do
            raise Error,
              type: :bounds,
              parameter: unquote(strkey),
              message: "value out of range #{inspect unquote(range)}"
          end
          defpack.(key, props, guards)

        %{enum: enum} ->
          def pack({unquote(key), val}, _acc, _opts) when not val in unquote(enum) do
            raise Error,
              type: :bounds,
              parameter: unquote(strkey),
              message: "value must be one off #{inspect unquote(enum)}"
          end
          defpack.(key, props, guards)

        %{set: set} when set !== nil ->
          defpack.(key, props, guards)

        %{type: :vsn} ->
          size = props[:size] || 1
          def pack({unquote(key), <<_,".",_,_>> = val}, acc, opts) when unquote(guards), do:
            maybe_add_addr(val, unquote(props[:addr]), acc, {:big, unquote(size)}, opts)
          def pack({unquote(key), _}, _acc, _opts) when unquote(guards) do
            raise Error,
              type: :vsnformat,
              parameter: unquote(strkey),
              message: "expected format <x>.<y><z>"
          end

        %{type: :binary} ->
          def pack({unquote(key), val}, _acc, _opts) when not is_binary(val) do
            raise Error,
              type: :type,
              parameter: unquote(strkey),
              message: "value must a string"
          end
          def pack({unquote(key), val}, _acc, _opts) when byte_size(val) > unquote(props.size || 1) do
            raise Error,
              type: :bounds,
              parameter: unquote(strkey),
              message: "value of size #{byte_size(val)} is larger than limit of #{unquote(props.size || 1)}"
          end
          defpack.(key, props, guards)
      end

      {before, since, multi?} = {props[:before], props[:since], props[:multi] || false}

      if nil !== since and not multi? do
        def pack({unquote(key), _val}, _acc, %{vsn: vsn}) when not vsn in [:ignore, nil] and vsn < unquote(since) do
          raise(Error, parameter: unquote(strkey),
            message: "field `#{unquote(strkey)}` not applicable for " <>
                     "revision '#{vsn}' (introduced in #{unquote(since)})")
        end
      end

      if nil !== before and not multi? do
        def pack({unquote(key), _val}, _acc, %{vsn: vsn}) when vsn > unquote(before) do
          raise(Error, parameter: unquote(strkey),
            message: "field `#{unquote(strkey)}` not applicable for " <>
                     "revision '#{vsn}' (deprecated in #{unquote(before)})")
        end
      end
    end
  end
  def pack({["device", "part"], val}, _acc, _opts) when not is_binary(val) or not byte_size(val) in [9,12] do
    raise Error, parameter: "device.part",
                 message: "`device.part` must be a binary with a size of 9 or 12"
  end
  def pack({["device", "part"], val}, acc, %{ignorero: true} = opts) do
    val = val <> "," # append delimeter
    maybe_add_addr(val, 60, acc, {:big, byte_size(val)}, opts)
  end
  def pack({["device", "part"], _val}, _acc, %{ignorero: false} =  _opts) do
    raise Error,
      type: :bounds,
      parameter: "device.part",
      message: "changing read-only value"
  end
  def pack({["device", "hw_revision"], val}, acc, %{part: part, ignorero: true} = opts) do
    addr = 60 + byte_size(part) + 1
    val = val <> ","
    maybe_add_addr(val, addr, acc, {:big, byte_size(val)}, opts)
  end
  def pack({["device", "hw_revision"], _val}, _acc, %{ignorero: true} =  _opts) do
    raise(Error, parameter: "device.hw_revision",
                 message: "`device.hw_revision` was not given, cannot pack value")
  end
  def pack({["device", "hw_revision"], _val}, _acc, %{ignorero: false} =  _opts) do
    raise Error,
      type: :bounds,
      parameter: "device.hw_revision",
      message: "changing read-only value"
  end
  def pack({["device", "fw_revision"], val}, acc, %{part: part, ignorero: true} = opts) do
    addr = 60 + 1 + 5 + byte_size(part)
    val = val <> <<255,255>>
    maybe_add_addr(val, addr, acc, {:big, byte_size(val)}, opts)
  end
  def pack({["device", "fw_revision"], _val}, _acc, %{ignorero: true} =  _opts) do
    raise(Error, parameter: "device.fw_revision",
                 message: "`device.fw_revision` was not given, cannot pack value")
  end
  def pack({["device", "fw_revision"], _val}, _acc, %{ignorero: false} =  _opts) do
    raise Error,
      type: :bounds,
      parameter: "device.fw_revision",
      message: "changing read-only value"
  end
  def pack({key, _val},  _acc, _opts) do
    raise Error,
      parameter: key_to_string(key),
      message: "can't pack unknown field `#{key_to_string key}`"
  end



  @doc """
  Add unsafe pack for individual fields
  """
  def packunsafe({["device", "hw_revision"], val}, acc, %{part: part} = opts) do
    addr = 60 + byte_size(part) + 1
    val = val <> ","
    maybe_add_addr(val, addr, acc, {:big, byte_size(val)}, opts)
  end
  def packunsafe({["device", "fw_revision"], val}, acc, %{part: part} = opts) do
    addr = 60 + 1 + 5 + byte_size(part)
    val = val <> <<255,255>>
    maybe_add_addr(val, addr, acc, {:big, byte_size(val)}, opts)
  end
  def packunsafe({["device", "part"], val}, acc, opts) do
    val = val <> "," # append delimeter
    maybe_add_addr(val, 60, acc, {:big, byte_size(val)}, opts)
  end
  for {strkey, props} <- @config do
      key = String.split strkey, "."
      encparams = {props[:endian] || :big, props[:size] || 1}

      if "device.part" !== strkey do
        def packunsafe({unquote(key), val}, acc, opts) do
          maybe_add_addr(val, unquote(props[:addr]), acc, unquote(encparams), opts)
        end
      end
  end

  def packunsafe({key, _val},  _acc, _opts) do
    raise Error,
      parameter: key_to_string(key),
      message: "can't pack unknown field `#{key_to_string key}`"
  end



  @doc """
  Filter callback to remove inapplicable config parameters based on
  firmware revision
  """
  for {strkey, props} <- @config do
    key = String.split strkey, "."

    {_before, since, multi?} = {props[:before], props[:since], props[:multi] || false}

    if nil !== since and not multi? do
      def vsnfilter({unquote(key), _val}, vsn) when vsn < unquote(since), do:
        false
    end
  end
  def vsnfilter(_, _), do: true

  defp key_to_string k do Enum.join(k, ".") end

  defp maybe_add_addr(val, addr, acc, {endian, size}, opts) when is_integer(val) do
    val = String.rjust(:binary.encode_unsigned(val), size, 0)
    maybe_add_addr(val, addr, acc, {endian, size}, opts)
  end
  defp maybe_add_addr(val, addr, acc, {endian, size}, %{addr: false}) do
    val = case endian do
        :little -> String.reverse val
        _       -> val
    end

    # we assume that acc is a flat list
    acc = case length acc do
      size when size < addr ->
        List.flatten [acc | List.duplicate(nil, addr - size)]

      _ ->
        acc
    end

    Enum.reduce 0..(size-1), acc, fn
      (n, acc) when n+addr == length(acc) ->
        List.insert_at acc, addr+n, String.at(val, n)

      (n, acc) when n+addr < length(acc) ->
        List.replace_at acc, addr+n, String.at(val, n)
    end
  end
  defp maybe_add_addr(val, addr, acc, {endian, size}, %{addr: true}) do
    val = case endian do
        :little -> String.reverse val
        _       -> val
    end

    val = for n <- 0..(size-1), do: [addr + n, String.at(val, n)]
    List.flatten [val | acc]
  end
end
