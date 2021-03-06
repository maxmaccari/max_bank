defmodule MaxBankWeb.UserAuth.EnsureAuthenticated do
  @moduledoc """
  Ensure the user is authenticated.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :max_bank,
    error_handler: MaxBankWeb.UserAuth.ErrorHandler,
    module: MaxBankWeb.UserAuth.Guardian

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
