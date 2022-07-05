defmodule PhoenixLiveSession.Strategy.ETS do
  # Application.get_env(:routific, :api_key)
  @moduledoc """
  Session store that uses ETS

  ## Options
    * `:pub_sub` - Required.- Module for handling PubSub (e.g. `MyApp.PubSub`).
    * `:table` - ETS table name. Defaults to `:phoenix_live_sessions`
    * `:lifetime` - Lifetime (in ms) of sessions before they are cleared.
       Reads and writes refresh session lifetime. Defaults to two days.
    * `clean_interval` - Interval (in ms) after which expired PhoenixLiveSession
      are cleared. Defaulst to 60 seconds.

  ## Caveats
  Since sessions are stored in memory, they will be lost when restarting
  your server and are not shared between servers in multi-node setups.
  """

  alias PhoenixLiveSession.Strategy
  @behaviour Strategy

  @impl Strategy
  def get(table, sid, _opts \\ []) do
    case :ets.lookup(table, sid) do
      [{^sid, data, expires_at}] ->
        {:ok, data, expires_at}

      [] ->
        nil
    end
  end

  @impl Strategy
  def put(table, sid, data, expires_at, _opts \\ []) do
    :ets.insert(table, {sid, data, expires_at})
  end

  @impl Strategy
  def put_new(table, sid, data, expires_at, _opts \\ []) do
    :ets.insert_new(table, {sid, data, expires_at})
  end

  @impl Strategy
  def delete(table, sid, _opts \\ []) do
    :ets.delete(table, sid)
  end

  @impl Strategy
  def clean_expired(table, opts) do
    lifetime = Keyword.fetch!(opts, :lifetime)
    now = DateTime.utc_now()

    cutoff =
      now
      |> DateTime.add(-1 * lifetime, :millisecond)
      |> DateTime.to_unix()

    :ets.select_delete(table, [{{:_, :_, :"$1"}, [{:<, :"$1", cutoff}], [true]}])
    :ets.insert(table, {"last_clean", nil, DateTime.to_unix(now)})
  end
end
