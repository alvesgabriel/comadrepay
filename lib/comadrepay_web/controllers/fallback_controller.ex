defmodule ComadrepayWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ComadrepayWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ComadrepayWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ComadrepayWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :email_password_wrong}) do
    body = Jason.encode!(%{errors: %{detail: "email or password wrong"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, body)
  end

  def call(conn, {:error, :already_reversaled}) do
    body = Jason.encode!(%{errors: %{detail: "transfer already reversaled"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, body)
  end

  def call(conn, {:error, :belong_user}) do
    body = Jason.encode!(%{errors: %{detail: "assets doesn't belong to user"}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, body)
  end
end
