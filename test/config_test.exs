defmodule ConfigTest do
  use ExUnit.Case

  setup_all do
    Mix.Task.run "cgen"
  end

  test "serialize" do
    assert {:ok, <<0,1>>}                     = Tinymesh.Config.serialize [{["rf", "channel"], 1}]
    assert {:ok, <<1,5>>}                     = Tinymesh.Config.serialize [{["rf", "power"], 5}]
    assert {:error, ["rf.power", _]}          = Tinymesh.Config.serialize [{["rf", "power"], 6}]
    assert {:ok, <<3,1>>}                     = Tinymesh.Config.serialize [{["device", "protocol_mode"], 1}]
    assert {:error, ["device.protocol_mode", _]}= Tinymesh.Config.serialize [{["device", "protocol_mode"], 2}]
    assert {:ok, <<107,3>>}                   = Tinymesh.Config.serialize [{["ima", "data_field"], 3}], "1.40"
    assert {:error, ["ima.data_field", _]}    = Tinymesh.Config.serialize [{["ima", "data_field"], 3}], "1.27"
    assert {:ok, <<108,200>>}                 = Tinymesh.Config.serialize [{["ima", "trig_hold"], 200}], "1.40"
    assert {:ok, <<14,3>>}                    = Tinymesh.Config.serialize [{["device", "type"], 3}], "1.40"
    assert {:error, ["device.type", _]}       = Tinymesh.Config.serialize [{["device", "type"], 3}], "1.27"
    assert {:ok, <<14,2>>}                    = Tinymesh.Config.serialize [{["device", "type"], 2}], "1.27"
    assert {:error, ["gpio_0.trig.hi", _]}    = Tinymesh.Config.serialize [{["gpio_0", "trig", "hi"], -1}]
    assert {:error, ["gpio_0.trig.hi", _]}    = Tinymesh.Config.serialize [{["gpio_0", "trig", "hi"], 2048}]
    assert {:ok, <<33,4,34,1>>}               = Tinymesh.Config.serialize [{["gpio_0", "trig", "hi"], 1025}]
    assert {:error, ["device.uid", _]}        = Tinymesh.Config.serialize [{["device", "uid"], -1}]
    assert {:error, ["device.uid", _]}        = Tinymesh.Config.serialize [{["device", "uid"], 4294967296}]
    assert {:ok, <<45,0,46,1,47,4,48,5>>}     = Tinymesh.Config.serialize [{["device", "uid"], 66565}]
    assert {:error, ["device.part", _]}       = Tinymesh.Config.serialize [{["device", "part"], "RC1140-TM."}]
    assert {:error, ["device.fw_version", _]} = Tinymesh.Config.serialize [{["device", "fw_version"], "1.23"}]
    assert {:ok, <<>>}                        = Tinymesh.Config.serialize [{["device", "force_backup"], 85}]
    assert {:error, ["non-existing-key", _]}  = Tinymesh.Config.serialize [{["non-existing-key"], 123}]
  end

  test "unserialize blob" do
    bincfg = <<9,5,5,0,190,193,2,255,6,20,30,5,10,20,1,0,1,1,1,1,1,1,1,1,
               0,0,0,0,3,0,0,0,10,7,255,0,0,10,7,255,0,0,10,5,0,2,1,0,0,
               1,0,0,0,5,8,0,1,0,49,4,82,67,49,49,55,48,45,84,77,44,50,
               46,48,48,44,49,46,51,53,255,255,0,0,0,0,255,5,0,0,0,0,1,0,
               0,0,0,1,0,0,10,60,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>

    {:ok, cfg} = Tinymesh.Config.unserialize bincfg

    assert {:ok, 3}            == Dict.fetch cfg, ["rf_jamming", "port"]
    assert {:ok, "1.35"}       == Dict.fetch cfg, ["device", "fw_version"]
    assert {:ok, "RC1170-TM,"} == Dict.fetch cfg, ["device", "part"]
    assert {:ok, 1}            == Dict.fetch cfg, ["device", "sid"]
    assert {:ok, 258}          == Dict.fetch cfg, ["device", "uid"]
    assert {:ok, 0}            == Dict.fetch cfg, ["gpio_1", "analogue_low_trig"]
    assert {:ok, 2047}         == Dict.fetch cfg, ["gpio_1", "analogue_high_trig"]

  end
end
