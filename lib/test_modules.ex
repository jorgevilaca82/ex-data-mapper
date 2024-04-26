defmodule ExDataMapper.MyUser do
  defstruct name: nil, age: nil, address_line: nil
end

defmodule ExDataMapper.ExternalUser do
  defstruct full_name: nil, how_old: nil, address_line: nil
end

defimpl ExDataMapper.DataMapProtocol, for: ExDataMapper.MyUser do
  defp upcase(value), do: String.upcase(value)

  def map_for(from, %ExDataMapper.ExternalUser{} = to) do
    rules = [
      :address_line,
      {:name, {:full_name, &upcase/1}},
      age: :how_old
    ]

    ExDataMapper.new_map_for(from, to, rules)
  end
end
