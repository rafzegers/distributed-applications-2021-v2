defmodule ChunkCreator.TodoTaskConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message
  alias KafkaEx.Protocol.Produce.Request
  # alias KafkaEx.Protocol.Produce.Message

  @topic "todo-tasks"

  # note - messages are delivered in batches
  def handle_message_set(message_set, state) do
    # Logger.debug(fn -> "#{inspect(self())}/message: " <> inspect(message_set) end)

    for %Message{value: message} <- message_set do
      #BLABLA BERICHT ONTVANGEN
      task = AssignmentMessages.TodoTask.decode!(message)
      IO.inspect(task)

    end

    {:async_commit, state}
  end

end


