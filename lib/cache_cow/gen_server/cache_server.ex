defmodule CacheCow.CacheServer do
  use GenServer
  alias CacheCow.CacheStorage

  def start_link(_1opts) do
    GenServer.start_link(__MODULE__, %CacheStorage{}, name: __MODULE__)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def clear do
    GenServer.cast(__MODULE__, {:clear})
  end

  def dump do
    GenServer.call(__MODULE__, {:dump})
  end

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
