defmodule PhoenixLiveSession.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_live_session,
      version: "0.1.2",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [exclude: [Phoenix.LiveView]],
      package: package(),
      docs: docs(),
      source_url: "https://github.com/pentacent/phoenix_live_session",
      homepage_url: "https://github.com/pentacent/phoenix_live_session"
    ]
  end

  def application do
    [
      mod: {PhoenixLiveSession.Application, []},
      applications: [:crypto],
      extra_applications: [:phoenix_pubsub]
    ]
  end

  defp package do
    %{
      description: "In-memory live sessions for LiveViews and Phoenix controllers.",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/pentacent/phoenix_live_session"},
    }
  end

  defp docs do
    [
      name: "Phoenix Live Session",
      main: "PhoenixLiveSession",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.10"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_live_view, "~> 0.5"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
