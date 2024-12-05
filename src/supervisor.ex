defmodule TicTacToe.Supervisor do
  def start() do
    config()

    children = [
      TicTacToe.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp config() do
    Application.put_env(:sample, TicTacToe.Endpoint,
      http: [ip: {127, 0, 0, 1}, port: 5001],
      server: true,
      live_view: [signing_salt: "aaaaaaaa"],
      secret_key_base: String.duplicate("a", 64)
    )
  end
end
