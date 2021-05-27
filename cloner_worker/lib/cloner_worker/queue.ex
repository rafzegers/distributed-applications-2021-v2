defmodule ClonerWorker.Queue do
  use GenServer

  defstruct tasks: []

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  def init(_args), do: {:ok, %__MODULE__{}}


  def add_to_queue(task), do: GenServer.cast(__MODULE__, {:add_to_queue, task})

  def get_first_element(), do: GenServer.call(__MODULE__, {:get_first_element, :please})

  def handle_cast({:add_to_queue, task}, state = %__MODULE__{tasks: tasks}) do
    queue = tasks ++ [task]
    {:noreply, %__MODULE__{state | tasks: queue}}
  end

  def handle_call({:get_first_element, :please}, _from, state = %__MODULE__{tasks: tasks}) do
    
    first = List.first(tasks)
    queue = Enum.drop(state.tasks, 1)

    {:reply, List.first(tasks), %__MODULE__{state | tasks: queue}}
  end

end
