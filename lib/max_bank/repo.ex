defmodule MaxBank.Repo do
  use Ecto.Repo,
    otp_app: :max_bank,
    adapter: Ecto.Adapters.Postgres
end
