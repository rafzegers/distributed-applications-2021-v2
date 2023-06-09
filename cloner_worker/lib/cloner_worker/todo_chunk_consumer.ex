defmodule ClonerWorker.TodoChunkConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message
  #alias FictiveWebserver.FactorialResultWaiter

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do

      message = AssignmentMessages.TodoChunk.decode!(message)
      IO.inspect("JOW MESSAGE")
      IO.inspect(message)
      ClonerWorker.WorkerManager.add_task(message)
    end

    {:async_commit, state}
  end
end