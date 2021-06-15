defmodule CacheCow.CacheHelper do
  alias CacheCow.CacheServer

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
