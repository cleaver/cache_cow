defmodule CacheCowWeb.CacheController do
  use CacheCowWeb, :controller

  alias CacheCow.CacheServer

  @doc """
  POST /api/cache - put a key/value pair to the cache.
  """
  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, params) do
    case params do
      %{"key" => key, "value" => value} ->
        CacheServer.put(key, value)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, ~s({"message": "success"}))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, ~s({"error": "bad request"}))
    end
  end

  @doc """
  GET /api/cache/:key - get a value from cache by key.
  """
  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"key" => key}) do
    case CacheServer.get(key) do
      data when not is_nil(data) ->
        json(conn, %{data: data})

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, ~s({"error": "not found"}))
    end
  end

  @doc """
  DELETE /api/cache - clear the entire cache.
  """
  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _param) do
    CacheServer.clear()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ~s({"message": "cache cleared"}))
  end
end
