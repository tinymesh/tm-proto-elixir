defmodule Tinymesh.Proto.Mixfile do
  use Mix.Project

  def project do
    [ app: :tinymesh,
      version: "0.4.0-2",
      deps: [
        {:exprof, "~> 0.1.0", only: :test, env: :test}
      ]
    ]
  end
end
