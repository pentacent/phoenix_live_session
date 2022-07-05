# Copyright 2013 Plataformatec.
# Copyright 2020 Pentacent.
#
# You may find a copy of the original file here:
# https://github.com/elixir-plug/plug/blob/ed0541110749531b1fd89cd2fac102ccef4041dc/test/plug/session/ets_test.exs

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

defmodule PhoenixLiveSession.Strategy.NebulexTest do
  use ExUnit.Case, async: false
  alias PhoenixLiveSession, as: LiveSession
  alias PhoenixLiveSession.Strategy.Nebulex

  @pub_sub PhoenixLiveSessionTestPubSub

  setup_all do
    Supervisor.start_link([{Phoenix.PubSub, name: @pub_sub}], strategy: :one_for_one)

    :ok
  end

  @tag :skip
  test "subscribe to and modify session" do
    opts = LiveSession.init(pub_sub: @pub_sub, store: Nebulex)
    LiveSession.put(%{}, "sid", %{}, opts)
    {"sid", session} = LiveSession.get(%{}, "sid", opts)

    socket =
      %Phoenix.LiveView.Socket{}
      |> Map.put(:connected?, true)
      |> Map.put(:transport_pid, "fake-pid")
      |> LiveSession.maybe_subscribe(session)

    LiveSession.put_session(socket, "foo", "bar")

    assert {:messages, [message]} = Process.info(self(), :messages)
    assert {:live_session_updated, %{"foo" => "bar"}} = message

    LiveSession.put_session(socket, "fizz", "buzz")

    assert {:messages, [_, message]} = Process.info(self(), :messages)
    assert {:live_session_updated, %{"foo" => "bar", "fizz" => "buzz"}} = message
  end

  @tag :skip
  test "put and get session" do
    opts = LiveSession.init(pub_sub: @pub_sub, store: Nebulex)

    assert "sid-foo" = LiveSession.put(%{}, "sid-foo", %{foo: :bar}, opts)
    assert "sid-bar" = LiveSession.put(%{}, "sid-bar", %{bar: :foo}, opts)

    assert {"sid-foo", %{foo: :bar}} = LiveSession.get(%{}, "sid-foo", opts)
    assert {"sid-bar", %{bar: :foo}} = LiveSession.get(%{}, "sid-bar", opts)

    assert {nil, %{}} = LiveSession.get(%{}, "sid-unknown", opts)
  end

  @tag :skip
  test "delete session" do
    opts = LiveSession.init(pub_sub: @pub_sub, store: Nebulex)

    LiveSession.put(%{}, "sid-foo", %{foo: :bar}, opts)
    LiveSession.put(%{}, "sid-bar", %{bar: :foo}, opts)

    LiveSession.delete(%{}, "sid-foo", opts)

    assert {nil, %{}} = LiveSession.get(%{}, "sid-foo", opts)
    assert {"sid-bar", %{bar: :foo}} = LiveSession.get(%{}, "sid-bar", opts)
  end

  @tag :skip
  test "generate new sid" do
    opts = LiveSession.init(pub_sub: @pub_sub, store: Nebulex)
    sid = LiveSession.put(%{}, nil, %{}, opts)
    assert byte_size(sid) == 128
  end

  @tag :skip
  test "invalidate sid if unknown" do
    opts = LiveSession.init(pub_sub: @pub_sub, store: Nebulex)
    assert {nil, %{}} = LiveSession.get(%{}, "sid-unknown", opts)
  end

  @tag :skip
  test "put session data without subscribing" do
    opts = LiveSession.init(pub_sub: @pub_sub, store: Nebulex)
    sid = LiveSession.put(nil, nil, %{foo: :bar}, opts)
    {_, session} = LiveSession.get(nil, sid, opts)

    {_, updated_session} = LiveSession.put_session(session, "fizz", :buzz)

    assert %{"fizz" => :buzz} = updated_session
    assert %{"fizz" => :buzz} = elem(LiveSession.get(nil, sid, opts), 1)
  end
end
