defmodule ClonerWorker.WorkerManager do
  use GenServer
  
  @def_workers []
  defstruct workers: @def_workers

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  
  def init(_args) do
    :timer.send_interval(1000, :assign_work)
    {:ok, %__MODULE__{}}
  end
  
  def add_task(task), do: ClonerWorker.Queue.add_to_queue(task)

  def add_worker(worker), do: GenServer.cast(__MODULE__, {:add_worker, worker})

  def handle_cast({:add_worker, worker}, state = %__MODULE__{workers: workers}) do
    workers_new = workers ++ [worker]
    {:noreply, %__MODULE__{state | workers: workers_new}}
  end

  def handle_info(:assign_work, %__MODULE__{workers: workers} = state) do
    worker_index = Enum.find_index(workers, fn worker -> worker.available == true end)
    if (worker_index != nil) do
      worker = Enum.at(workers, worker_index)
      task = ClonerWorker.Queue.get_first_element
      
      if (task != nil) do
        GenServer.cast(worker.pid, {:add_task, task})
        updated_workers = List.replace_at(workers, worker_index, %{pid: worker.pid, available: false})
        {:noreply, %__MODULE__{workers: updated_workers}}
      else
        IO.puts("no tasks in queue")
        {:noreply, %__MODULE__{workers: workers}}
      end
    else
      IO.puts("no workers available")
      {:noreply, %__MODULE__{workers: workers}}
    end
  end

end