defmodule ComadrepayWeb.UserView do
  use ComadrepayWeb, :view
  alias ComadrepayWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      cpf: user.cpf
    }
  end

  def render("login.json", %{user: user, token: token}) do
    Map.put(render_one(user, UserView, "user.json"), :token, token)
  end

  def render("balance.json", %{user: user}) do
    %{
      account_id: user.account.id,
      balance: user.account.balance
    }
  end
end
