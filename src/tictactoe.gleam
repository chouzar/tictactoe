import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/static_supervisor as sup
import gleam/result.{try_recover as else_try}

pub fn main() {
  let _supervisor =
    sup.new(sup.OneForOne)
    |> sup.add(sup.worker_child("endpoint", phoenix_endpoint))
    |> sup.start_link

  observer()

  process.sleep_forever()
}

// ----- Supervision Tree ------ //

@external(erlang, "Elixir.TicTacToe.Supervisor", "start")
fn phoenix_endpoint() -> phoenix_endpoint

@external(erlang, "observer", "start")
fn observer() -> x

// ------ Game Logic ------ //

pub opaque type Game {
  Game(grid: Grid, turn: Mark)
}

pub type Grid =
  Dict(#(Int, Int), Option(Mark))

pub type Mark {
  X
  O
}

pub type Error {
  OutOfBounds(x: Int, y: Int)
  AlreadyMarked(x: Int, y: Int, mark: Mark)
}

pub fn new() -> Game {
  let grid = new_grid(dict.new())
  let assert [mark, ..] = list.shuffle([X, O])
  Game(grid, mark)
}

pub fn mark(game: Game, x: Int, y: Int) -> Result(Game, Error) {
  let Game(grid: grid, turn: mark) = game

  case dict.get(grid, #(x, y)) {
    Ok(None) -> {
      let grid = dict.insert(grid, #(x, y), Some(mark))
      let mark = next_turn(mark)
      let game = Game(grid: grid, turn: mark)
      Ok(game)
    }

    Ok(Some(mark)) -> {
      Error(AlreadyMarked(x, y, mark))
    }

    Error(Nil) -> {
      Error(OutOfBounds(x, y))
    }
  }
}

pub fn win(game: Game) -> Result(Mark, Nil) {
  let Game(grid: grid, ..) = game

  // Check all rows
  use _ <- else_try(check(grid, [#(1, 1), #(1, 2), #(1, 3)]))
  use _ <- else_try(check(grid, [#(2, 1), #(2, 2), #(2, 3)]))
  use _ <- else_try(check(grid, [#(3, 1), #(3, 2), #(3, 3)]))

  // Check all columns
  use _ <- else_try(check(grid, [#(1, 1), #(2, 1), #(3, 1)]))
  use _ <- else_try(check(grid, [#(1, 2), #(2, 2), #(3, 2)]))
  use _ <- else_try(check(grid, [#(1, 3), #(2, 3), #(3, 3)]))

  // Check \ diagonal
  use _ <- else_try(check(grid, [#(1, 1), #(2, 2), #(3, 3)]))

  // Check / diagonal
  use _ <- else_try(check(grid, [#(1, 3), #(2, 2), #(3, 1)]))

  Error(Nil)
}

fn new_grid(grid: Grid) -> Grid {
  let coordinates = {
    use x <- list.flat_map([1, 2, 3])
    use y <- list.map([1, 2, 3])
    #(x, y)
  }

  list.fold(coordinates, grid, fn(grid, coordinate) {
    dict.insert(grid, coordinate, None)
  })
}

fn next_turn(mark: Mark) -> Mark {
  case mark {
    X -> O
    O -> X
  }
}

fn check(grid: Grid, coordinates: List(#(Int, Int))) -> Result(Mark, Nil) {
  let marks =
    coordinates
    |> list.map(get(grid, _))
    |> option.values()

  case marks {
    [x, y, z] if x == y && y == z -> Ok(x)
    _other -> Error(Nil)
  }
}

fn get(dict: Dict(k, v), key: k) -> v {
  let assert Ok(value) = dict.get(dict, key)
  value
}
