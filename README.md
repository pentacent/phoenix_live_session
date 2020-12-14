# Phoenix LiveSession

![CI](https://github.com/pentacent/phoenix_live_session/workflows/CI/badge.svg)
 [![Hex pm](http://img.shields.io/hexpm/v/phoenix_live_session.svg?style=flat)](https://hex.pm/packages/phoenix_live_session)
 [![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/phoenix_live_session)

LiveSession provides in-memory sessions for LiveViews and Phoenix controllers.

You can use them like regular Plug sessions in Phoenix controllers and have
full read/write access to session data from LiveViews - including updates
via Phoenix.PubSub.

## Installation
1. Add this project to your `mix.exs` as a dependency:
   `{:phoenix_live_session, "~> 0.1"},`
2. Add PhoenixLiveSession as store for Plug.Session:
   ```elixir
    # lib/my_app_web/endpoint.ex
      @session_options [
          store: PhoenixLiveSession,
          pub_sub: MyApp.PubSub,
          signing_salt: "your-salt"
      ]
   ```

## Usage
### Usage in Phoenix Controllers
  You don’t need to do anything special to use LiveSessions in regular
  Phoenix controllers.
  Your sessions will continue to work the same as with other stores.

### Usage in LiveViews
  Use `maybe_subscribe/2` in your `mount/3` function to subscribe to
  LiveSession updates.
  Only sockets with `connected? == true` are subscribed by `maybe_subscribe/2`.

  Once you’ve subscribed to a LiveSession, you can handle session
  updates with `handle_info/2` and push session updates with `put_session/3`.

### Example
```elixir
defmodule ShoppingCartLive
  use MyAppWeb, :live_view

  def mount(_params, session, socket) do
    socket = socket
    |> PhoenixLiveSession.maybe_subscribe(session)
    |> put_session_assigns(session)

    {:ok, socket}
  end

  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, put_session_assigns(socket, session)}
  end

  def handle_event("add_to_cart", %{"product_id" => product_id}, socket) do
    updated_cart = [product_id | socket.assigns.cart]
    PhoenixLiveSession.put_session(socket, "cart", updated_cart)

    {:noreply, socket}
  end

  defp put_sesion_assigns(socket, session) do
    socket
    |> assign(:shopping_cart, Map.get(session, "shopping_cart", []))
  end
end
```


## License
Copyright 2013 Plataformatec.
Copyright 2020 Pentacent.

Licensed under the Apache License, Version 2.0 (the "License");
You may not use any files in this repository except in compliance with
the License. You may find a copy of the License in the [LICENSE](LICENSE) file.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
