defmodule UpwardDemo.GlobalCounter do
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__.Server, :start_link, []}
    }
  end

  def get_count() do
    GenServer.call(__MODULE__, :get_count)
  end

  def increment() do
    GenServer.call(__MODULE__, :increment)
  end

  def decrement() do
    GenServer.call(__MODULE__, :decrement)
  end

  defmodule Server do
    use GenServer
    @vsn 1

    def start_link() do
      GenServer.start_link(__MODULE__, 0, name: UpwardDemo.GlobalCounter)
    end

    def init(count) do
      {:ok, count}
    end

    def handle_call(:get_count, _from, count) do
      {:reply, count, count}
    end

    def handle_call(:increment, _from, count) do
      new_count = count + 1
      UpwardDemo.Web.Endpoint.broadcast("global_counter", "update_count", %{count: new_count})
      {:reply, new_count, new_count}
    end

    def handle_call(:decrement, _from, count) do
      new_count = count - 1
      UpwardDemo.Web.Endpoint.broadcast("global_counter", "update_count", %{count: new_count})
      {:reply, new_count, new_count}
    end
  end
end
