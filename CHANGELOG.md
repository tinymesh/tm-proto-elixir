# Changelog

## 0.4.0

* Enchantments 
	* Add `addr` flag to support (un)serialize with (addr, byte) style
	  blobs

Changes

- Code generation now happends inline, and `mix cgen` task is removed
- Configuration now accepts both proplists and maps
- Move `vsn` argument in `Tinymesh.Config.serialize` into `opts` map 
- Rename various configuration fields
