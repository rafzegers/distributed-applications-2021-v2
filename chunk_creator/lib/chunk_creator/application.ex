defmodule ChunkCreator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  @consumer_group "todo-tasks-consumer-group"
  @topic "todo-tasks"

  def start(_type, _args) do

    consumer_group_opts = []
    gen_consumer_impl = ChunkCreator.TodoTaskConsumer
    topic_names = [@topic]

    children = [
      {ChunkCreator.Repo, []},
      # Starts a worker by calling: ChunkCreator.Worker.start_link(arg)
      # {ChunkCreator.Worker, arg}
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
