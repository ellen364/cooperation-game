defmodule Cooperation.Board do
  alias __MODULE__

  @doc ~S"""
  Create a new board.

  ## Examples
    iex> Cooperation.Board.new()
    [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
  """
  @spec new() :: list(nil)
  def new() do
    Stream.cycle([nil]) |> Enum.take(36)
  end

  @doc ~S"""

  ## Examples
    iex> Cooperation.Board.play_card()
  """
  @spec play_card(list, pos_integer, non_neg_integer, pos_integer) ::
          {:ok, list} | {:error, String.t()}
  def play_card(board, card, position, acceptable_cost) do
    # Create new board and check validity
    # Find cost of move and check acceptable
    {inserted?, board} = insert_card(board, card, position)
    cost = min_cost(board, position)

    cond do
      inserted? == :error -> {:error, "Already card in position"}
      not valid?(board) -> {:error, "Card wouldn't be in order"}
      cost > acceptable_cost -> {:error, "Cost too high"}
      # TODO add win condition? (or maybe better to do that elsewhere -- after each player's turn, check for win condition)
      true -> {:ok, board}
    end
  end

  @doc ~S"""
  Have the players won?
  (Cards must also be in ascending order. This is controlled at card insertion and can be assumed to be true.)

  ## Examples
    >iex Cooperation.Board.win?([1, 3, 4, 7, :win])
    true

    >iex Cooperation.Board.win?([1, 3, 4, 7, 8])
    false

    >iex Cooperation.Board.win?([1, nil, 4, 7, 8])
    false
  """
  @spec win?(list) :: boolean
  def win?(board) do
    :win in board and nil not in board
  end

  @doc """
  If the position is empty (nil) insert the card and return the new board. Otherwise return the old board.
  """
  @spec insert_card(list, pos_integer, non_neg_integer) :: {:ok | :error, list}
  defp insert_card(board, card, position) do
    case Enum.at(board, position) do
      nil -> {:ok, List.insert_at(board, position, card)}
      _ -> {:error, board}
    end
  end

  # TODO Test some of this logic via the public API (in board_tests.exs rather then doc tests as getting long)
  @doc """
  Checks whether the numbers on the board are in ascending order. Nils are ignored.

  ## Examples
    iex> Cooperation.Board.valid?([nil, nil, nil])
    true

    iex> Cooperation.Board.valid?([1, 2, 3, 4])
    true

    iex> Cooperation.Board.valid?([nil, 20, nil, 25])
    true

    iex> Cooperation.Board.valid?([98, 1, 2])
    false

    iex> Cooperation.Board.valid?([nil, nil, 86, nil, nil, 83])
    false
  """
  @spec valid?(list) :: boolean
  defp valid?(board) do
    board
    |> Enum.reject(&is_nil/1)
    |> ascending?()
    |> Enum.all?()
  end

  @doc """
  Checks whether numbers are in ascending order.
  (Simplify to "reverse list and compare"? Or is reduce much more efficient?)
  """
  @spec ascending?(list) :: [boolean]
  defp ascending?(board) do
    board
    # Cards begin at 1, so acc.prev can be initialised to 0
    |> Enum.reduce(%{prev: 0, result: []}, fn num, acc ->
      %{prev: num, result: [acc.prev < num | acc.result]}
    end)
    |> Map.get(:result)
  end

  @doc ~S"""

  ## Examples
      iex> Cooperation.Board.min_cost([nil, 50, nil], 1)
      0

      iex> Cooperation.Board.min_cost([1, 3, 6], 1)
      2

      iex> Cooperation.Board.min_cost([64, 67, 69, 70], 2)
      1

      iex> Cooperation.Board.min_cost([1, 2, nil, 82], 3)
      0

      iex> Cooperation.Board.min_cost([1, 2, nil, 82], 0)
      1
  """
  @spec min_cost(list, non_neg_integer) :: non_neg_integer
  defp min_cost(board, position) do
    card = Enum.at(board, position)
    # OK if index wraps around (e.g. -1) because diff will be much greater than next up or down
    prev_card = Enum.at(board, position - 1)
    next_card = Enum.at(board, position + 1)

    cost_a = cost(card, prev_card)
    cost_b = cost(card, next_card)
    min(cost_a, cost_b)
  end

  @doc """

  ## Examples
    iex> Cooperation.Board.cost(nil, nil)
    0

    iex> Cooperation.Board.cost(nil, 33)
    0

    iex> Cooperation.Board.cost(73, nil)
    0

    iex> Cooperation.Board.cost(27, 29)
    2

    iex> Cooperation.Board.cost(79, 78)
    1
  """
  @spec cost(pos_integer | nil, pos_integer | nil) :: non_neg_integer
  defp cost(nil, _card_b), do: 0
  defp cost(_card_a, nil), do: 0
  defp cost(card_a, card_b), do: abs(card_b - card_a)
end
