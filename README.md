# Tinymesh Elixir Parser

Elixir bindings for parsing the Tinymesh protocol.

## Features
	- Provides marshalling through `Tinymesh.Proto.unserialize/1` and `Tinymesh.Proto.serialize/1`.
	- Read Tinymesh configuration blobs with `Tinymesh.Config.unserialize`
	- Write instructions for setting `(addr,val)` pairs with `Tinymesh.Config.serialize

## Example

```elixir
iex(2)> {:ok, msg} = Tinymesh.Proto.unserialize buf
# => {:ok, [{"sid", 1}, {"uid", 2}, {"rssi", 90}, {"network_lvl", 1}, {"hops", 1},
#           {"packet_num", 5137}, {"latency", 0}, {"type", "event"}, {"detail", "tamper"},
#           {"duration", 99}, {"ended", 2}, {"locator", 3217317034}, {"temp", 33},
#           {"volt", 3.33},
#           {"dio",
#            [{"gpio_0", 1}, {"gpio_1", 1}, {"gpio_2", 1}, {"gpio_3", 1}, {"gpio_4", 0},
#             {"gpio_5", 1}, {"gpio_6", 1}, {"gpio_7", 1}]}, {"aio0", 3768},
#           {"aio1", 3946}, {"hw", "2.00"}, {"fw", "1.22"}]}
iex(3)> {:ok, ^buf} = Tinymesh.Proto.serialize msg
# => {:ok,
#      <<35, 1, 0, 0, 0, 2, 0, 0, 0, 90, 1, 1, 20, 17, 0, 0, 2, 6, 99, 2, 191, 196,
#		     92, 170, 161, 111, 239, 14, 184, 15, 106, 2, 0, 1, 34>>}
```


## Licensing

The code for the Workbench application is released under a 2-clause
BSD license. This license can be found in the `./LICENSE` file.
