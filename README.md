# ExDataMapper

**TODO: Add description**

ExDataMapper allows you to map and tranform data from one format to another. If several times you found yourself
receiving external data and having to translate/transform data to meet internal expectations, this lib is for you.

For exemple, you receive a external struct with a key "name" but you need "login" instead. With ExDataMapper it's
easy to do that transformation.

Only the specified keys on mappings will be translated/transformed, all other will be ignored.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_data_mapper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_data_mapper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_data_mapper>.

