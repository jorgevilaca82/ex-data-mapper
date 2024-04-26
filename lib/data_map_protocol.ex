defprotocol ExDataMapper2.DataMapProtocol do
  def map_for(from, to)
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
