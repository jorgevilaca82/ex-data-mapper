defmodule ExDataMapper do
  @moduledoc """
  Documentation for `ExDataMapper`.
  """

  @doc """
  Maps data.

  ## Examples

      iex> data = %{name: "Jhon"}
      iex> mappings = %{name: :login}
      iex> ExDataMapper.map(mappings, data)
      %{login: "Jhon"}

  """
  @spec map(map(), map()) :: map()
  def map(mappings, data) do
    for {key, new_key_defs} <- mappings, into: %{} do
      {new_key, map_or_op} = normalize_new_key_defs(key, new_key_defs)

      if Map.has_key?(data, key) do
        value = data[key]
        transform(value, new_key, map_or_op, data)
      end
    end
  end

  defp normalize_new_key_defs(current_key, new_key_defs) do
    case new_key_defs do
      nil -> {current_key, nil}
      new_key when is_atom(new_key) -> {new_key, nil}
      op when is_function(op) -> {current_key, op}
      {nil, op} when is_function(op) -> {current_key, op}
      {new_key, op} when is_function(op) -> {new_key, op}
      {nil, map} when is_map(map) -> {current_key, map}
      {new_key, map} when is_map(map) -> {new_key, map}
    end
  end

  defp transform(value, new_key, nil, _), do: {new_key, value}

  defp transform(value, new_key, op, original_data) when is_function(op),
    do: {new_key, op.(value, original_data)}

  defp transform(value, new_key, map, _) when is_map(map), do: {new_key, map(map, value)}
end
