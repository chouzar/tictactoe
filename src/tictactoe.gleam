import gleam/io

pub fn main() {
  start_phoenix()
  io.println("Hello from tictactoe!")
}

@external(erlang, "Elixir.TicTacToe.Endpoint", "start_endpoint")
fn start_phoenix() -> phoenix
