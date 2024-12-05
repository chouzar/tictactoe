# Gleam's Interoperability with the BEAM

## Effortlesly download dependencies from Erlang or Elixir

We can take advantage of a whole ecosystem of libraries.

```toml
cubdb = ">= 2.0.0 and < 3.0.0"
ecto = ">= 3.0.0 < 4.0.0"
phoenix = ">= 1.7.0 and < 2.0.0"
```

## Compile both erlang or elixir from the Gleam tool

Gleam wil compile both your erlang or elixir files.

```sh
gleam build
```

## Simple FFI to reach any function on the BEAM

```gleam
@external(erlang, "observer", "start")
fn observer() -> x
```
