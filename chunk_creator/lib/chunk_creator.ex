defmodule ChunkCreator do
  @moduledoc """
  Documentation for `ChunkCreator`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ChunkCreator.hello()
      :world

  """
  def hello do
    :world
  end

  def check_db(pair) do

    if ( DatabaseInteraction.CurrencyPairContext.get_pair_by_name(pair) != nil ) do
      IO.inspect("pair #{pair} GEVONDEN")
    end
    IO.inspect("checked DB for: #{pair}")
    
  end

end
