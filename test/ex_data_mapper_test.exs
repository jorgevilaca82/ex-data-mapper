defmodule ExDataMapperTest do
  use ExUnit.Case
  doctest ExDataMapper

  setup do
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

    [data: data]
  end

  test "preserve key and do no transformation" do
    # Arrange
    data = %{name: "Jhon", age: 40}
    mapping_rules = [:name]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{name: "Jhon"}
    # should have only keys specified on mapping rules
    assert not Map.has_key?(new_data, :age)
  end

  test "map key to a new key" do
    # Arrange
    data = %{name: "Jhon", age: 40}
    mapping_rules = [:age, name: :full_name]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{full_name: "Jhon", age: 40}
  end

  test "transform value and preserve key with a transformation function" do
    # Arrange
    data = %{name: "Jhon", age: 40}
    mapping_rules = [:age, name: &String.upcase/1]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{name: "JHON", age: 40}
  end

  test "transform value and rename key with a transformation function" do
    # Arrange
    data = %{name: "Jhon", date_of_birth: "1980-01-01"}

    mapping_rules = [
      :age,
      {:name, {:full_name, &String.upcase/1}},
      date_of_birth: &Date.from_iso8601!/1
    ]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{full_name: "JHON", date_of_birth: ~D[1980-01-01]}
  end

  test "simple map of preserve inner maps", %{data: data} do
    # Arrange

    mapping_rules = [:address]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{
             address: %{
               address: "1st Street",
               city: "Big City",
               province: "Big County",
               country: "CA",
               postalCode: "000-000"
             }
           }
  end

  test "simple map rename key and preserve inner map", %{data: data} do
    # Arrange

    mapping_rules = [address: :location]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{
             location: %{
               address: "1st Street",
               city: "Big City",
               province: "Big County",
               country: "CA",
               postalCode: "000-000"
             }
           }
  end

  test "simple map preserve key and transform inner map", %{data: data} do
    # Arrange

    one_line_address = fn value ->
      value |> Map.values() |> Enum.join(", ")
    end

    mapping_rules = [address: one_line_address]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{
             address: "1st Street, Big City, Big County, CA, 000-000"
           }
  end

  test "simple map rename key and transform inner map", %{data: data} do
    # Arrange

    one_line_address = fn value ->
      value |> Map.values() |> Enum.join(", ")
    end

    mapping_rules = [address: {:location, one_line_address}]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{
             location: "1st Street, Big City, Big County, CA, 000-000"
           }
  end

  test "preserve some keys from inner map and keep the parent key", %{data: data} do
    # Arrange

    mapping_rules = [address: [:country, :city]]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{address: %{city: "Big City", country: "CA"}}
  end

  test "preserve some keys and rename some from inner map and keep the parent key", %{data: data} do
    # Arrange

    mapping_rules = [address: [:country, city: :province]]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{address: %{province: "Big City", country: "CA"}}
  end

  test "preserve some keys and rename some from inner map and rename the parent key", %{
    data: data
  } do
    # Arrange

    mapping_rules = [address: {:location, [:country, city: :province]}]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{location: %{province: "Big City", country: "CA"}}
  end

  test "preserve some keys and transform some values from inner map and keep the parent key", %{
    data: data
  } do
    # Arrange

    mapping_rules = [address: [:country, {:city, &String.upcase/1}]]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{address: %{city: "BIG CITY", country: "CA"}}
  end

  test "preserve some keys from inner map and update the parent key", %{data: data} do
    # Arrange

    mapping_rules = [address: {:location, [:country, :city]}]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{location: %{city: "Big City", country: "CA"}}
  end

  test "preserve some keys and transform some values from inner map and update the parent key", %{
    data: data
  } do
    # Arrange

    mapping_rules = [
      address:
        {:location,
         [
           :country,
           {:city, &String.upcase/1}
         ]}
    ]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{location: %{city: "BIG CITY", country: "CA"}}
  end

  test "preserve some keys rename and transform some values from inner map and update the parent key",
       %{
         data: data
       } do
    # Arrange
    format_cep = fn value -> "#{value}##" end

    mapping_rules = [
      address:
        {:location,
         [
           :country,
           postalCode: {:cep, format_cep}
         ]}
    ]

    # Act
    new_data = data |> ExDataMapper.map(mapping_rules)

    # Assert
    assert new_data == %{location: %{country: "CA", cep: "000-000##"}}
  end
end
