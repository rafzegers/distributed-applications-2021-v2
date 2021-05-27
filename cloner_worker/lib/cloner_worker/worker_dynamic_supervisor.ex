defmodule ClonerWorker.WorkerDynamicSupervisor do
  use DynamicSupervisor

  def start_link(args \\ []), do: DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  def init(_args), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_workers() do
    n_workers = Application.get_env(:cloner_worker, :n_workers)

    for x <- 1..n_workers do
        spec = {ClonerWorker.Worker, [name: String.to_atom("#{x}")]}
        DynamicSupervisor.start_child(ClonerWorker.WorkerDynamicSupervisor, spec)
    end

    for children <- DynamicSupervisor.which_children(ClonerWorker.WorkerDynamicSupervisor) do
        {_, pid, _, _} = children
        ClonerWorker.WorkerManager.add_worker(%{pid: pid, available: true})
        IO.puts("started workers")
    end
  end

end