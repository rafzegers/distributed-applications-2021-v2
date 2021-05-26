defmodule ChunkCreator.CompletedChunksConsumer do
  use KafkaEx.GenConsumer
  require Logger
  require IEx

  alias KafkaEx.Protocol.Fetch.Message
  alias KafkaEx.Protocol.Produce.Request
  # alias KafkaEx.Protocol.Produce.Message

  @topic "todo-tasks"



end


