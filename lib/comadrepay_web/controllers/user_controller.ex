defmodule ComadrepayWeb.UserController do
  use ComadrepayWeb, :controller

  alias Comadrepay.Accounts
  alias Comadrepay.Accounts.User

  action_fallback ComadrepayWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user_resource = Guardian.Plug.current_resource(conn)

    if user_resource.id == id do
      user = Accounts.get_user!(id)

      with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
        render(conn, "show.json", user: user)
      end
    else
      {:error, :belong_user}
    end
  end

  def delete(conn, %{"id" => id}) do
    %{id: user_id} = Guardian.Plug.current_resource(conn)

    if user_id == id do
      user = Accounts.get_user!(id)

      with {:ok, %User{}} <- Accounts.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
    else
      {:error, :belong_user}
    end
  end

  def balance(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "balance.json", user: user)
  end

  def login(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.generate_user_api_token(user)

      conn
      |> render("login.json", %{user: user, token: token})
    else
      conn
      |> ComadrepayWeb.FallbackController.call({:error, :email_password_wrong})
    end
  end

  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)

    with {:ok, _} <- Comadrepay.Auth.Guardian.revoke(token) do
      conn
      |> put_status(:no_content)
      |> json(nil)
    end
  end
end
