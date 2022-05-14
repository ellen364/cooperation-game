defmodule Cooperation.Player do
  alias __MODULE__

  defstruct hand: [],
            draw_pile: [],
            discard_pile: []

  @spec new() :: %Player{}
  def new(), do: %Player{}

  @doc ~S"""
  Try to draw specified number of cards from the pile. If there aren't enough cards in the pile, draw all cards.

  ## Examples
    iex> Cooperation.DrawPile.draw_cards([56, :win, 12, 77], 2)
    {:ok, [56, :win], [12, 77]}

    iex> Cooperation.DrawPile.draw_cards([56], 3)
    {:few, [56], []}
  """
  # Maybe don't return status atom? Could let caller check the quantity and inform user.
  @spec draw_cards(%Player{}, pos_integer) :: {:ok | :few, %Player{}}
  def draw_cards(player, num_cards_wanted) do
    {drawn, pile} = Enum.split(player.draw_pile, num_cards_wanted)
    {_, player} = get_and_update_in(player, [:hand], &{&1, &1 ++ drawn})
    {_, player} = get_and_update_in(player, [:draw_pile], &{&1, pile})

    # case Enum.count(drawn) < num_cards_wanted do
    #   true -> {:few, player}
    #   false -> {:ok, player}
    # end
    player
  end

  # TODO let player pick the cards
  # can I just take a cards arg and `hand -- cards` ? What about checks?
  # Have to check because someone could manipulate the frontend to send non-existent cards and keep their whole hand
  def discard_cards(player, num_cards) do
    {discarded, new_hand} = Enum.split(player.hand, num_cards)
    {_, player} = get_and_update_in(player, [:discard_pile], &{&1, &1 ++ discarded})
    {_, player} = get_and_update_in(player, [:hand], &{&1, new_hand})
    player
  end

  # When passed a list of players, discard cards for the right player
  def discard_cards([] = _players, _id, _num_cards), do: []

  def discard_cards([player | tail] = _players, id, num_cards)
      when player.id == id do
    [discard_cards(player, num_cards) | discard_cards(tail, id, num_cards)]
  end

  def discard_cards([player | tail] = _players, id, num_cards) do
    [player | discard_cards(tail, id, num_cards)]
  end
end
