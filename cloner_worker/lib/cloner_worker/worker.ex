defmodule ClonerWorker.Worker do
  #use Tesla
  use GenServer

  @base "https://poloniex.com/public"

  defstruct tasks: []
  def start_link(name: n), do: GenServer.start_link(__MODULE__, n, name: n)

  def init(_name), do: {:ok, %__MODULE__{}}

  def handle_cast({:add_task, task}, state) do
    new_tasks = state.tasks ++ [task]
    
    IO.puts("WORKER IS WORKING")
    IO.inspect(task)

    # API call:
    url = "#{@base}?command=returnTradeHistory&currencyPair=#{task.currency_pair}&start=#{task.from_unix_ts}&end=#{task.until_unix_ts}"
    
    http_res = HTTPoison.get!(url)
    result = Jason.decode!(http_res.body)
    IO.inspect(result)

    {:noreply, %__MODULE__{tasks: new_tasks}}
  end
end

