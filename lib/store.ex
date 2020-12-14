defmodule PhoenixLiveSession.Store do
  use GenServer

  @default_table :phoenix_live_sessions

  @doc """
  Starts GenServer to hold on to ETS table.

  Use this in your application supervision tree.
  """
  def start_link(_opts) do
    table = Application.get_env(PhoenixLiveSession, :table, @default_table)
    GenServer.start_link(__MODULE__, table, name: __MODULE__)
  end

  @impl true
  def init(table) do
    :ets.new(table, [:named_table, :public, read_concurrency: true])
    {:ok, table}
  end
end
