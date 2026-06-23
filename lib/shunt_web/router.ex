defmodule ShuntWeb.Router do
  use ShuntWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShuntWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShuntWeb do
    pipe_through :browser

    live "/", HubLive
    live "/map", MovementLive
    live "/skills/ghostwork", SkillsLive, :ghostwork
    live "/skills/chrome-meat", SkillsLive, :chrome_meat
    live "/skills/the-web", SkillsLive, :web
    live "/skills/street-alchemy", SkillsLive, :street_alchemy
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShuntWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shunt, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShuntWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
