defmodule ClonerWorker.Worker do
  #use Tesla
  use GenServer

  defstruct tasks: []
  def start_link(name: n), do: GenServer.start_link(__MODULE__, n, name: n)

  def init(_name), do: {:ok, %__MODULE__{}}

  def handle_cast({:add_task, task}, state) do
    new_tasks = state.tasks ++ [task]
    
    IO.puts("WORKER IS WORKING")
    IO.inspect(task)
    {:noreply, %__MODULE__{tasks: new_tasks}}
  end
end

