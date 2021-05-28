defmodule ClonerWorker.Worker do
  #use Tesla
  use GenServer
  alias KafkaEx.Protocol.Produce.Request

  @topic "finished-chunks"
  @base "https://poloniex.com/public"

  defstruct tasks: []
  def start_link(name: name), do: GenServer.start_link(__MODULE__, name, name: name)

  def init(_name), do: {:ok, %__MODULE__{}}

  def handle_cast({:add_task, task}, state) do
    new_tasks = state.tasks ++ [task]
    ClonerWorker.RateLimiter.register(self())
    {:noreply, %__MODULE__{tasks: new_tasks}}
  end

  def work(pid), do: GenServer.cast(pid, :work)

  def handle_cast(:work, state) do
    task = Enum.at(state.tasks, 0)
    new_tasks = Enum.drop(state.tasks, 1)

    url = "#{@base}?command=returnTradeHistory&currencyPair=#{task.currency_pair}&start=#{task.from_unix_ts}&end=#{task.until_unix_ts}"
    http_res = HTTPoison.get!(url)
    result = Jason.decode!(http_res.body)
    IO.inspect("HTTP CALL is uitgevoerd")

    entries = Enum.map(result, &reformatted_entry/1)
    
    
    if (length(result) < 1000) do
    # oke, minder dan 1000
      chunk = %AssignmentMessages.ClonedChunk{chunk_result: :COMPLETE, original_todo_chunk: task, entries: entries, possible_error_message: ""}
      encoded_chunk = AssignmentMessages.ClonedChunk.encode!(chunk)
      send_kafka_request(encoded_chunk)
    else
      chunk = %AssignmentMessages.ClonedChunk{chunk_result: :WINDOW_TOO_BIG, original_todo_chunk: task, entries: entries, possible_error_message: "More than 1000 elements"}
      encoded_chunk = AssignmentMessages.ClonedChunk.encode!(chunk)
      send_kafka_request(encoded_chunk)
    end

    ClonerWorker.WorkerManager.change_worker_status(self()) # pid
    {:noreply, %__MODULE__{tasks: new_tasks}}
  end

  defp send_kafka_request(encoded_cloned_chunk) do
    IO.puts("Send message on finished-chunks")
    message = %KafkaEx.Protocol.Produce.Message{value: encoded_cloned_chunk}
    request = %{%Request{topic: @topic, required_acks: 1} | messages: [message]}
    KafkaEx.produce(request)
  end

  defp parse_date(date) do
    formatted = String.replace("#{date}Z", " ", "T")
    {:ok, res, _} = DateTime.from_iso8601(formatted)
    DateTime.to_unix(res)
  end

  defp reformatted_entry(result) do
    %AssignmentMessages.ClonedEntry{
      type: String.to_atom(String.upcase(Map.get(result, "type"))),
      trade_id: Map.get(result, "tradeID"),
      date: parse_date(Map.get(result, "date")),
      rate: Map.get(result, "rate"),
      amount: Map.get(result, "amount"),
      total: Map.get(result, "total")
    }
  end

end

