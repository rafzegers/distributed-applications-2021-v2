defmodule ChunkCreator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  @todo_tasks_consumer_group "todo-tasks-consumer-group"
  @todo_tasks "todo-tasks"
  @finished_chunks_consumer_group "finished-chunks-consumer-group"
  @finished_chunks "finished-chunks"

  def start(_type, _args) do

    consumer_group_opts = []
    todo_task_gen_consumer_impl = ChunkCreator.TodoTaskConsumer
    todo_task_topic_names = [@todo_tasks]

    finished_chunks_gen_consumer_impl = ChunkCreator.CompletedChunksConsumer
    finished_chunks_topic_names = [@finished_chunks]

    children = [
      {ChunkCreator.Repo, []},
      # Starts a worker by calling: ChunkCreator.Worker.start_link(arg)
      # {ChunkCreator.Worker, arg}
      %{
        id: TodoTasksConsumerGroup,
        start: {KafkaEx.ConsumerGroup, :start_link, [todo_task_gen_consumer_impl, @todo_tasks_consumer_group, todo_task_topic_names, consumer_group_opts]}
      },
      %{
        id: FinishedChunksConsumerGroup,
        start: {KafkaEx.ConsumerGroup, :start_link, [finished_chunks_gen_consumer_impl, @finished_chunks_consumer_group, finished_chunks_topic_names, consumer_group_opts]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChunkCreator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
