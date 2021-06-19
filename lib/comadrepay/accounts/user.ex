defmodule Comadrepay.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :cpf, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :cpf, :password, :password_confirmation])
    |> validate_required([
      :email,
      :first_name,
      :last_name,
      :cpf,
      :password,
      :password_confirmation
    ])
    |> validate_cpf()
    |> validate_email()
    |> validate_password()
  end

  defp validate_cpf(%Ecto.Changeset{} = changeset) do
    changeset
    |> CPF.Ecto.Changeset.validate_cpf(:cpf)
    |> Ecto.Changeset.prepare_changes(fn changeset ->
      if cpf = Ecto.Changeset.get_change(changeset, :cpf) do
        str_cpf = cpf |> CPF.parse!() |> CPF.format()
        Ecto.Changeset.put_change(changeset, :cpf, str_cpf)
      else
        changeset
      end
    end)
    |> unique_constraint(:cpf, message: "cpf already registered")
  end

  defp validate_email(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_format(:email, ~r/^[\w\.]+@\w+(\.\w+){1,2}$/, message: "email format invalid")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email, message: "email already registered")
  end

  defp validate_password(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_length(:password, min: 8, max: 128, message: "password length between 8 and 128")
    |> validate_confirmation(:password, message: "password is not equal")
    |> hash_password()
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp hash_password(changeset), do: changeset
end
