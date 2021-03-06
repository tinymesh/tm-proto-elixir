defmodule ProtoTests do
  use ExUnit.Case

  require Tinymesh.Proto, as: Proto

  defp sid, do: 1
  defp uid, do: 16909060

  test "marshal command" do
    bufs = [
      {<<10, uid() :: size(32), 123,  3,  1, 3, 12>>, "set_output"},
      {<<10, uid() :: size(32), 123,  3,  2,  0, 0>>, "set_pwm"},
      {<<10, uid() :: size(32), 123,  3,  2, 10, 0>>, "set_pwm"},
      {<<10, uid() :: size(32), 123,  3,  2,100, 0>>, "set_pwm"},
      {<<10, uid() :: size(32), 124,  3,  5,  0, 0>>, "init_gw_config"},
      {<<10, uid() :: size(32), 125,  3, 16,  0, 0>>, "get_nid"},
      {<<10, uid() :: size(32), 126,  3, 17,  0, 0>>, "get_status"},
      {<<10, uid() :: size(32), 127,  3, 18,  0, 0>>, "get_did_status"},
      {<<10, uid() :: size(32), 128,  3, 19,  0, 0>>, "get_config"},
      {<<10, uid() :: size(32), 129,  3, 20,  0, 0>>, "get_calibration"},
      {<<10, uid() :: size(32), 130,  3, 21,  0, 0>>, "force_reset"},
      {<<10, uid() :: size(32), 131,  3, 22,  0, 0>>, "get_path"},
      {<<10, uid() :: size(32), 132,  3, 22,  0, 0>>, "serial"},
      {<<12, uid() :: size(32), 133, 17, "hello">>, "serial"},
    ]

    Enum.each bufs, fn({buf, msg}) ->
      {:ok, cmd} = Proto.unserialize buf
      res = Proto.serialize cmd
      assert {:ok, buf} == res, """
failed to pack command/#{msg}:
              buf:  {:ok, #{Kernel.inspect buf}}
              proc: #{Kernel.inspect res}
      """
    end
  end

  test "marshal events" do
    bufs = [
      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 1, 0, 216, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "io_change"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 2, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "aio0_change"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 3, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "aio1_change"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 6, 99, 2, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "tamper"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 8, 0, 5, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "power_on"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 9, 61, 216, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "ima"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 10, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_taken"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 11, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_free"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 12, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_jammed"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 13, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "network_shared"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 14, 61, 216, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "zacima"},

      {<<20, sid() :: size(32), uid() :: size(32), 90, 1, 1, 20, 17, 0, 0, 2, 16, 0, 1>>, "ack/gw"},

      #{<<20, sid() :: size(32), uid() :: size(32), 0,0,0,0,1,0,0,2,16,15,0>>, "ack/gw2"},

      {<<20, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 17, 3, 1>>, "nak/gw"},

      {<<31, sid() :: size(32), uid() :: size(32),
        89, 1, 1, 20, 17, 0, 0, 16, 0, "i am a monkey">>, "ev/serial"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 16, 0, 61, 0, 0, 0, 0,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "ack/node"},

      {<<35, sid() :: size(32), uid() :: size(32), 110, 1, 1, 0, 23, 0, 16, 2, 16, 0, 254, 0, 0, 0,
         0, 160, 114, 255, 0, 0, 0, 0, 2, 0, 1, 69>>, "ack/node-2"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 17, 4, 61, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "nak/node"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 18, 0, 0, 0, 0, 89, 255,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "nid"},

      {<<35, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 19, 0, 0, 191, 196, 92, 170,
         161, 111, 239, 14, 184, 15, 106, 2, 0, 1,34>>, "next_receiver"},

      {<<38, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 32, 1, 1, 0, 0, 0, 2, 2, 0, 0, 0,
         3, 3, 0, 0, 0, 4, 4, 0, 0, 0>>, "path"},

      {<<23,1,0,0,0,1,0,0,0,85,1,1,0,3,0,45,2,32,85,123,0,0,0>>, "path2"},

# Some things are reserved meaning I have not a single clue what's in
# there so it's not possible to reproduce and exact config dump from
# string therefor somethings are replaced with zero
      {<<138, sid() :: size(32), uid() :: size(32),
         0, 0, 0, 0, 1, 0, 0, 2, 33, 9, 5, 5, 0, 193, 110, 1, 255, 6, 20,
         30, 5, 25, 20,  1, 150, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
         0, 0, 0, 0, 10, 7, 255, 0, 0, 10, 7, 255, 0, 0, 10, 6, 0, 1,
         0, 0,  0, 2, 0, 0, 0, 5, 8, 0, 1, 0, 1, 18, 82, 67, 49, 49,
         56, 48, 45, 84, 77, 44, 50, 46, 48, 48, 44, 49, 46,  51, 56,
         255, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
         0, 12, 10, 60, 0, 0, 3, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0,
         0, 0, 0, 0>>, "config"},

      {<<138, sid() :: size(32), uid() :: size(32), 102, 1, 1, 0, 56, 0, 17, 2, 34, 128, 192, 0, 0, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
         255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 34, 2, 170, 85, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 100, 0, 8, 170, 85, 1, 2, 3, 4, 5, 6, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0>>, "calibration"}
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

  test "event/config" do
    buf = <<138,1,0,0,0,2,1,0,0,0,0,0,0,2,0,0,2,33,9,5,5,0,190,193,2,
            255,6,20,30,5,10,20,1,0,1,1,1,1,1,1,1,1,0,0,0,0,3,0,0,0,
            10,7,255,0,0,10,7,255,0,0,10,5,0,2,1,0,0,1,0,0,0,5,8,0,1,
            0,49,4,82,67,49,49,55,48,45,84,77,44,50,46,48,48,44,49,46,
            52,48,255,255,0,0,0,0,255,5,0,0,0,0,1,0,0,0,0,1,0,0,10,60,
            0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>


    # A one-to-one conversion is nearly impossible due to reserved,
    # undocumented, or version dependant parameter. The above config
    # is therefore "constructed" to work smoothly for that this
    # particular version of the protocol
    {:ok, ev} = Tinymesh.Proto.unserialize buf
    assert {:ok, buf} == Tinymesh.Proto.serialize ev
  end

  test "event/ack" do
    cmdnum = 119
    buf = <<35, 1, 0, 0, 0, 0, 0, 0, 3, 143, 1, 1, 0, 90, 0, 16, 2, 16, 0, cmdnum,
            0, 0, 0, 0, 154, 111, 255, 0, 0, 0, 0, 2, 0, 1, 71>>

    {:ok, %{"cmd_number" => ^cmdnum, "detail" => "ack"} = ev} = Tinymesh.Proto.unserialize buf
    {:ok, ^buf} = Tinymesh.Proto.serialize ev
  end

  test "command/set_config" do
    buf = <<40,2,1,0,0,2,3,3,0,1,14,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>
    {:ok, cmd} = Tinymesh.Proto.unserialize buf
    {:ok, buf2} = Tinymesh.Proto.serialize cmd

    assert buf == buf2

    # make a very long one
    cmd = %{
      "type" => "command",
      "command" => "set_config",
      "uid" => 1,
      "cmd_number" => 1,
      "config" => %{
        "gpio_0" => %{"config" => 1,
                      "trigger" => 1,
                      "analogue_high_trig" => 1,
                      "analogue_low_trig" => 1,
                      "analogue_sample_rate" => 1},
        "gpio_1" => %{"config" => 1,
                      "trigger" => 1,
                      "analogue_high_trig" => 1,
                      "analogue_low_trig" => 1,
                      "analogue_sample_rate" => 1},
        "gpio_2" => %{"config" => 1,
                      "trigger" => 1},
        "gpio_3" => %{"config" => 1,
                      "trigger" => 1},
        "gpio_4" => %{"config" => 1,
                      "trigger" => 1},
        "gpio_5" => %{"config" => 1,
                      "trigger" => 1},
        "gpio_6" => %{"config" => 1,
                      "trigger" => 1},
        "gpio_7" => %{"config" => 1,
                      "trigger" => 1,
                      "pwm_default" => 50}}}

    assert %Tinymesh.Proto.Error{type: :max_params} = Tinymesh.Proto.serialize cmd
  end

  test "command/serial" do
    buf = Enum.map(0..256, fn(_) -> 0 end) |> List.to_string
    %Tinymesh.Proto.Error{type: :data_length} = Tinymesh.Proto.serialize %{
      "type" => "command",
      "command" => "serial",
      "uid" => 0,
      "cmd_number" => 0,
      "data" => buf}
  end


  test "serialize command ctx" do
    assert %Tinymesh.Proto.Error{} = Tinymesh.Proto.serialize %{"uid" => 1,
      "type" => "command",
      "command" => "set_config",
      "cmd_number" => 1,
      "config" => %{"cluster" => %{"device_limit" => 9}}
      },
      configopts: [vsn: "1.00"]

    assert {:ok, <<40,0,0,0,1,1,3,3,99,9,0,_::binary>>} = Tinymesh.Proto.serialize %{"uid" => 1,
      "type" => "command",
      "command" => "set_config",
      "cmd_number" => 1,
      "config" => %{"cluster" => %{"device_limit" => 9}}
      },
      configopts: [ignorero: true, vsn: "1.42"]

    # ignore version requirement
    assert {:ok, <<40,0,0,0,1,1,3,3,99,9,0,_::binary>>} = Tinymesh.Proto.serialize %{"uid" => 1,
      "type" => "command",
      "command" => "set_config",
      "cmd_number" => 1,
      "config" => %{"cluster" => %{"device_limit" => 9}}
      },
      configopts: [vsn: :ignore]
  end

  test "event/path" do
      buf = <<38, sid() :: size(32), uid() :: size(32),
         90, 1, 1, 20, 17, 0, 0, 2, 32, 1, 1, 0, 0, 0, 2, 2, 0, 0, 0,
         3, 3, 0, 0, 0, 4, 4, 0, 0, 0>>

    {:ok, ev} = Tinymesh.Proto.unserialize buf
    assert %{} = ev["path"]
    {:ok, buf2} = Tinymesh.Proto.serialize ev

    assert buf == buf2
  end
end
