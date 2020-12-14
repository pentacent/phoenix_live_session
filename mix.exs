defmodule PhoenixLiveSession.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_live_session,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [exclude: [Phoenix.LiveView]]
    ]
  end

  def application do
    [
      mod: {PhoenixLiveSession.Application, []},
      applications: [:crypto],
      extra_applications: [:phoenix_pubsub]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.10"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_live_view, "~> 0.5"},
      {:ex_doc, ">= 0.0.0", only: :docs}
    ]
  end
end
