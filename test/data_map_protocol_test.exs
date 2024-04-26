defmodule DataMapProtocolTest do
  use ExUnit.Case
  doctest ExDataMapper.DataMapProtocol

  alias ExDataMapper.ExternalUser
  alias ExDataMapper.MyUser

  test "convert on struct to another" do
    my_user_data = %{
      name: "my full name",
      age: "42",
      address_line: "some address line 123"
    }

    expected = %ExDataMapper.ExternalUser{
      full_name: "MY FULL NAME",
      how_old: "42",
      address_line: "some address line 123"
    }

    struct(MyUser, my_user_data)
    |> ExDataMapper.DataMapProtocol.map_for(%ExternalUser{})
    |> ExDataMapper.map()
    |> Kernel.==(expected)
    |> assert
  end
end
