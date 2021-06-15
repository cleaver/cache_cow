defmodule CacheCow.CacheServerTest do
  use ExUnit.Case
  alias CacheCow.CacheServer

  setup do
    CacheServer.clear()
  end

  test "put values" do
    CacheServer.put("cache_cow", %{says: "moo"})
    result = CacheServer.dump()
    assert Map.has_key?(result, :index)
    assert Map.has_key?(result, :expiry)
    assert Map.has_key?(result.index, "cache_cow")
    assert "cache_cow" in result.expiry
  end

  test "get value" do
    CacheServer.put(1, "one")
    CacheServer.put(2, "two")
    assert CacheServer.get(1) == "one"
    assert CacheServer.get(2) == "two"
  end

  test "clear all" do
    CacheServer.put(1, "one")
    CacheServer.clear()
    assert is_nil(CacheServer.get(1))
  end
end
