defmodule MaxBankWeb.UserAuth do
  alias MaxBankWeb.UserAuth.Guardian

  def encode_and_sign(user) do
    case Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minutes}) do
      {:ok, token, _claim} -> {:ok, token}
      error -> error
    end
  end

  def decode_and_verify(token) do
    Guardian.decode_and_verify(token)
  end

  def revoke_current_token(conn) do
    case conn |> Guardian.Plug.current_token() |> Guardian.revoke() do
      {:ok, _claims} -> :ok
      error -> error
    end
  end
end
