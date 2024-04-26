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

# ########################################################

my_user_data = %{
  name: "my full name",
  age: "42",
  address_line: "some address line 123"
}

struct(MyUser, my_user_data)
|> ExDataMapper2.DataMapProtocol.map_for(%ExternalUser{})
|> ExDataMapper2.map()
