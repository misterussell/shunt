defmodule Shunt.Repo do
  use Ecto.Repo,
    otp_app: :shunt,
    adapter: Ecto.Adapters.Postgres
end
