defmodule CacheCowWeb.CacheControllerTest do
  use CacheCowWeb.ConnCase

  @create_attrs_1 [key: "1", value: "one"]
  @create_attrs_2 [key: "2", value: "two"]
  @create_attrs_3 [key: "3", value: "three"]
  @create_attrs_4 [key: "4", value: "four"]
  @create_attrs_5 [key: "5", value: "five"]
  @create_attrs_6 [key: "6", value: "six"]

  @update_attrs_1 [key: "1", value: "uno"]

  @invalid_attrs [foo: "bar", baz: "foo"]

  setup %{conn: conn} do
    CacheCow.CacheServer.clear()
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "puts key-value pair", %{conn: conn} do
    conn = post(conn, Routes.cache_path(conn, :create), @create_attrs_1)
    assert json_response(conn, 201)
    conn = get(conn, Routes.cache_path(conn, :show, "1"))
    assert json_response(conn, 200)["data"] == "one"
  end

  test "updates key-value pair", %{conn: conn} do
    conn = post(conn, Routes.cache_path(conn, :create), @create_attrs_1)
    conn = post(conn, Routes.cache_path(conn, :create), @update_attrs_1)
    assert json_response(conn, 201)
    conn = get(conn, Routes.cache_path(conn, :show, "1"))
    assert json_response(conn, 200)["data"] == "uno"
  end

  test "gives 404 for value not in cache", %{conn: conn} do
    conn = get(conn, Routes.cache_path(conn, :show, "zero"))
    assert json_response(conn, 404)["error"] == "not found"
  end

  test "gives 400 when data is invalid", %{conn: conn} do
    conn = post(conn, Routes.cache_path(conn, :create), @invalid_attrs)
    assert json_response(conn, 400)["error"] == "bad request"
  end

  test "deals with overflowed cache (more than five)", %{conn: conn} do
    conn
    |> post(Routes.cache_path(conn, :create), @create_attrs_1)
    |> post(Routes.cache_path(conn, :create), @create_attrs_2)
    |> post(Routes.cache_path(conn, :create), @create_attrs_3)
    |> post(Routes.cache_path(conn, :create), @create_attrs_4)
    |> post(Routes.cache_path(conn, :create), @create_attrs_5)

    # now overflow
    conn = post(conn, Routes.cache_path(conn, :create), @create_attrs_6)
    conn = get(conn, Routes.cache_path(conn, :show, "1"))
    assert json_response(conn, 404)["error"] == "not found"
  end
end
