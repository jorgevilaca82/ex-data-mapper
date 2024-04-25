defprotocol ExDataMapper2.DataMapProtocol do
  def map_for(from, to)
end

defmodule MyUser do
  defstruct name: nil, age: nil, address_line: nil
end

defmodule ExternalUser do
  defstruct full_name: nil, how_old: nil, address_line: nil
end

defimpl ExDataMapper2.DataMapProtocol, for: ExternalUser do
  defp upcase(value), do: String.upcase(value)

  def map_for(from, %MyUser{} = to) do
    {Map.from_struct(from),
     [
       :address_line,
       {:full_name, {:name, &upcase/1}}
     ]}
  end
end

external_data = %{
  full_name: "my full name",
  how_old: "42",
  address_line: "some address line 123"
}

struct(ExternalUser, external_data)
|> ExDataMapper2.DataMapProtocol.map_for(%MyUser{})
|> ExDataMapper2.map()
