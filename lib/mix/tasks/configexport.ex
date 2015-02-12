defmodule Lens do
  @moduledoc """
  Utility to dynamically put nested keys into maps

  ```
  import Lens.Atom
  a = %{}
  a.b.c.d <- "i'm a dddddd"
  IO.inspect a # => %{b: %{c: %{d: "i'm a dddddd}}}
  ```
  """
  defmacro __using__(options \\ []) do
    keyfun = case options[:stringkeys?] do
      true ->
        quote(do: &Atom.to_string/1)

      _ ->
        quote(do: fn(a) -> a end)
    end

    quote do
      defmacro left <- right do
        [var | path] = DBL.Util.Lens.compactpath(left, [], unquote(keyfun))
        setter = DBL.Util.Lens.gensetpath(var, path, right)

        quote(do: unquote(var) = unquote(setter))
      end
    end
  end

  @doc """
  Helper to calculate the path of the setter reference
  """
  def compactpath({{:., _, [Access, :get]}, _, [a, [_|_] = b]}, [], keyfun), do:
    compactpath(a, b, keyfun)
  def compactpath({{:., _, [Access, :get]}, _, [a, b]}, [], keyfun), do:
    compactpath(a, [b], keyfun)
  def compactpath({{:., _, [a,b]}, _, _}, [], keyfun), do:
    compactpath(a, [keyfun.(b)], keyfun)
  def compactpath({{:., _, [Access, :get]}, _, [a, b]}, acc, keyfun), do:
    compactpath(a, [b|acc], keyfun)
  def compactpath({{:., _, [a,b]}, _, _}, acc, keyfun), do:
    compactpath(a, [keyfun.(b) | acc], keyfun)
  def compactpath([b | rest], acc, keyfun), do:
    compactpath(rest, [b|acc], keyfun)
  def compactpath(b, acc, _keyfun) do
    [b|acc]
  end

  @doc """
  Helper to generate setter function AST
  """
  def gensetpath(var, [k], v), do:
    quote(do: Dict.put(unquote(var), unquote(k), unquote(v)))

  def gensetpath(var, [k|rest], v) do
    nest = gensetpath(quote(do: unquote(var)[unquote(k)] || %{}), rest, v)
    quote(do: Dict.put(unquote(var), unquote(k), unquote(nest)))
  end

  def setpath(var, [k], v), do: Dict.put(var, k, v)
  def setpath(var, [k|rest], v), do: Dict.put(var, k, setpath(var[k] || %{}, rest, v))
  def delpath(var, [k]), do: Dict.delete(var, k)
  def delpath(var, [k|rest]), do: Dict.put(var, k, delpath(var[k] || %{}, rest))
end

defmodule Mix.Tasks.Configexport do
  use Mix.Task

  @keys [:size, :enum, :set, :range, :since, :before, :ro]

  def run(_) do
    cfg = Enum.reduce Tinymesh.Config.Packer.module_info[:attributes], %{}, fn
      ({:config, [{k, v}]}, acc) ->
        v = Enum.reduce @keys, %{key: k}, fn(i, acc) ->
          case {v[i], i} do
            {nil, _}-> acc
            {val, :range}-> Dict.put acc, i, [val.first, val.last]

            {val, _}-> Dict.put acc, i, val
          end
        end
        Lens.setpath acc, String.split(k, "."), v

      (_, acc) ->
        acc
    end

    Poison.encode!(cfg) |> IO.write
  end
end
