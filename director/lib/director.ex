defmodule Director do
  alias KafkaEx.Protocol.CreateTopics.TopicRequest
  alias KafkaEx.Protocol.Produce.Request

  @todo_task "todo-tasks"
  @finished_task "finished-tasks"
  @todo_chunks "todo-chunks"
  @finished_chunks "finished-chunks"
  
  @create_topic_req_todo_task %TopicRequest{topic: @todo_task, num_partitions: 2, replication_factor: 1}
  @create_topic_req_finished_task %TopicRequest{topic: @finished_task, num_partitions: 2, replication_factor: 1}
  @create_topic_req_todo_chunks %TopicRequest{topic: @todo_chunks, num_partitions: 2, replication_factor: 1}
  @create_topic_req_finished_chunks %TopicRequest{topic: @finished_chunks, num_partitions: 2, replication_factor: 1}

  @default_req %Request{
    topic: @topic,
    required_acks: 1
  }

  def create_topic() do
    KafkaEx.create_topics([
      @create_topic_req_todo_task, 
      @create_topic_req_finished_task,
      @create_topic_req_todo_chunks, 
      @create_topic_req_finished_chunks])
  end

  def delete_topic() do
    KafkaEx.delete_topics([@todo_task, @finished_task, @todo_chunks, @finished_chunks])
  end

  defp create_task(from, until, pair) do
    if ( DatabaseInteraction.CurrencyPairContext.get_pair_by_name(pair) == nil ) do
      IO.inspect("pair niet in db, genereer pair voor #{pair}")
      DatabaseInteraction.CurrencyPairContext.create_currency_pair(%{currency_pair: pair})
    end
    
    unix_from = DateTime.to_unix(from)
    unix_until = DateTime.to_unix(until)

    todo_task = %AssignmentMessages.TodoTask{task_operation: :ADD, currency_pair: pair, from_unix_ts: unix_from, until_unix_ts: unix_until, task_uuid: Ecto.UUID.generate}
    
    encoded_task = AssignmentMessages.encode_message!(todo_task)
    message = %KafkaEx.Protocol.Produce.Message{value: encoded_task}
    
    IO.inspect("maak message")
    
    request = %{%Request{topic: @todo_task, required_acks: 1} | messages: [message]}

    IO.inspect("request")
    IO.inspect(request)

    KafkaEx.produce(request)
  end

  def automatic_create_tasks() do

    pairs = Application.fetch_env!(:director, :pairs_to_clone)
    {_bla, from} = DateTime.from_unix(Application.fetch_env!(:director, :from))
    {_bla, until} = DateTime.from_unix(Application.fetch_env!(:director, :until))

    for pair <- pairs do
      IO.inspect("Create task for #{pair}")
      create_task(from, until, pair)
    end

  end
end
