defmodule Director do
  alias KafkaEx.Protocol.CreateTopics.TopicRequest
  alias KafkaEx.Protocol.Produce.Request

  @todo_task "todo-tasks"
  @finished_task "finished-tasks"
  @create_topic_req_todo_task %TopicRequest{topic: @todo_task, num_partitions: 2, replication_factor: 1}
  @create_topic_req_finished_task %TopicRequest{topic: @finished_task, num_partitions: 2, replication_factor: 1}

  @default_req %Request{
    topic: @topic,
    required_acks: 1
  }

  def create_topic() do
    KafkaEx.create_topics([@create_topic_req_todo_task, @create_topic_req_finished_task])
  end

  def delete_topic() do
    KafkaEx.delete_topics([@todo_task, @finished_task])
  end

  defp create_tasks(unix_from, unix_until, pairs_to_clone) do
    :wip
  end

  def automatic_create_tasks() do
    :yeah
  end
end
