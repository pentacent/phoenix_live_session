defmodule PhoenixLiveSession.Strategy.Nebulex do
  @moduledoc """
  Session store that uses Nebulex as a distributed storage.
  """
  alias PhoenixLiveSession.Strategy
  @behaviour Strategy
  @cache Application.get_env(
           :phoenix_live_session,
           :nebulex_cache,
           PhoenixLiveSession.Nebulex.TestCache
         )

  @impl Strategy
  def get(table, sid) do
    with {data, expires_at} <- @cache.get({table, sid}),
         false <- :os.system_time(:millisecond) > expires_at do
      {:ok, data, expires_at}
    else
      true ->
        @cache.delete({table, sid})
        nil

      nil ->
        nil
    end
  end

  @impl Strategy
  def clean_expired(_table, _opts) do
    :ok
  end

  @impl Strategy
  def put(table, sid, data, expires_at) do
    @cache.put({table, sid}, {data, expires_at})
  end

  @impl Strategy
  def put_new(table, sid, data, expires_at) do
    @cache.put_new({table, sid}, {data, expires_at})
  end

  @impl Strategy
  def delete(table, sid) do
    @cache.delete({table, sid})
  end
end
