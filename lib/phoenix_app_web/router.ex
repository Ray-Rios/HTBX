defmodule PhoenixAppWeb.Router do
  use PhoenixAppWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoenixAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :game_auth do
    plug PhoenixAppWeb.Plugs.GameAuthPlug
  end

  # --------------------
  # Public LiveViews
  # --------------------
  scope "/", PhoenixAppWeb do
  pipe_through :browser

  live_session :browser,
    on_mount: {PhoenixAppWeb.UserAuth, :default},
    session: %{},
    layout: {PhoenixAppWeb.Layouts, :app} do

    # Homepage is always public
    live "/", HomeLive, :index

    # Public auth routes
    live "/login", AuthLive, :login
    live "/register", AuthLive, :register

    # Public blog/shop/chat/etc.
    live "/blog", CMS.BlogLive, :index
    live "/blog/:slug", CMS.BlogLive, :show
    live "/shop", ShopLive, :index
    live "/shop/category/:slug", ShopLive, :category
    live "/shop/product/:id", ShopLive, :product
    live "/cart", CartLive, :index
    live "/checkout", CheckoutLive, :index
    live "/chat", ChatLive, :index
    live "/chat/:channel_id", ChatLive, :channel
    live "/quest", QuestLive, :index
    live "/unreal", UnrealLive, :index
    live "/desktop", DesktopLive, :index
    live "/terminal", TerminalLive, :index

  end
  end

  # --------------------
  # Authenticated LiveViews
  # --------------------
  scope "/", PhoenixAppWeb do
    pipe_through :browser

    live_session :authenticated,
      on_mount: {PhoenixAppWeb.UserAuth, :require_authenticated_user},
      layout: {PhoenixAppWeb.Layouts, :app} do

      live "/dashboard", DashboardLive, :index
      live "/profile", ProfileLive, :index
      live "/profile/security", ProfileLive, :security
      live "/profile/orders", ProfileLive, :orders
      live "/avatar", AvatarLive, :index
      live "/files", FilesLive, :index
      live "/files/upload", FilesLive, :upload
      
      # Game interfaces (require authentication)
      live "/game", GamePlayerLive, :index
    end
  end

  # --------------------
  # Auth Controller Actions (non-Live)
  # --------------------
  scope "/", PhoenixAppWeb do
    pipe_through :browser

    get "/auth/login_success", AuthController, :login_success
    get "/auth/logout", AuthController, :logout
    post "/auth/logout", AuthController, :logout
    post "/auth/2fa/verify", AuthController, :verify_2fa
    post "/auth/2fa/setup", AuthController, :setup_2fa
  end

  # --------------------
  # Admin LiveViews
  # --------------------
  scope "/admin", PhoenixAppWeb do
    pipe_through :browser

    live_session :admin,
      on_mount: {PhoenixAppWeb.UserAuth, :require_admin_user},
      layout: {PhoenixAppWeb.Layouts, :app} do

      live "/", CMS.AdminLive, :index
      live "/game", GameAdminLive, :index
      live "/game-cms", GameCmsAdminLive, :index
      live "/user-management", UserManagementLive, :index
    end
  end


  scope "/eqemu", PhoenixAppWeb do
    pipe_through [:browser, :require_authenticated_user]
  
    live "/admin", EqemuAdminLive, :index
    live "/player", EqemuPlayerLive, :index
    live "/server", EqemuServerLive, :index
  end


  # --------------------
  # Game API
  # --------------------
  scope "/api/game", PhoenixAppWeb do
    pipe_through :api

    # Public game endpoints
    post "/register", Api.GameAuthController, :register
    post "/login", Api.GameAuthController, :login
    post "/auth", Api.GameAuthController, :authenticate
    post "/verify", Api.GameAuthController, :verify_token
    get "/leaderboard", Api.GameController, :leaderboard
    get "/stats", Api.GameController, :stats

    # Protected game routes (require authentication)
    pipe_through :game_auth

    # Player profile and stats
    get "/profile", Api.GameController, :profile
    
    # Game sessions
    post "/session/start", Api.GameController, :start_session
    put "/session/:id/update", Api.GameController, :update_session
    post "/session/:id/heartbeat", Api.GameController, :heartbeat
    
    # Game events
    post "/event", Api.GameController, :create_event
    
    # Admin-only endpoints
    get "/users", Api.GameAuthController, :list_users
  end

  # --------------------
  # Pixel Streaming API
  # --------------------
  scope "/api/pixel-streaming", PhoenixAppWeb do
    pipe_through :api

    # Public endpoints for pixel streaming service
    get "/status", Api.PixelStreamingController, :status
    get "/players", Api.PixelStreamingController, :players
    get "/game-data", Api.PixelStreamingController, :game_data
    
    # Admin endpoints (should be protected in production)
    get "/admin/stats", Api.PixelStreamingController, :admin_stats
    post "/admin/broadcast", Api.PixelStreamingController, :broadcast_message
    post "/admin/kick/:player_id", Api.PixelStreamingController, :kick_player
  end

  # --------------------
  # GraphQL API
  # --------------------
  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: PhoenixAppWeb.Schema

    if Mix.env() == :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: PhoenixAppWeb.Schema,
        interface: :simple
    end
  end
end
