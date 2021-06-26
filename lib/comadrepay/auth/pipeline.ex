defmodule Comadrepay.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :comadrepay,
    module: Comadrepay.Auth.Guardian,
    error_handler: Comadrepay.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
