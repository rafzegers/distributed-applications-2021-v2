defmodule FinishedTasksKafkaContext do
  alias KafkaEx.Protocol.Fetch.Message
  alias KafkaEx.Protocol.Produce.Request

  @topic "finished-tasks"

  @moduledoc """
  Documentation for `ChunkCreator`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ChunkCreator.hello()
      :world

  """
  def create_task_response_produce_message(uuid, result) do
    :world
  end

  def produce_message(messages) do
    for message <- messages do
      request = %{%Request{topic: @topic, required_acks: 1} | messages: [message]}
      KafkaEx.produce(request)
    end
  end

end
