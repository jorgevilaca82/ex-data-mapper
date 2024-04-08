defmodule ExDataMapperTest do
  use ExUnit.Case
  doctest ExDataMapper

  test "preserve key and do no transformation" do
    data = %{name: "Jhon"}
    mappings = %{name: nil}

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{name: "Jhon"}
  end

  test "preserve key and do no transformation, ignore keys not in mappings" do
    data = %{name: "Jhon", date_of_birth: ~c"1980-01-01"}
    mappings = %{name: nil}

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{name: "Jhon"}
  end

  test "map simple atom key" do
    data = %{name: "Jhon"}
    mappings = %{name: :login}

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{login: "Jhon"}
  end

  test "transform value and preserve key passing function" do
    data = %{name: "Jhon"}

    mappings = %{name: fn value, _ -> String.upcase(value) end}

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{name: "JHON"}
  end

  test "transform value and preserve key passing a tuple param" do
    data = %{name: "Jhon"}

    mappings = %{name: {nil, fn value, _ -> String.upcase(value) end}}

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{name: "JHON"}
  end

  test "transform value and update key" do
    data = %{name: "Jhon", date_of_birth: "1980-01-01"}

    mappings = %{
      name: {:login, fn value, _ -> String.upcase(value) end},
      date_of_birth: {:dob, fn value, _ -> Date.from_iso8601!(value) end}
    }

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{login: "JHON", dob: ~D[1980-01-01]}
  end

  test "combine two or more values to form a new field" do
    data = %{first_name: "Jhon", last_name: "Doe"}

    mappings = %{
      first_name:
        {:full_name,
         fn value, %{last_name: last_name} = _original_data ->
           "#{value} #{last_name}"
         end}
    }

    new_data = ExDataMapper.map(mappings, data)

    assert new_data == %{full_name: "Jhon Doe"}
  end

  test "map inner attributes" do
    data = %{
      name: "Jhon",
      address: %{
        address: "1st Street",
        city: "Big City",
        province: "Big County",
        country: "CA",
        postalCode: "000-000"
      }
    }

    mappings = %{
      name: nil,
      address:
        {:full_address,
         %{
           address: :line_address_1,
           city: nil,
           province: :state,
           country: nil,
           postalCode: :postalNumber
         }}
    }

    new_data = ExDataMapper.map(mappings, data) |> IO.inspect()

    assert new_data == %{
             name: "Jhon",
             full_address: %{
               state: "Big County",
               city: "Big City",
               country: "CA",
               line_address_1: "1st Street",
               postalNumber: "000-000"
             }
           }
  end

  test "combine inner attributes" do
    data = %{
      name: "Jhon",
      address: %{
        address: "1st Street",
        city: "Big City",
        province: "Big County",
        country: "CA",
        postalCode: "000-000"
      }
    }

    mappings = %{
      name: nil,
      address:
        {:full_address,
         fn %{
              address: address,
              city: city,
              province: province,
              country: country,
              postalCode: postalCode
            }, _ ->
           "#{address}, #{city}-#{province}, #{country}, #{postalCode}"
         end}
    }

    new_data = ExDataMapper.map(mappings, data) |> IO.inspect()

    assert new_data == %{
             name: "Jhon",
             full_address: "1st Street, Big City-Big County, CA, 000-000"
           }
  end
end
