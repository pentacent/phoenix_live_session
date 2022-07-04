defmodule PhoenixLiveSession.Strategy do
  @callback get(table :: atom, sid :: any) ::
              {:ok, data :: term, expires_at :: integer} | nil
  @callback put(table :: atom, sid :: any, data :: term, expires_at :: integer) :: term
  @callback put_new(table :: atom, sid :: any, data :: term, expires_at :: integer) ::
              boolean
  @callback delete(table :: atom, sid :: any) :: term
  @callback clean_expired(table :: atom, opts :: term) :: term
end
