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
    @vsn 3

    def start_link() do
      GenServer.start_link(__MODULE__, 0, name: UpwardDemo.GlobalCounter)
    end

    def init(count) do
      {:ok, {count, 4}}
    end

    def handle_call(:get_count, _from, {count, increment}) do
      {:reply, count, {count, increment}}
    end

    def handle_call(:increment, _from, {count, increment}) do
      new_count = count + increment
      UpwardDemo.Web.Endpoint.broadcast("global_counter", "update_count", %{count: new_count})
      {:reply, new_count, {new_count, increment}}
    end

    def handle_call(:decrement, _from, {count, increment}) do
      new_count = count - increment
      UpwardDemo.Web.Endpoint.broadcast("global_counter", "update_count", %{count: new_count})
      {:reply, new_count, {new_count, increment}}
    end

    # Down from 2 to 1
    def code_change({:down, 1}, {counter, _increment}, _extra) when is_integer(counter) do
      {:ok, counter}
    end

    # Up from 1 to 2
    def code_change(1, counter, _extra) when is_integer(counter) do
      {:ok, {counter, 2}}
    end

    # Down from 3 to 2
    def code_change({:down, 2}, {counter, _increment}, _extra) when is_integer(counter) do
      {:ok, {counter, 2}}
    end

    # Up from 2 to 3
    def code_change(2, {counter, _increment}, _extra) when is_integer(counter) do
      {:ok, {counter, 4}}
    end
  end
end
