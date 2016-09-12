defmodule Tinymesh.Proto.Mixfile do
  use Mix.Project

  def project do
    [ app: :tinymesh,
      version: "0.4.0-2",
      deps: [
        {:poison, "~> 1.2", only: :dev, env: :test},
#        {:exprof, "~> 0.1", only: :dev, env: :test}
      ]
    ]
  end
end
