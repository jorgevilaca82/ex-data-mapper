defmodule ExDataMapperTest do
  use ExUnit.Case
  doctest ExDataMapper

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

  test "simple map of preserve inner maps" do
    # Arrange
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

  test "simple map rename key and preserve inner map" do
    # Arrange
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

  test "simple map preserve key and transform inner map" do
    # Arrange
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

  test "simple map rename key and transform inner map" do
    # Arrange
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

  # :address ✅
  # {:address, :new_address} ✅
  # {:address, [:country, :state]}
  # {:address, {:new_address, [:country, :state]}}
  # {:address, {:new_address, [:country, state: fn value -> String.upcase(value) end]}}
  # {:address, {:new_address, [:country, state: :uf]}}
  # {:address, {:new_address, [:country, state: {:uf, fn value -> String.upcase(value) end}]}}
end
