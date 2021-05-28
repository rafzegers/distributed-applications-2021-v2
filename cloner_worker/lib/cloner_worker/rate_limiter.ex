defmodule ClonerWorker.RateLimiter do
  use GenServer

  @def_workers []
  @def_rate Application.fetch_env!(:cloner_worker, :default_rate)
  defstruct workers: @def_workers, rate: @def_rate

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  
  def init(_args) do 
    :timer.send_interval(1000, :do_work)
    {:ok, %__MODULE__{}}
  end

  def register(worker), do: GenServer.cast(__MODULE__, {:register, worker})

  def set_rate(rate) do
      GenServer.cast(__MODULE__, {:set_rate, rate})
  end

  def handle_cast({:register, worker}, state = %__MODULE__{workers: workers, rate: rate}) do
    workers_new = workers ++ [worker]
    {:noreply, %__MODULE__{state | workers: workers_new, rate: rate }}
  end

  def handle_info(:do_work, %__MODULE__{} = state) do
    
    Enum.each(1..state.rate, fn x ->
      worker = Enum.at(state.workers, x - 1)
      if (worker != nil) do
        ClonerWorker.Worker.work(worker)
      end
    end)
    
    workers_new = Enum.drop(state.workers, state.rate)
    {:noreply, %__MODULE__{rate: state.rate, workers: workers_new}}
  end

  def handle_cast({:set_rate, rate}, %__MODULE__{} = state) do
    {:noreply, %__MODULE__{rate: rate, workers: state.workers}}
  end

end