defmodule CacheCow.CacheHelper do
  alias CacheCow.CacheServer

  @doc """
  Cache helper function. Returns cached value for a function expression, otherwise returns the result of the expression.

  ## Parameters:

  - key:any() - the key to identify the expression result.
  - function:function() - the function to be evaluated.

  ## Returns:any() - the result, cached or computed.

  """
  @spec cached(any(), function()) :: any()
  def cached(key, function) do
    case CacheServer.get(key) do
      value when is_nil(value) ->
        new_value = function.()
        CacheServer.put(key, new_value)
        new_value

      value ->
        value
    end
  end
end
