defmodule CacheCow.CacheServer do
  use GenServer
  alias CacheCow.CacheStorage

  @moduledoc """
  Defines a GenServer behaviour for a cache server.
  """

  ## Public facing API

  @doc """
  Start the server.
  """
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %CacheStorage{}, name: __MODULE__)
  end

  @doc """
  Get a value from the cache.

  ## Parameters:

  - key: (any) the key for the data to retrieve.

  """
  @spec get(any) :: any
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Put a key / value pair in the cache.

  ## Parameters:

  - key: (any) the key for the data to store.
  - value: (any) the value to store.
  """
  @spec put(any(), any()) :: :ok
  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  @doc """
  Clear the entire cache.
  """
  @spec clear :: :ok
  def clear do
    GenServer.cast(__MODULE__, {:clear})
  end

  @doc """
  Print out all data from the cache index and expiry list.
  """
  @spec dump :: any()
  def dump do
    GenServer.call(__MODULE__, {:dump})
  end

  ## GenServer API

  @impl true
  def init(storage) do
    {:ok, storage}
  end

  @impl true
  def handle_call({:get, key}, _from, storage) do
    {value, storage} = CacheStorage.get(storage, key)
    {:reply, value, storage}
  end

  @impl true
  def handle_call({:dump}, _from, storage) do
    {:reply, storage, storage}
  end

  @impl true
  def handle_cast({:put, key, value}, storage) do
    {:noreply, CacheStorage.put(storage, key, value)}
  end

  @impl true
  def handle_cast({:clear}, _storage) do
    {:noreply, %CacheStorage{}}
  end
end
