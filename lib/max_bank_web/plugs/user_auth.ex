defmodule MaxBankWeb.UserAuth do
  alias MaxBankWeb.UserAuth.Guardian

  def encode_and_sign(user) do
    case Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {15, :minutes}) do
      {:ok, token, _claim} -> {:ok, token}
      error -> error
    end
  end
end
