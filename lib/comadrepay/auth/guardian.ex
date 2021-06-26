defmodule Comadrepay.Auth.Guardian do
  use Guardian, otp_app: :comadrepay

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, "Unknown resource type"}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok, Comadrepay.Accounts.get_user!(id)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
