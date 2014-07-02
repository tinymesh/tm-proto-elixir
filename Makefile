MIX_ENV ?= dev

all: ebin/Elixir.Tinymesh.Config.beam \
     ebin/Elixir.Tinymesh.Proto.beam \
     ebin/Elixir.Tinymesh.Proto.PacketError.beam \
     ebin/tinymesh.app

clean:
	@rm -rvf _build ebin

ebin/Elixir.Tinymesh.Config.beam: priv/config lib/mix/tasks/cg.ex
	mix do compile, cgen
	mkdir -p ebin/
	cp -v _build/$(MIX_ENV)/lib/tinymesh/ebin/Elixir.Tinymesh.Config.beam ebin/

ebin/%.beam: lib/tinymesh/*.ex
	mix compile
	mkdir -p ebin/
	cp -v _build/$(MIX_ENV)/lib/tinymesh/ebin/$*.beam ebin/

ebin/tinymesh.app: mix.exs
	mix compile
	mkdir -p ebin
	cp -v _build/$(MIX_ENV)/lib/tinymesh/ebin/tinymesh.app ebin/
