data = %{
  name: "Jorge",
  other_name: "Jorge",
  upcasename: "Jorge",
  otherupcasename: "Jorge",
  address: %{
    state: "mn",
    country: "US",
    street: "some street"
  }
}

mappings = [
  :non_existent_key_ignored,
  :name,
  {:other_name, :full_name},
  {:upcasename, &String.upcase/1},
  {:otherupcasename, {:otherfullname, fn value -> String.upcase(value) end}}
  # :address
  # {:address, :new_address}
  # {:address, [:country, :state]}
  # {:address, {:new_address, [:country, :state]}}
  # {:address, {:new_address, [:country, state: fn value -> String.upcase(value) end]}}
  # {:address, {:new_address, [:country, state: :uf]}}
  # {:address, {:new_address, [:country, state: {:uf, fn value -> String.upcase(value) end}]}}
]

data
|> ExDataMapper2.map(mappings)

# #######################################################

defmodule MyUser2 do
  @to_external_user_mapping_rules [age: :how_old]

  @derive {ExDataMapper2.DataMapProtocol,
           [to: %ExternalUser{}, mapping_rules: @to_external_user_mapping_rules]}
  defstruct age: nil
end

defmodule MyUser do
  defstruct name: nil, age: nil, address_line: nil
end

defmodule ExternalUser do
  defstruct full_name: nil, how_old: nil, address_line: nil
end

defimpl ExDataMapper2.DataMapProtocol, for: MyUser do
  defp upcase(value), do: String.upcase(value)

  def map_for(from, %ExternalUser{} = to) do
    rules = [
      :address_line,
      {:name, {:full_name, &upcase/1}},
      age: :how_old
    ]

    ExDataMapper2.new_map_for(from, to, rules)
  end
end

# ########################################################

my_user_data = %{
  name: "my full name",
  age: "42",
  address_line: "some address line 123"
}

struct(MyUser, my_user_data)
|> ExDataMapper2.DataMapProtocol.map_for(%ExternalUser{})
|> ExDataMapper2.map()
