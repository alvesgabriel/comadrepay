defmodule Comadrepay.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Comadrepay.Repo

  alias Comadrepay.Accounts.User
  alias Comadrepay.Payment.Account

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
    |> Repo.preload(:account)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    Repo.get!(User, id)
    |> Repo.preload(:account)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, insert_user(attrs))
      |> Ecto.Multi.insert(:account, fn %{user: user} ->
        user
        |> Ecto.build_assoc(:account)
        |> Account.changeset(attrs)
      end)
      |> Comadrepay.Repo.transaction()

    case transaction do
      {:ok, result} ->
        user =
          result.user
          |> Repo.preload(:account)

        {:ok, user}

      {:error, :user, changeset, _} ->
        {:error, changeset}

      {:error, :account, changeset, _} ->
        {:error, changeset}
    end
  end

  defp insert_user(attrs) do
    %User{}
    |> User.changeset(attrs)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_user_by_email_and_password(email, password) do
    with %User{} = user <- Repo.get_by(User, email: email) |> Repo.preload(:account) do
      if Argon2.verify_pass(password, user.password_hash), do: user
    end
  end

  def generate_user_api_token(user) do
    {:ok, token, _claims} =
      Comadrepay.Auth.Guardian.encode_and_sign(user, %{}, token_type: :access)

    token
  end
end
