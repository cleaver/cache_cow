defmodule CacheCowWeb.PageController do
  use CacheCowWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
