defmodule ComadrepayWeb.UserControllerTest do
  use ComadrepayWeb.ConnCase

  import Comadrepay.AccountsFixtures

  alias Comadrepay.Accounts
  alias Comadrepay.Accounts.User

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(user_valid_attrs())
    user
  end

  setup %{conn: conn} do
    user = fixture(:user)
    token = Accounts.generate_user_api_token(user)

    conn = put_req_header(conn, "accept", "application/json")
    conn_auth = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: conn, conn_auth: conn_auth, user: user}
  end

  describe "POST /api/users" do
    test "renders user when data is valid", %{conn: conn} do
      user = user_valid_attrs()
      conn = post(conn, Routes.user_path(conn, :create), user: user)

      data = json_response(conn, 201)["data"]
      assert data["cpf"] == user.cpf
      assert data["email"] == user.email
      assert data["first_name"] == user.first_name
      assert data["last_name"] == user.last_name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: user_invalid_attrs())
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when balance is invalid", %{conn: conn} do
      user = Map.put(user_valid_attrs(), :balance, -1)

      conn = post(conn, Routes.user_path(conn, :create), user: user)
      assert json_response(conn, 422)["errors"] == %{"balance" => ["balance minimum is zero"]}
    end
  end

  describe "POST /api/login" do
    test "render token when login is valid", %{conn: conn, user: user} do
      login = %{email: user.email, password: user.password}
      conn = post(conn, Routes.user_path(conn, :login), login)
      token = json_response(conn, 200)["token"]
      assert {:ok, _} = Comadrepay.Auth.Guardian.decode_and_verify(token)
    end

    test "render errors when password is invalid", %{conn: conn, user: user} do
      login = %{email: "abc." <> user.email, password: "invalid password"}
      conn = post(conn, Routes.user_path(conn, :login), login)
      assert %{"errors" => %{"detail" => "email or password wrong"}} == json_response(conn, 400)
    end

    test "render errors when email is invalid", %{conn: conn, user: user} do
      login = %{email: "invalid@email.com", password: user.password}
      conn = post(conn, Routes.user_path(conn, :login), login)
      assert %{"errors" => %{"detail" => "email or password wrong"}} == json_response(conn, 400)
    end
  end

  describe "GET /api/users" do
    test "lists all users", %{conn_auth: conn_auth} do
      conn_auth = get(conn_auth, Routes.user_path(conn_auth, :index))
      assert json_response(conn_auth, 200)["data"] != []
    end
  end

  describe "PUT /api/users/:id" do
    test "renders user when data is valid", %{conn_auth: conn_auth, user: %User{id: id} = user} do
      user_updated = user_update_attrs()
      conn_auth = put(conn_auth, Routes.user_path(conn_auth, :update, user), user: user_updated)

      assert %{"id" => ^id} = json_response(conn_auth, 200)["data"]

      conn_auth = get(conn_auth, Routes.user_path(conn_auth, :show, id))

      data = json_response(conn_auth, 200)["data"]
      assert data["cpf"] == user_updated.cpf
      assert data["email"] == user_updated.email
      assert data["first_name"] == user_updated.first_name
      assert data["last_name"] == user_updated.last_name
    end

    test "renders errors when data is invalid", %{conn_auth: conn_auth, user: user} do
      conn_auth =
        put(conn_auth, Routes.user_path(conn_auth, :update, user), user: user_invalid_attrs())

      assert json_response(conn_auth, 422)["errors"] != %{}
    end
  end

  describe "DELETE /api/users/:id" do
    test "deletes chosen user", %{conn_auth: conn_auth, user: user} do
      conn_auth = delete(conn_auth, Routes.user_path(conn_auth, :delete, user))
      assert response(conn_auth, 204)

      assert_error_sent 404, fn ->
        get(conn_auth, Routes.user_path(conn_auth, :show, user))
      end
    end
  end

  describe "DELETE /api/logout" do
    test "renders logout when data is valid", %{conn_auth: conn_auth} do
      conn_auth = delete(conn_auth, Routes.user_path(conn_auth, :logout))

      data = json_response(conn_auth, 204)
      assert is_nil(data)
    end
  end

  describe "GET /api/accounts/balance" do
    test "renders balance statement when data is valid", %{conn_auth: conn_auth, user: user} do
      conn_auth = get(conn_auth, Routes.user_path(conn_auth, :balance))

      assert data = json_response(conn_auth, 200)
      assert data["account_id"] == user.account.id
      assert data["balance"] == to_string(user.account.balance)
    end
  end
end
