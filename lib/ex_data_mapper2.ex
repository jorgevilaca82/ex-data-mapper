defmodule ExDataMapper2 do

  def map({data, mappings}), do: map(data, mappings)

  def map(data, mappings) when is_list(mappings) do
    for map_def <- mappings, key_is_present(map_def, data), into: %{} do
      key = get_key(map_def)

      transform(map_def, data[key])
    end
  end

  def key_is_present(map_def, data) do
    Map.has_key?(data, get_key(map_def))
  end

  defp get_key({key, _}), do: key
  defp get_key(key), do: key

  defp transform({key, map_def}, current_value)
       when is_list(map_def) and is_map(current_value),
       do: {key, map(current_value, map_def)}

  defp transform({_key, {new_key, map_def}}, current_value)
       when is_map(current_value),
       do: {new_key, map(current_value, map_def)}

  defp transform({_key, {new_key, op}}, current_value)
       when is_atom(new_key) and is_function(op),
       do: {new_key, op.(current_value)}

  defp transform({key, op}, current_value)
       when is_function(op),
       do: {key, op.(current_value)}

  defp transform({_key, new_key}, current_value)
       when is_atom(new_key),
       do: {new_key, current_value}

  defp transform(key, current_value)
       when is_atom(key),
       do: {key, current_value}
end

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

upcase_op = fn value -> String.upcase(value) end

mappings = [
  :non_existent_key_ignored,
  :name,
  {:other_name, :full_name},
  {:upcasename, upcase_op},
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
