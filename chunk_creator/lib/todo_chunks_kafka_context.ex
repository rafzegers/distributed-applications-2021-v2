defmodule TodoChucksKafkaContext do
  alias KafkaEx.Protocol.Fetch.Message
  alias KafkaEx.Protocol.Produce.Request
  @topic "todo-chunks"
  @moduledoc """
  Documentation for `ChunkCreator`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ChunkCreator.hello()
      :world

  """
  def task_remaining_chunk_to_produce_message(taskRemainingChunk, currency_pair) do
    :world
  end

  def produce_message(messages) do
    for message <- messages do
      request = %{%Request{topic: @topic, required_acks: 1} | messages: [message]}
      KafkaEx.produce(request)
    end
  end

end
