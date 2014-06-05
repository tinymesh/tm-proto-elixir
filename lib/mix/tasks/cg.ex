defmodule Mix.Tasks.Cgen do

  use Mix.Task

  @shortdoc "Generate and compiles configuration parser"

  @moduledoc """
  Generates and compiles configuration module
  """

  def run([]), do: run(["priv/config"])
  def run([src]), do: run([src, "Tinymesh.Config"])
  def run([src, mod]) do
      dest = Mix.Project.compile_path <> "/Elixir." <> mod <> ".beam"
      {cfgdef, []} = Code.eval_string File.read! src

      Code.unload_files [dest]
      quotedcfg = generate cfgdef, binary_to_atom("Elixir." <> mod)

      [{_, bytes}] = Code.compile_quoted quotedcfg
      File.write! dest, bytes

      IO.puts "Generated (#{mod} -> Elixir.#{mod}.beam) from #{src}"
  end
  def run(_), do: IO.puts(:stderr, "usage: mix cgen <src-file> <dst-file>")

  defp generate(config, mod) do
    {unpack, pack} = Enum.reduce config, {[], []}, fn({k, v}, {unpack, pack}) ->
      ks =  String.split atom_to_binary(k), "."
      {[defunpack(ks, v)|unpack],[defpack(ks, v)|pack]}
    end

    quote do
      defmodule unquote(mod) do

        def serialize(config) do
          vsn = case Dict.fetch(config, ["device", "fw_version"]) do
            {:ok, v} -> v
            :error -> nil
          end
          serialize(config, vsn)
        end
        def serialize(config, vsn),  do: serialize(config,  vsn, true)
        def serialize(config, vsn, ignorero),  do: serialize(config, vsn, ignorero, [])
        def serialize([], _vsn, _ignorero, acc) do
          {:ok, iolist_to_binary(Enum.sort(acc))}
        end
        def serialize([{k,v}|rest], vsn, ignorero, acc) do
          case pack(k, v, vsn, ignorero) do
            {:ok, buf} ->
              serialize rest, vsn, ignorero, [buf | acc]

            {:error, _} = err ->
              err
          end
        end

        def unserialize(buf),      do: unserialize(buf, String.slice(buf, 75, 4))
        def unserialize(buf, vsn), do: unpack(0, buf, vsn, [])

        def pack(config, val, vsn), do: pack(config, val, vsn, false)
        unquote_splicing(pack)
        def pack(key, val, vsn, _ignorero), do:
          {:error, [Enum.join(key, "."),
                    "no such parameter or maybe not applicable for version #{vsn || "unknown"}"]}

        def unpack(buf, vsn), do: unpack(0, buf, vsn, [])
        def unpack(_, "", _, acc), do: {:ok, acc}
        unquote_splicing(unpack)
        def unpack(p, <<_ :: [size(1), unit(8)], rest :: binary()>>, fw, acc), do:
          unpack(p+1, rest, fw, acc)

        defp ataddr(addr, val, size), do: ataddr(addr, val, size, :big)
        defp ataddr(addr, val, size, nil), do: ataddr(addr, val, size, :big)
        defp ataddr(addr, val, size, endian) do
          val = case val do
            v when is_binary(v)  -> v
            v when is_integer(v) and endian === :big ->
              <<v :: [size(size), unit(8), integer()]>>

            v when is_integer(v) and endian === :little ->
              <<v :: [little(), size(size), unit(8), integer()]>>
          end

          vals = :erlang.binary_to_list val

          match = addr + size
          {^match, buf} = Enum.reduce vals, {addr, ""}, fn(v, {p, acc}) ->
            {p+1, acc <> <<p, v>>}
          end

          buf
        end
      end
    end
  end

  defp defunpack(key, t) do
    cond do
      t[:type] == :binary or t[:type] == :vsn ->
        quote do
          def unpack(unquote(t[:addr]),
                     <<val :: [size(unquote(t[:size] || 1)), unit(8), unquote(t[:endian] || :big)(), binary()], rest :: binary>>,
                     fw,
                     acc) when fw >= unquote(t[:since]) do
            unpack(unquote(t[:addr] + (t[:size] || 1)), rest, fw, [{unquote(key), val} | acc])
          end
        end

      true ->
        quote do
          def unpack(unquote(t[:addr]),
                     <<val :: [size(unquote(t[:size] || 1)), unit(8), unquote(t[:endian] || :big)()], rest :: binary>>,
                     fw,
                     acc) when fw >= unquote(t[:since]) do
            unpack(unquote(t[:addr] + (t[:size] || 1)), rest, fw, [{unquote(key), val} | acc])
          end
        end
    end
  end

  defp defpack(key, t) do
    vsnpredA = t[:since]
    vsnpredB = t[:before]
    static  = t[:static]
    type    = t[:type]
    addr    = t[:addr]
    size    = t[:size] || 1

    cond do
      nil !== (t[:enum] || t[:range]) ->
        {match, err} = case {t[:enum], t[:range]} do
          {enums, nil} ->
            {enums, "value should be one of #{Enum.join(enums, ", ")}"}
          {nil, range} ->
            {range, "value must be in range #{Macro.to_string(range)}"}
        end

        case {vsnpredA, vsnpredB} do
          {nil, nil} ->
            quote do
              def pack(unquote(key), _, _fw, false), do:
                {:error, [unquote(Enum.join(key, ".")), "read-only variable"]}

              def pack(unquote(key), val, _vsn, _ignorero) when val in unquote(match), do:
               {:ok, ataddr(unquote(addr), val, unquote(size), unquote(t[:endian]))}

              def pack(unquote(key), val, _vsn, _ignorero), do:
                {:error, [unquote(Enum.join(key, ".")), unquote(err)]}
            end

          {vsnpred, nil} ->
            quote do
              def pack(unquote(key), _, _fw, false), do:
                {:error, [unquote(Enum.join(key, ".")), "read-only variable"]}

              def pack(unquote(key), val, fw, _ignorero) when
                  fw >= unquote(vsnpred) and val in unquote(match), do:

                {:ok, ataddr(unquote(addr), val, unquote(size), unquote(t[:endian]))}

              def pack(unquote(key), val, fw, _ignorero)
                  when fw >= unquote(vsnpred) and not val in unquote(match), do:

                {:error, [unquote(Enum.join(key, ".")), unquote(err)]}
            end

          {nil, vsnpred} ->
            quote do
              def pack(unquote(key), _, _fw, false), do:
                {:error, [unquote(Enum.join(key, ".")), "read-only variable"]}

              def pack(unquote(key), val, fw, _ignorero) when
                  fw < unquote(vsnpred) and val in unquote(match), do:

                {:ok, ataddr(unquote(addr), val, unquote(size), unquote(t[:endian]))}

              def pack(unquote(key), val, fw, _ignorero) when
                  fw < unquote(vsnpred) and not val in unquote(match), do:

                {:error, [unquote(Enum.join(key, ".")), unquote(err)]}
            end
        end

      nil !== static ->
        quote do
          def pack(unquote(key), _, _fw, false), do:
            {:error, [unquote(Enum.join(key, ".")), "read-only variable"]}

          def pack(unquote(key), val, _fw, _ignorero) when val === unquote(static), do:
            {:ok, ""} # don't return anything, just static
          def pack(unquote(key), val, _fw, _ignorero) do
            {:error, [unquote(Enum.join(key, ".")),
                      "value must equal #{unquote(static)}"]}
          end
        end

      :binary === type ->
        quote do
          def pack(unquote(key), _, _fw, false), do:
            {:error, [unquote(Enum.join(key, ".")), "read-only variable"]}

          def pack(unquote(key), val, _fw, _ignorero) when is_binary(val), do:
            {:ok, ataddr(unquote(addr), val, unquote(size), unquote(t[:endian]))}

          def pack(unquote(key), _val, _fw, _ignorero), do:
            {:error, [unquote(Enum.join(key, ".")), "value must be binary"]}
        end

      :vsn === type ->
        quote do
          def pack(unquote(key), _, _fw, false), do:
            {:error, [unquote(Enum.join(key, ".")), "read-only variable"]}

          def pack(unquote(key), <<_, ".", _, _>> = val, _fw, _ignorero), do:
            {:ok, ataddr(unquote(addr), val, unquote(size), unquote(t[:endian]))}
          def pack(unquote(key), _val, _fw, _ignorero), do:
            {:error, [unquote(Enum.join(key, ".")), "value must be in format `x.yz`"]}
        end

      true ->
        quote(do: def pack(unquote(key), val, _fw, _ignorero) do
            {:ok, ataddr(unquote(addr), val, unquote(size), unquote(t[:endian]))}
        end)
    end
  end
end
