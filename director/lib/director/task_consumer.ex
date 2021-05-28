defmodule Director.TaskConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message
  #alias FictiveWebserver.FactorialResultWaiter

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do

      message = AssignmentMessages.TaskResponse.decode!(message)
      IO.inspect("MESSAGE ONTVANGEN")
      IO.inspect(message)

      if (message.task_result == :TASK_CONFLICT) do
        IO.puts("Er was een probleem")
      else
        IO.puts("Taak is successvol uitgevoerd.")
      end

    end

    {:async_commit, state}
  end
end
