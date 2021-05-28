defmodule ChunkCreator.CompletedChunksConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message
  alias KafkaEx.Protocol.Produce.Request
  # alias KafkaEx.Protocol.Produce.Message

  @todo_tasks "todo-tasks"
  @finished_chunks "finished-chunks"

  def handle_message_set(message_set, state) do

    for %Message{value: message} <- message_set do
      message_decoded = AssignmentMessages.ClonedChunk.decode!(message)

      IO.puts("nieuw worker bericht")
      
      task_id = message_decoded.original_todo_chunk.task_dbid
      from = message_decoded.original_todo_chunk.from_unix_ts
      until = message_decoded.original_todo_chunk.until_unix_ts
      
      task = DatabaseInteraction.TaskStatusContext.get_by_id!(task_id)
      
      if (message_decoded.chunk_result == :COMPLETE) do
        task_remaining_chunk = DatabaseInteraction.TaskRemainingChunkContext.get_chunk_by(task_id, from, until)
        
        DatabaseInteraction.TaskRemainingChunkContext.mark_as_done(task_remaining_chunk)
        status = DatabaseInteraction.TaskStatusContext.task_status_complete?(task_id)
        
        if (elem(status, 0)) do # elem(status, 0)
          # Indie task complete
          response = %AssignmentMessages.TaskResponse{task_result: :COMPLETE, todo_task_uuid: task.uuid}
          encoded_response = AssignmentMessages.TaskResponse.encode!(response)
          message = %KafkaEx.Protocol.Produce.Message{value: encoded_response}
          request = %{%Request{topic: @finished_chunks, required_acks: 1} | messages: [message]}
          KafkaEx.produce(request)
          
          IO.puts("TASK IS COMPLETE")
        end
      else
      # verdeel in kleinere chunks
        chunks = Enum.map(DatabaseInteraction.TaskRemainingChunkContext.halve_chunk(task_id, from, until), fn x -> x end)
        for chunk <- chunks do
          todo_chunk = %AssignmentMessages.TodoChunk{currency_pair: task.currency_pair, from_unix_ts: DateTime.to_unix(chunk.from), until_unix_ts: DateTime.to_unix(chunk.until), task_dbid: task.task_status.id}
          encoded_chunk = AssignmentMessages.encode_message!(todo_chunk)
          message = %KafkaEx.Protocol.Produce.Message{value: encoded_chunk}
          request = %{%Request{topic: @todo_tasks, required_acks: 1} | messages: [message]}
          KafkaEx.produce(request)
        end
      end
    end
    {:async_commit, state}
  end



end