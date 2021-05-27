defmodule ClonerWorker.RateLimiter do
  use GenServer

  @def_workers []
  defstruct workers: @def_workers

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  def init(args), do: {:ok, struct(__MODULE__, args)}

  def register(worker), do: GenServer.cast(__MODULE__, {:register, worker})

  def handle_cast({:register, worker}, state = %__MODULE__{workers: workers}) do
    workers_new = workers ++ [worker]
    {:noreply, %__MODULE__{state | workers: workers_new}}
  end

end