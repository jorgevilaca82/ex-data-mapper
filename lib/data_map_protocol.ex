defprotocol ExDataMapper.DataMapProtocol do
  def map_for(from, to)
end

defimpl ExDataMapper.DataMapProtocol, for: Any do
  defmacro __deriving__(module, _struct, opts) do
    to_struct = opts[:to].__struct__
    mapping_rules = opts[:mapping_rules]

    quote do
      unquote(to_struct)

      defimpl ExDataMapper.DataMapProtocol, for: unquote(module) do
        def map_for(from, %to_struct{} = to) do
          ExDataMapper.new_map_for(from, to, unquote(mapping_rules))
          |> ExDataMapper.map()
        end
      end
    end
  end

  def map_for(from, _to) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: from,
      description: """
      ExDataMapper.DataMapProtocol protocol must always be explicitly implemented.
      """
  end
end
