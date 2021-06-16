defmodule CacheCow.CacheStorage do
  alias __MODULE__

  @moduledoc """
  Manage the cache storage.
  """

  defstruct index: %{}, expiry: []

  @max_cache 5

  @doc """
  Get a value from cache storage by key.

  ## Parameters:

  - storage: (%CacheStorage{} struct) - the cache storage.
  - key: (any) - the key for the data to get.

  ## Return: {value, storage}

  """
  @spec get(%CacheCow.CacheStorage{}, any()) :: {any(), %CacheCow.CacheStorage{}}
  def get(%CacheStorage{index: index, expiry: expiry} = _storage, key) do
    value = index[key]

    new_expiry =
      if is_nil(value) do
        expiry
      else
        set_recent_key(expiry, key)
      end

    {value, %CacheStorage{index: index, expiry: new_expiry}}
  end

  @doc """
  Put a key/value pair into cache storage.

  ## Parameters:

  - storage: (%CacheStorage{} struct) - the cache storage.
  - key: (any) - the key for the data to put.
  - value: (any) - the key for the data to put

  ## Return: storage

  """
  @spec put(%CacheCow.CacheStorage{}, any(), any()) :: %CacheCow.CacheStorage{}
  def put(%CacheStorage{index: index, expiry: expiry} = storage, key, value) do
    cond do
      Map.has_key?(index, key) ->
        %CacheStorage{index: Map.put(index, key, value), expiry: set_recent_key(expiry, key)}

      map_size(index) < @max_cache ->
        %CacheStorage{index: Map.put(index, key, value), expiry: [key | expiry]}

      true ->
        replace_oldest(storage, key, value)
    end
  end

  ## Move the specified key to the head of the list.
  defp set_recent_key(expiry, key), do: [key | List.delete(expiry, key)]

  ## Replace the oldest cache value with the new value.
  defp replace_oldest(%CacheStorage{index: index, expiry: expiry} = _storage, key, value) do
    oldest_key = List.last(expiry)
    new_index = index |> Map.delete(oldest_key) |> Map.put(key, value)
    new_expiry = [key | List.delete(expiry, oldest_key)]
    %CacheStorage{index: new_index, expiry: new_expiry}
  end
end
