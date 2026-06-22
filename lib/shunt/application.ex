defmodule Shunt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShuntWeb.Telemetry,
      Shunt.Repo,
      {DNSCluster, query: Application.get_env(:shunt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shunt.PubSub},
      {Registry, keys: :unique, name: Shunt.Players.Registry},
      {DynamicSupervisor, name: Shunt.Players.Supervisor, strategy: :one_for_one},
      Shunt.Content.Store,
      # Start to serve requests, typically the last entry
      ShuntWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shunt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShuntWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
