defmodule ComadrepayWeb.Router do
  use ComadrepayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug Comadrepay.Auth.Pipeline
  end

  scope "/api", ComadrepayWeb do
    pipe_through :api

    post "/users", UserController, :create
    post "/login", UserController, :login
  end

  scope "/api", ComadrepayWeb do
    pipe_through :api_auth

    resources "/users", UserController, except: [:create, :new, :edit]

    scope "/accounts" do
      post "/transfer", TransferController, :transfer
      get "/transfer/:id", TransferController, :show
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: ComadrepayWeb.Telemetry
    end
  end
end
