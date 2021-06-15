defmodule CacheCow.CacheStorageTest do
  use ExUnit.Case

  alias CacheCow.CacheStorage

  @empty_storage %CacheStorage{}

  @full_storage %CacheStorage{
    expiry: [1, 2, 3, 4, 5],
    index: %{1 => "one", 2 => "two", 3 => "three", 4 => "four", 5 => "five"}
  }

  test "get value from storage" do
    {value1, _} = CacheStorage.get(@full_storage, 1)
    assert value1 == "one"
    {value5, _} = CacheStorage.get(@full_storage, 5)
    assert value5 == "five"
  end

  test "get value not in cache returns nil" do
    {value, _} = CacheStorage.get(@empty_storage, :anything_really)
    assert is_nil(value)
  end

  test "update expiry list" do
    {_, new_storage} = CacheStorage.get(@full_storage, 5)
    assert hd(new_storage.expiry) == 5
  end

  test "put" do
    new_storage =
      CacheStorage.put(@empty_storage, "foo", 42)
      |> CacheStorage.put(:foo, ~s({"json_string": true}))
      |> CacheStorage.put("bar", 3.1415926)

    assert new_storage.index["foo"] == 42
    assert new_storage.index[:foo] == ~s({"json_string": true})
    assert new_storage.index["bar"] == 3.1415926
  end

  test "expire old cache item" do
    assert 5 in @full_storage.expiry
    new_storage = CacheStorage.put(@full_storage, 6, "six")
    refute 5 in new_storage.expiry
  end
end
