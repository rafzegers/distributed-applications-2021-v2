defmodule ClonerWorker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  @consumer_group "todo-chunks-consumer-group"
  @topic "todo-chunks"

  def start(_type, _args) do

    consumer_group_opts = []
    gen_consumer_impl = ClonerWorker.TodoChunkConsumer
    topic_names = [@topic]

    children = [
      {ClonerWorker.Queue, []},
      {ClonerWorker.WorkerManager, []},
      {ClonerWorker.RateLimiter, []},
      {ClonerWorker.WorkerDynamicSupervisor, []},
      {Task, &ClonerWorker.WorkerDynamicSupervisor.start_workers/0},
      # Starts a worker by calling: ClonerWorker.Worker.start_link(arg)
      # {ClonerWorker.Worker, arg}
      supervisor(
        KafkaEx.ConsumerGroup,
        [gen_consumer_impl, @consumer_group, topic_names, consumer_group_opts]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChunkCreator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
