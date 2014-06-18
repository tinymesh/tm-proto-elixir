defmodule ProtoTests do
  use ExUnit.Case

  require Tinymesh.Proto, as: Proto

  defp sid, do: 1
  defp uid, do: 16909060

  test "marshal command" do
    bufs = [
      {<<10, uid :: [size(32), little()], 123, 3,  5, 0, 0>>, "init_gw_config"},
      {<<10, uid :: [size(32), little()], 123, 3, 16, 0, 0>>, "get_nid"},
      {<<10, uid :: [size(32), little()], 123, 3, 17, 0, 0>>, "get_status"},
      {<<10, uid :: [size(32), little()], 123, 3, 18, 0, 0>>, "get_did_status"},
      {<<10, uid :: [size(32), little()], 123, 3, 19, 0, 0>>, "get_config"},
      {<<10, uid :: [size(32), little()], 123, 3, 20, 0, 0>>, "get_calibration"},
      {<<10, uid :: [size(32), little()], 123, 3, 21, 0, 0>>, "force_reset"},
      {<<10, uid :: [size(32), little()], 123, 3, 22, 0, 0>>, "get_path"},
    ]

    Enum.each bufs, fn({buf, msg}) ->
      {:ok, cmd} = Proto.unserialize buf
      res = Proto.serialize cmd
      assert {:ok, buf} == res, "failed to pack event/#{msg}: #{Kernel.inspect res}"
    end
  end

  test "marshal events" do
    bufs = [
      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 1, 0, 216, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "io_change"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 2, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "aio0_change"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 3, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "aio1_change"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 6, 99, 2, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "tamper"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 8, 0, 5, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "power_on"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 9, 61, 216, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "ima"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 10, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_taken"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 11, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_free"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 12, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_jammed"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 13, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_shared"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 14, 61, 216, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "zacima"},

      {<<20, sid :: [size(32), little()], uid :: [size(32),little()],
         90, 1, 1, 20, 17, 0, 0, 2, 16, 1, 0>>, "ack/gw"},

      {<<20, sid :: [size(32), little()], uid :: [size(32),little()],
         90, 1, 1, 20, 17, 0, 0, 2, 17, 1, 3>>, "nak/gw"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 16, 61, 0, 0, 0, 0, 0,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "ack/node"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 17, 61, 4, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "nak/node"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 18, 0, 0, 0, 0, 89, 255,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "nid"},

      {<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 19, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "next_receiver"},

      {<<37, sid :: [size(32), little()], uid :: [size(32),little()], 
         90, 1, 1, 20, 17, 0, 0, 2, 32, 1, 1, 0, 0, 0, 2, 2, 0, 0, 0,
         3, 3, 0, 0, 0, 4, 4, 0, 0, 0>>, "path"},
# Some things are reserved meaning I have not a single clue what's in
# there so it's not possible to reproduce and exact config dump from
# string therefor somethings are replaced with zero
      {<<138, sid :: [size(32), little()], uid :: [size(32),little()],
         0, 0, 0, 0, 1, 0, 0, 2, 33, 9, 5, 5, 0, 193, 110, 1, 255, 6, 20,
         30, 5, 25, 20,  1, 150, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
         0, 0, 0, 0, 10, 7, 255, 0, 0, 10, 7, 255, 0, 0, 10, 6, 0, 1,
         0, 0,  0, 2, 0, 0, 0, 5, 8, 0, 1, 0, 1, 18, 82, 67, 49, 49,
         56, 48, 45, 84, 77, 44, 50, 46, 48, 48, 0, 49, 46,  51, 56,
         0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
         0, 12, 10, 60, 0, 0, 3, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,
         0, 0, 0, 0>>, "config"},

      #{<<35, sid :: [size(32), little()], uid :: [size(32),little()], 
      #  90, 1, 1, 20, 17, 0, 0, 2, 34, 61, 216, 191, 196, 92, 170,
      #  161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "calibration"}
    ]

    Enum.each bufs, fn({buf, msg}) ->
      {:ok, cmd} = Proto.unserialize buf
      res = Proto.serialize cmd

      assert {:ok, buf} == res, """
failed to pack event/#{msg}:
              buf:  {:ok, #{Kernel.inspect buf}}
              proc: #{Kernel.inspect res}
      """
    end
  end
end
