defmodule Runner do
  import ExProf.Macro

  def analyze(lines) do
    profile do
      Enum.reduce lines, 0, fn(msg, acc) ->
        try do
          {:ok, r} = Tinymesh.Proto.unserialize msg
        catch
          _, _ -> nil
        end
        acc + 1
      end
    end
  end
end

dir = "test/conn_data"
lines = for file <- File.ls! dir do
  for line <- File.read!(:filename.join(dir, file)) |> String.split("\n") do
    :base64.decode line
  end
end
lines = List.flatten lines
{m1, s1, ms1} = :erlang.now
start = (m1 * 10000000 + s1) * 100000 + ms1
Runner.analyze lines
{m2, s2, ms2} = :erlang.now
stop = (m2 * 10000000 + s2) * 100000 + ms2


t = stop - start
x = t/length(lines)
IO.puts "processed #{length lines} items in #{t}uS (#{x} pr item)"

