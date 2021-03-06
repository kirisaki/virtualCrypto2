defmodule VirtualCryptoWeb.Router do
  use VirtualCryptoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug VirtualCryptoWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug VirtualCryptoWeb.ApiAuthPlug
  end

  # for human
  scope "/", VirtualCryptoWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/logout", LogoutController, :index

    get "/invite", OutgoingController, :bot
    get "/support", OutgoingController, :guild

    get "/callback/discord", WebAuthController, :discord_callback

    scope "/document" do
      get "/", DocumentController, :index
      get "/about", DocumentController, :about
      get "/commands", DocumentController, :commands
      get "/api", DocumentController, :api
    end

    # required auth
    scope "/" do
      pipe_through :browser_auth
      get "/me", MyPageController, :index
    end
  end

  scope "/oauth2", VirtualCryptoWeb.OAuth2 do
    scope "/authorize" do
      pipe_through :browser
      pipe_through :browser_auth
      get "/", AuthorizeController, :get
      post "/", AuthorizeController, :post
    end

    scope "/" do
      pipe_through :api
      post "/token", TokenController, :post

      scope "/clients" do
        pipe_through :api_auth
        get "/", ClientsController, :get
        post "/", ClientsController, :post

        scope "/@me" do
          get "/", ClientController, :get
          patch "/", ClientController, :patch
        end
      end
    end
  end

  scope "/", VirtualCryptoWeb do
    get "/sw.js", ServiceWorkerController, :index
    post "/token", WebAuthController, :token
  end

  scope "/api", VirtualCryptoWeb.Api do
    pipe_through :api
    post "/integrations/discord/interactions", InteractionsController, :index

    scope "/v1", V1 do
      scope "/" do
        pipe_through :api_auth

        get "/user/@me", UserController, :me
        get "/balance/@me", BalanceController, :balance
        get "/users/@me/claims", ClaimController, :me
        post "/users/@me/transactions", UserTransactionController, :post
      end

      get "/moneys", InfoController, :index
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
      pipe_through :browser
      #      pipe_through [:fetch_session, :protect_from_forgery, :browser]
      live_dashboard "/dashboard",
        ecto_repos: [VirtualCrypto.Repo],
        metrics: VirtualCryptoWeb.Telemetry
    end
  end
end
