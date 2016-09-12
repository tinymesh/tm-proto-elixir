defmodule ConfigTest do
  use ExUnit.Case

  test "serialize" do
    opts = %{:addr => true, :vsn => nil}
    assert {:error, ["device.uid", _]}        = Tinymesh.Config.serialize [{["device", "uid"], -1}], opts
    assert {:ok, <<0,1>>}                     = Tinymesh.Config.serialize [{["rf", "channel"], 1}], opts
    assert {:ok, <<1,5>>}                     = Tinymesh.Config.serialize [{["rf", "power"], 5}], opts
    assert {:error, ["rf.power", _]}          = Tinymesh.Config.serialize [{["rf", "power"], 6}], opts
    assert {:ok, <<3,1>>}                     = Tinymesh.Config.serialize [{["device", "protocol_mode"], 1}], opts
    assert {:error, ["device.protocol_mode", _]}= Tinymesh.Config.serialize [{["device", "protocol_mode"], 2}], opts
    assert {:ok, <<107,3>>}                   = Tinymesh.Config.serialize [{["ima", "address_field"], 3}], %{opts | :vsn => "1.40"}
    assert {:error, ["ima.address_field", _]} = Tinymesh.Config.serialize [{["ima", "address_field"], 3}], %{opts | :vsn => "1.27"}
    assert {:ok, <<108,200>>}                 = Tinymesh.Config.serialize [{["ima", "trig_hold"], 200}], %{opts | :vsn => "1.40"}
    assert {:ok, <<14,3>>}                    = Tinymesh.Config.serialize [{["device", "type"], 3}], %{opts | :vsn => "1.40"}
    assert {:error, ["device.type", _]}       = Tinymesh.Config.serialize [{["device", "type"], 3}], %{opts | :vsn => "1.27"}
    assert {:ok, <<14,2>>}                    = Tinymesh.Config.serialize [{["device", "type"], 2}], %{opts | :vsn => "1.27"}
    assert {:error, ["gpio_0.analogue_high_trig", _]} = Tinymesh.Config.serialize [{["gpio_0", "analogue_high_trig"], -1}], opts
    assert {:error, ["gpio_0.analogue_high_trig", _]} = Tinymesh.Config.serialize [{["gpio_0", "analogue_high_trig"], 2048}], opts
    assert {:ok, <<33,4,34,1>>}               = Tinymesh.Config.serialize [{["gpio_0", "analogue_high_trig"], 1025}], opts
    assert {:error, ["device.uid", _]}        = Tinymesh.Config.serialize [{["device", "uid"], -1}], opts
    assert {:error, ["device.uid", _]}        = Tinymesh.Config.serialize [{["device", "uid"], 4294967296}], opts
    assert {:ok, <<45,0,46,1,47,4,48,5>>}     = Tinymesh.Config.serialize [{["device", "uid"], 66565}], opts


    # device part and fw/hw revisions are dependant on eachother
    # special care must be given. These parameters will never be
    # changeable through `command/set_config` but we need to be able to
    # convert back and forth between `event/config`'s binary and map
    # representations.
    assert {:error, ["device.part", _]}       = Tinymesh.Config.serialize [{["device", "part"], "RC1140-TM"}], opts
    val = String.duplicate(<<0>>, 60) <> "RC1140-TM,"
    assert {:ok, val}       == Tinymesh.Config.serialize [{["device", "part"], "RC1140-TM"}], %{ignorero: true}

    assert {:error, ["device.fw_version", _]} = Tinymesh.Config.serialize [{["device", "fw_version"], "1.23"}], opts
    assert {:error, ["device.hw_version", _]} = Tinymesh.Config.serialize [{["device", "hw_version"], "1.23"}], opts
    val2 = "#{val}2.00,1.23" <> <<255, 255>>
    assert {:ok, val2} == Tinymesh.Config.serialize [
                                                    {["device", "fw_revision"], "1.23"},
                                                    {["device", "hw_revision"], "2.00"},
                                                    {["device", "part"], "RC1140-TM"}
                                                  ], %{ignorero: true}
#    assert {:ok, <<>>}                        = Tinymesh.Config.serialize [{["device", "force_backup"], 85}], opts
    assert {:error, ["non-existing-key", _]}  = Tinymesh.Config.serialize [{["non-existing-key"], 123}], opts
  end

  test "unserialize blob" do
    bincfg = <<9,5,5,0,190,193,2,255,6,20,30,5,10,20,1,0,1,1,1,1,1,1,1,1,
               0,0,0,0,3,0,0,0,10,7,255,0,0,10,7,255,0,0,10,5,0,2,1,0,0,
               1,0,0,0,5,8,0,1,0,49,4,82,67,49,49,55,48,45,84,77,44,50,
               46,48,48,44,49,46,51,53,255,255,0,0,0,0,255,5,0,0,0,0,1,0,
               0,0,0,1,0,0,10,60,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>

    {:ok, cfg} = Tinymesh.Config.unserialize bincfg

    assert 3            == Dict.get cfg, ["rf_jamming", "port"]
    assert "1.35"       == Dict.get cfg, ["device", "fw_revision"]
    assert "RC1170-TM"  == Dict.get cfg, ["device", "part"]
    assert 16777216     == Dict.get cfg, ["device", "sid"]
    assert 33619968     == Dict.get cfg, ["device", "uid"]
    assert 0            == Dict.get cfg, ["gpio_1", "analogue_low_trig"]
    assert 2047         == Dict.get cfg, ["gpio_1", "analogue_high_trig"]

  end

  test "multi test" do
    buf_43 = <<138,1,0,0,0,1,0,0,0,61,1,1,0,9,0,38,2,33,4,5,5,1,193,
               180,1,255,6,20,30,50,25,20,3,150,1,1,1,1,1,1,1,1,0,0,0,
               0,0,0,0,0,10,7,255,0,0,100,7,255,0,0,100,6,0,1,0,0,0,1,
               0,0,0,5,8,0,1,0,1,18,82,67,49,49,55,48,45,84,77,44,50,
               46,48,48,44,49,46,52,51,255,255,0,0,0,1,6,10,8,0,255,0,
               1,0,0,0,0,0,0,12,10,60,0,0,255,255,0,0,2,0,255,0,0,0,0,
               0,0,0,0,0,0>>
    {:ok, ev_43} = Tinymesh.Proto.unserialize buf_43
    cfg_43 = Tinymesh.Proto.config_to_proplist ev_43["config"]

    buf_39 = <<138,1,0,0,0,1,0,0,0,61,1,1,0,9,0,38,2,33,4,5,5,1,193,
               180,1,255,6,20,30,50,25,20,3,150,1,1,1,1,1,1,1,1,0,0,0,
               0,0,0,0,0,10,7,255,0,0,100,7,255,0,0,100,6,0,1,0,0,0,1,
               0,0,0,5,8,0,1,0,1,18,82,67,49,49,55,48,45,84,77,44,50,
               46,48,48,44,49,46,51,57,255,255,0,0,0,1,6,10,8,0,255,0,
               1,0,0,0,0,0,0,12,10,60,0,0,255,255,0,0,2,0,255,0,0,0,0,
               0,0,0,0,0,0>>
    {:ok, ev_39} = Tinymesh.Proto.unserialize buf_39
    cfg_39 = Tinymesh.Proto.config_to_proplist ev_39["config"]


    assert {:ok, _} = Tinymesh.Config.serialize cfg_43, [ignorero: true]
    assert {:error, ["device.type", "value must be one off [1, 2]"]} = Tinymesh.Config.serialize cfg_39, [ignorero: true]
  end
end
