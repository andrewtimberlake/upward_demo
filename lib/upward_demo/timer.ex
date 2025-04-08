defmodule UpwardDemo.Timer do
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__.Server, :start_link, []}
    }
  end

  def uptime() do
    GenServer.call(__MODULE__, :uptime)
  end

  defmodule Server do
    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, nil, name: UpwardDemo.Timer)
    end

    def init(_) do
      send(self(), :tick)
      {:ok, DateTime.utc_now()}
    end

    def handle_call(:uptime, _from, start_time) do
      {:reply, DateTime.diff(DateTime.utc_now(), start_time, :second), start_time}
    end

    def handle_info(:tick, start_time) do
      Process.send_after(self(), :tick, 1000)

      uptime = DateTime.diff(DateTime.utc_now(), start_time, :second)

      UpwardDemo.Web.Endpoint.broadcast("timer", "uptime", %{uptime: uptime})

      {:noreply, start_time}
    end
  end
end
