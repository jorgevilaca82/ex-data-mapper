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
## How to use this lib

When you have a map and you want to keep some keys.

```elixir
data = %{
  name: "Jhon",
  age: 42,
  email: "jhon@email.com"
}

keep = [:name, :email]

ExDataMapper2.map(data, keep)

...> %{ name: "Jhon", email: "jhon@email.com"}

```

When you have a map and you want to keep some keys but need to rename some key.

```elixir
data = %{
  name: "Jhon",
  age: 42,
  email: "jhon@email.com"
}

new_email_key = :email_address

keep = [:name, email: new_email_key]

ExDataMapper2.map(data, keep)

...> %{ name: "Jhon", email_address: "jhon@email.com"}

```

When you have a map and you want to keep some keys but also run some transformation.

Inform a tuple containing the key and a transformation function

```elixir
data = %{
  name: "Jhon",
  age: 42,
  email: "jhon@email.com"
}

keep = [{:name, &String.upcase/1}, :email]

ExDataMapper2.map(data, keep)

...> %{name: "JHON", email: "jhon@email.com"}
```

If you want to rename the key and also run a transformation
```elixir
data = %{
  name: "Jhon",
  age: 42,
  email: "jhon@email.com"
}

# update name to full_name and run a transformation function
keep = [
  {:name, {:full_name, &String.upcase/1}}, 
  :email
]

ExDataMapper2.map(data, keep)

...> %{full_name: "JHON", email: "jhon@email.com"}
```

## Working with structs

You can also convert a struct to another using the protocol.

Consider you want to map/transform your struct to an external format.

```elixir
defmodule MyUser do
  defstruct name: nil, age: nil, address_line: nil
end

defmodule ExternalUser do
  defstruct full_name: nil, how_old: nil, address_line: nil
end


# Implement the protocol for your internal struct
defimpl ExDataMapper2.DataMapProtocol, for: MyUser do
  defp upcase(value), do: String.upcase(value)

  def map_for(from, %ExternalUser{} = to) do
    rules = [
      :address_line,
      {:name, {:full_name, &upcase/1}},
      age: :how_old
    ]

    ExDataMapper2.new_map_for(from, to, rules)
    |> ExDataMapper2.map()
  end
end


my_user_data = %{
  name: "my full name",
  age: "42",
  address_line: "some address line 123"
}

struct(MyUser, my_user_data)
|> ExDataMapper2.DataMapProtocol.map_for(%ExternalUser{})

...> %ExternalUser{
  full_name: "MY FULL NAME",
  how_old: "42",
  address_line: "some address line 123"
}
```

You also can derive an ecto schema to simplify mapping

```elixir
defmodule ExDataMapper.ExternalUser2 do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @derive {ExDataMapper.DataMapProtocol,
           [
             to: %ExDataMapper.MyUser{},
             mapping_rules: [
               :address_line,
               {:full_name, {:name, &String.upcase/1}},
               how_old: :age
             ]
           ]}

  embedded_schema do
    field(:full_name, :string)
    field(:how_old, :integer)
    field(:address_line, :string)
  end

  def create(external_params) do
    %__MODULE__{}
    |> cast(external_params, [:full_name, :how_old, :address_line])
    |> apply_changes()
  end
end
```

```elixir
external_params = %{"full_name" => "Jorge"}

ExDataMapper.ExternalUser2.create(external_params)
|> ExDataMapper.DataMapProtocol.map_for(%ExDataMapper.MyUser{})

# %ExDataMapper.MyUser{name: "JORGE", age: nil, address_line: nil}
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_data_mapper>.

