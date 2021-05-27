defmodule ChunkCreator.TodoTaskConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message
  alias KafkaEx.Protocol.Produce.Request
  # alias KafkaEx.Protocol.Produce.Message

  @todo_task "todo-tasks"
  @finished_task "finished-tasks"
  @todo_chunks "todo-chunks"
  @finished_chunks "finished-chunks"

  # note - messages are delivered in batches
  def handle_message_set(message_set, state) do
    # Logger.debug(fn -> "#{inspect(self())}/message: " <> inspect(message_set) end)

    for %Message{value: message} <- message_set do
      #BLABLA BERICHT ONTVANGEN

      task = AssignmentMessages.TodoTask.decode!(message)
      
      {_bla, utc_from} = DateTime.from_unix(task.from_unix_ts)
      {_bla, utc_until} = DateTime.from_unix(task.until_unix_ts)

      if (overlap(task.currency_pair, utc_from, utc_until)) do
        # send :TASK_CONFLICT to director
        finished_task = %AssignmentMessages.TaskResponse{task_result: :TASK_CONFLICT, todo_task_uuid: task.task_uuid}
        encoded_task = AssignmentMessages.encode_message!(finished_task)
        message = %KafkaEx.Protocol.Produce.Message{value: encoded_task}
        
        request = %{%Request{topic: @finished_task, required_acks: 1} | messages: [message]}
        IO.inspect("overlap")

        KafkaEx.produce(request)
      else
        # Geen overlap
        max_window_size_in_sec = Application.fetch_env!(:chunk_creator, :max_window_size_in_sec)
        pair_db = DatabaseInteraction.CurrencyPairContext.get_pair_by_name(task.currency_pair)
        
        # chunks kan via dbInteractions maken :p
        chunks_db = DatabaseInteraction.TaskStatusContext.generate_chunk_windows(task.from_unix_ts, task.until_unix_ts, max_window_size_in_sec)
        
        # maak task
        {:ok, task_db} = DatabaseInteraction.TaskStatusContext.create_full_task( %{from: utc_from, until: utc_until, uuid: task.task_uuid}, pair_db, chunks_db)
        
        for chunk <- chunks_db do
          # send chucks to cloner worker
          todo_chunk = %AssignmentMessages.TodoChunk{currency_pair: task.currency_pair, from_unix_ts: DateTime.to_unix(chunk.from), until_unix_ts: DateTime.to_unix(chunk.until), task_dbid: task_db.task_status.id}
          encoded_chunk = AssignmentMessages.encode_message!(todo_chunk)
          message = %KafkaEx.Protocol.Produce.Message{value: encoded_chunk}
          
          request = %{%Request{topic: @todo_chunks, required_acks: 1} | messages: [message]}
          IO.inspect("send chunk")
          
          KafkaEx.produce(request)
        end 
      end

    end

    {:async_commit, state}
  end

  defp overlap(pair, from, until) do
    task_statuses = DatabaseInteraction.TaskStatusContext.list_task_status()
    loaded_associations = Map.values(Enum.reduce(task_statuses, %{}, fn task_status, acc -> Map.put(acc, task_status.id, DatabaseInteraction.TaskStatusContext.load_association(task_status, [:currency_pair])) end))
    task = Enum.find(loaded_associations, fn x -> x.currency_pair.currency_pair == pair end)

    if task == nil do
      false
    else
      if ( from <= task.until && from >= task.from ) || ( until <= task.until && until >= task.from ) do
        true
      else
        false
      end
    end
  end
end