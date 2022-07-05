defmodule PhoenixLiveSession.Strategy.Nebulex do
  @moduledoc """
  Session store that uses Nebulex as a distributed storage.
  """
  alias PhoenixLiveSession.Strategy
  @behaviour Strategy

  @impl Strategy
  def get(table, sid, opts) do
    cache = Keyword.fetch!(opts, :nebulex_cache)

    with {data, expires_at} <- cache.get({table, sid}) do
      {:ok, data, expires_at}
    else
      true ->
        cache.delete({table, sid})
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
  def put(table, sid, data, expires_at, opts) do
    cache = Keyword.fetch!(opts, :nebulex_cache)
    cache.put({table, sid}, {data, expires_at})
  end

  @impl Strategy
  def put_new(table, sid, data, expires_at, opts) do
    cache = Keyword.fetch!(opts, :nebulex_cache)
    cache.put_new({table, sid}, {data, expires_at})
  end

  @impl Strategy
  def delete(table, sid, opts) do
    cache = Keyword.fetch!(opts, :nebulex_cache)
    cache.delete({table, sid})
  end
end
