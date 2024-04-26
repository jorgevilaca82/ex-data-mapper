defmodule ExDataMapper do
  def new_map_for(from, to, mapping_rules) do
    {
      %{from: from, to: to},
      mapping_rules
    }
  end

  def map({%{from: from, to: to}, mappings}) when is_struct(from) do
    from
    |> Map.from_struct()
    |> do_map(mappings)
    |> then(fn mapped_data ->
      struct(to.__struct__, mapped_data)
    end)
  end

  def map({data, mappings}), do: do_map(data, mappings)

  def map(data, mappings) when is_map(data), do: do_map(data, mappings)

  defp do_map(data, mappings) when is_list(mappings) do
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
       do: {key, do_map(current_value, map_def)}

  defp transform({_key, {new_key, map_def}}, current_value)
       when is_map(current_value),
       do: {new_key, do_map(current_value, map_def)}

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
