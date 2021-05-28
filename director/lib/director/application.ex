defmodule Director.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  @consumer_group "finished-tasks-consumer-group"
  @topic "finished-tasks"

  def start(_type, _args) do
    consumer_group_opts = []
    gen_consumer_impl = Director.TaskConsumer
    topic_names = [@topic]

    children = [
      # Starts a worker by calling: Director.Worker.start_link(arg)
      # {Director.Worker, arg}
      {Director.Repo, []},
      supervisor(
        KafkaEx.ConsumerGroup,
        [gen_consumer_impl, @consumer_group, topic_names, consumer_group_opts]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Director.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
