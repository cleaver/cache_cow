defmodule CacheCow.Repo do
  use Ecto.Repo,
    otp_app: :cache_cow,
    adapter: Ecto.Adapters.Postgres
end
