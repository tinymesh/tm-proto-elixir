defmodule Tinymesh.Config do

  import Tinymesh.Config.Packer

  defmodule Error do
    defexception type: nil, parameter: nil, addr: nil, message: ""
  end

  @serializedefaults %{
      :addr => false,
      :vsn => nil,
      :ignorero => false
    }
  @unserializedefaults %{addr: false, vsn: nil}

  @doc """
  Serialize a configuration into a Tinymesh Configuration blob.

  ## Options

    * `:addr` - Dictates if the output blob should have contain (addr, val)
                pairs.  Defaults to false, using the bytes potision
                in the blob as the address (0 based index).

    * `:vsn` - defines the fw revision used for the config

    * `:ignorero` - Allow modification of read only bytes

    * `:zerofill` - Initialize the buffer with nil values of size `n`
                    only used when `:addr` := false.
  """
  def serialize(config), do: serialize(config, %{})
  def serialize([_|_] = config, opts), do:
    serialize(
      Enum.reduce(config, %{}, fn({k, v}, acc) -> Map.put(acc, k, v) end),
      opts)
  def serialize(%{} = config, opts) do
    vsn = getvsn config, opts
    part = Map.get config, ["device", "part"], ""

    opts = Map.merge @serializedefaults, Map.put(opts, :vsn, vsn)
    opts = Map.put opts, :part, part

    try do
      acc = case {opts[:zerofill], opts[:addr]} do
        {_, true} -> []
        {nil,_}   -> []
        {size, false} ->
          List.duplicate nil, size
      end

      buf = Enum.reduce config, acc, fn({k, v}, acc) ->
        pack {k, v}, acc, opts
      end


      # acc returns a list with possible `nil` values if no data could
      # be filled in, convert this to zeros for backwards compatability
      buf = :erlang.iolist_to_binary(Enum.map(buf, fn
        (nil) -> 0
        (v) -> v
      end))

      {:ok, buf}
    rescue e in Tinymesh.Config.Packer.Error ->
      {:error, [e.parameter, e.message]}
    end
  end

  @doc """
  Unserialize a Tinymesh Configuration blob.

  ## Options

    * `:addr` - Mapates if the blob contains (addr, val) pairs.
                Defaults to false, using the bytes position in the blob
                as the address (0 based index)

    * `:vsn` - defines the revision used for the config
  """
  def unserialize(buf, opts \\ %{}) do
    opts = Map.merge @unserializedefaults, opts

    try do
      {res, _p} = chunk(buf, opts[:addr]) |> Enum.reduce({%{}, %{}}, fn(i, acc) ->
        unpack(i, acc, opts)
      end)

      vsn = getvsn res, opts

      {:ok, filtervsn(res, vsn)}
    rescue e in Tinymesh.Config.Packer.Error ->
      {:error, [e.addr, e.message]}
    end
  end

  def filtervsn(res, vsn) do
    # Merge into with empty map to return a map instead of proplist
    res
      |> Enum.filter(&Tinymesh.Config.Packer.vsnfilter(&1, vsn))
      |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.put(acc, k, v) end)
  end

  defp getvsn(config, opts) do
    case {opts[:vsn], Map.fetch(config, ["device", "fw_revision"])} do
      {vsn, {:ok, _v}} when nil !== vsn ->
        vsn

      {_vsn, {:ok, v}} ->
        v

      {vsn, _} ->
        vsn
    end
  end

  defp chunk(buf, addr?), do: chunk(buf, addr?, {0, []})
  defp chunk("", _addr?, {_, parts}), do: parts
  defp chunk(<<byte>> <> rest, false = addr?, {p, parts}), do:
    chunk(rest, addr?, {p + 1, [{p, byte} | parts]})
  defp chunk(<<0, 0>> <> _, true, {_p, parts}), do:
    parts
  defp chunk(<<addr, val>> <> rest, true = addr?, {p, parts}), do:
    chunk(rest, addr?, {p, [{addr, val} | parts]})
end
