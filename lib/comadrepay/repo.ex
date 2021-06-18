defmodule Comadrepay.Repo do
  use Ecto.Repo,
    otp_app: :comadrepay,
    adapter: Ecto.Adapters.Postgres
end
