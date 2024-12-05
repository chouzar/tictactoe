# ------ Game Live View ------

defmodule TicTacToe.GameLive do
  use Phoenix.LiveView, layout: {TicTacToe.LayoutLive, :live}

  @tictactoe :tictactoe

  def render(assigns) do
    ~H"""
    <div class="win-block">
      <h1><%= @render_win %></h1>
    </div>
    <div class="center">
      <div class="grid">
        <%= for {x, y, mark, class} <- @render_grid do %>
          <%= if @ended? do %>
            <div phx-value-x={x} phx-value-y={y} class={class}>
              <%= mark %>
            </div>
          <% else %>
            <div phx-click="mark" phx-value-x={x} phx-value-y={y} class={class}>
              <%= mark %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    <style><%= css(assigns) %></style>
    """
  end

  def mount(_params, _session, socket) do
    game = @tictactoe.new()

    {:ok,
     socket
     |> assign(:game, game)
     |> assign(:ended?, ended?(game))
     |> assign(:render_win, render_win(game))
     |> assign(:render_grid, render_grid(game))}
  end

  def handle_event("mark", %{"x" => x, "y" => y}, socket) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)

    case @tictactoe.mark(socket.assigns.game, x, y) do
      {:ok, game} ->
        {:noreply,
         socket
         |> assign(:game, game)
         |> assign(:ended?, ended?(game))
         |> assign(:render_win, render_win(game))
         |> assign(:render_grid, render_grid(game))}

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  defp ended?({:game, _grid, _mark} = game) do
    case @tictactoe.win(game) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp render_win({:game, _grid, _mark} = game) do
    case @tictactoe.win(game) do
      {:ok, :x} -> "Game! X 🎉"
      {:ok, :o} -> "Game! O 🎉"
      {:error, _} -> nil
    end
  end

  defp render_grid({:game, grid, _mark} = _game) do
    for x <- [1, 2, 3],
        y <- [1, 2, 3] do
      case Map.get(grid, {x, y}) do
        {:some, :x} -> {x, y, "X", "mark-x"}
        {:some, :o} -> {x, y, "O", "mark-o"}
        :none -> {x, y, nil, nil}
      end
    end
  end

  defp css(assigns) do
    ~H"""
    .grid {
      height: 750px;
      width: 750px;
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      grid-template-rows: 1fr 1fr 1fr;
      background-color: #292d3e;
      gap: 5px;
    }
    .grid > div {
      background-color: #fffefb;
      text-align: center;
      padding: 61px 0px;
      font-size: 100px;
      font-family: verdana;
    }
    .mark-x {
      color: #ffaff3;
    }
    .mark-o {
      color: #4e2a8e;
    }
    .center {
      display: flex;
      justify-content: center;
      height: 100vh;
    }
    .win-block {
      padding-top: 16px;
      padding-bottom: 16px;
      height: 160;
    }
    .win-block > h1 {
      font-family: cursive;
      text-align: center;
      font-size: 100px;
      margin: 0;
    }
    """
  end
end

# ------ Web Layout and helpers ------

defmodule TicTacToe.ErrorView do
  def render(template, _), do: Phoenix.Controller.status_message_from_template(template)
end

defmodule TicTacToe.LayoutLive do
  use Phoenix.LiveView

  defp phx_vsn, do: Application.spec(:phoenix, :vsn)
  defp lv_vsn, do: Application.spec(:phoenix_live_view, :vsn)

  def render("live.html", assigns) do
    ~H"""
    <main>
      <%= @inner_content %>
    </main>
    <script src={"https://cdn.jsdelivr.net/npm/phoenix@#{phx_vsn()}/priv/static/phoenix.min.js"}></script>
    <script src={"https://cdn.jsdelivr.net/npm/phoenix_live_view@#{lv_vsn()}/priv/static/phoenix_live_view.min.js"}></script>
    <script>
      let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket)
      liveSocket.connect()
    </script>
    <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #fffbe8;
    }
    </style>
    """
  end
end

# ------ Web Router and Endpoint ------

defmodule TicTacToe.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", TicTacToe do
    pipe_through(:browser)

    # live("/", LayoutLive, :index)
    live("/", GameLive, :index)
  end
end

defmodule TicTacToe.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample
  socket("/live", Phoenix.LiveView.Socket)
  plug(TicTacToe.Router)
end
