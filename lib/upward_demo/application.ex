defmodule UpwardDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UpwardDemo.Web.Telemetry,
      {DNSCluster, query: Application.get_env(:upward_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UpwardDemo.PubSub},
      # Start a worker by calling: UpwardDemo.Worker.start_link(arg)
      # {UpwardDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      UpwardDemo.Web.Endpoint,
      UpwardDemo.GlobalCounter,
      UpwardDemo.Timer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UpwardDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UpwardDemo.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
