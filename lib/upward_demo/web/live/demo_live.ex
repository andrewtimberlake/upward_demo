defmodule UpwardDemo.Web.DemoLive do
  use UpwardDemo.Web, :live_view

  def mount(_params, _session, socket) do
    UpwardDemo.Web.Endpoint.subscribe("global_counter")
    UpwardDemo.Web.Endpoint.subscribe("timer")

    socket
    |> assign(:version, Application.spec(:upward_demo, :vsn))
    |> assign(:count, 0)
    |> assign(:global_count, UpwardDemo.GlobalCounter.get_count())
    |> assign(:uptime, UpwardDemo.Timer.uptime())
    |> ok()
  end

  def handle_event("increment", _params, socket) do
    socket
    |> update(:count, &(&1 + 3))
    |> assign(:global_count, UpwardDemo.GlobalCounter.increment())
    |> noreply()
  end

  def handle_event("decrement", _params, socket) do
    socket
    |> update(:count, &(&1 - 3))
    |> assign(:global_count, UpwardDemo.GlobalCounter.decrement())
    |> noreply()
  end

  def handle_event("upgrade", _params, socket) do
    Task.async(fn ->
      Upward.upgrade() |> IO.inspect(label: "UPGRADE")
    end)
    |> Task.ignore()

    noreply(socket)
  end

  def handle_event("downgrade", _params, socket) do
    Task.async(fn ->
      Upward.downgrade() |> IO.inspect(label: "DOWNGRADE")
    end)
    |> Task.ignore()

    noreply(socket)
  end

  def handle_info(%{event: "update_count", payload: %{count: count}}, socket) do
    socket
    |> assign(:global_count, count)
    |> noreply()
  end

  def handle_info(%{event: "uptime", payload: %{uptime: uptime}}, socket) do
    socket
    |> assign(:uptime, uptime)
    |> noreply()
  end

  def handle_info(:code_changed, socket) do
    # Used to force a re-render of the page when the code changes
    noreply(socket)
  end

  def code_change(_vsn, socket, _extra) do
    send(self(), :code_changed)

    socket
    |> assign(:version, Application.spec(:upward_demo, :vsn))
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen w-screen justify-start items-center p-4 flex-col gap-4">
      <.header class="text-center">
        Upward Demo
        <:subtitle>
          <a
            href="https://hex.pm/packages/upward"
            target="_blank"
            class="underline"
            rel="noopener noreferrer"
          >
            Upward
          </a>
          is a library to help with hot-code upgrades in Elixir.
        </:subtitle>
      </.header>

      <div>
        <p>Installed version: {@version}</p>
        <.button phx-click="upgrade">Upgrade</.button>
        <.button phx-click="downgrade">Downgrade</.button>
      </div>

      <div class="flex flex-col items-center justify-center">
        <h2 class="text-2xl font-bold text-green-500">LiveView Counter</h2>
        <p class="text-sm text-base-content/70">Increments by 2</p>
        <div class="text-4xl font-bold">{@count}</div>
        <div>
          <.button phx-click="increment">+</.button>
          <.button phx-click="decrement">-</.button>
        </div>
      </div>

      <div class="flex flex-col items-center justify-center">
        <h2 class="text-2xl font-bold text-purple-500">Global Counter</h2>
        <p class="text-sm text-base-content/70">Increments by 2</p>
        <div class="text-4xl font-bold">{@global_count}</div>
      </div>

      <div class="flex flex-col items-center justify-center">
        <p class="text-sm text-base-content/70">Time since initial install</p>
        <div class="text-xl font-bold font-mono">{format_uptime(@uptime)}</div>
      </div>

      <div class="flex flex-col items-center justify-center">
        <a
          href="https://github.com/andrewtimberlake/upward_demo"
          class="flex items-center gap-2 btn"
          target="_blank"
          rel="noopener noreferrer"
        >
          <svg viewBox="0 0 24 24" aria-hidden="true" class="size-6 fill-slate-900">
            <path
              fill-rule="evenodd"
              clip-rule="evenodd"
              d="M12 2C6.477 2 2 6.463 2 11.97c0 4.404 2.865 8.14 6.839 9.458.5.092.682-.216.682-.48 0-.236-.008-.864-.013-1.695-2.782.602-3.369-1.337-3.369-1.337-.454-1.151-1.11-1.458-1.11-1.458-.908-.618.069-.606.069-.606 1.003.07 1.531 1.027 1.531 1.027.892 1.524 2.341 1.084 2.91.828.092-.643.35-1.083.636-1.332-2.22-.251-4.555-1.107-4.555-4.927 0-1.088.39-1.979 1.029-2.675-.103-.252-.446-1.266.098-2.638 0 0 .84-.268 2.75 1.022A9.607 9.607 0 0 1 12 6.82c.85.004 1.705.114 2.504.336 1.909-1.29 2.747-1.022 2.747-1.022.546 1.372.202 2.386.1 2.638.64.696 1.028 1.587 1.028 2.675 0 3.83-2.339 4.673-4.566 4.92.359.307.678.915.678 1.846 0 1.332-.012 2.407-.012 2.734 0 .267.18.577.688.48 3.97-1.32 6.833-5.054 6.833-9.458C22 6.463 17.522 2 12 2Z"
            >
            </path>
          </svg>
          Demo Source Code
        </a>
      </div>

      <div class="text-base-content/70">
        <h2 class="text-xl font-bold">Changelog</h2>
        <ul>
          <li>0.0.0 - Increment local liveview and global counter</li>
          <li>0.0.1 - Local counter increments by 2; heading changed to green</li>
          <li>0.0.2 - Global counter increments by 2; heading changed to purple</li>
          <li>0.0.3 - Local counter increments by 3; global counter increments by 4</li>
        </ul>
      </div>
    </div>
    """
  end

  defp format_uptime(uptime) do
    days = uptime |> div(86400)
    hours = uptime |> rem(86400) |> div(3600)
    minutes = uptime |> rem(3600) |> div(60)
    seconds = uptime |> rem(60)
    "#{days}d #{hours}h #{minutes}m #{seconds}s"
  end
end
