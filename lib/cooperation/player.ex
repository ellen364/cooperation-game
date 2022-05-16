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

    player
    |> Map.update!(:hand, &(&1 ++ drawn))
    |> Map.put(:draw_pile, pile)

    # case Enum.count(drawn) < num_cards_wanted do
    #   true -> {:few, player}
    #   false -> {:ok, player}
    # end
  end

  # TODO let player pick the cards
  # can I just take a cards arg and `hand -- cards` ? What about checks?
  # Have to check because someone could manipulate the frontend to send non-existent cards and keep their whole hand
  def discard_cards(player, num_cards) do
    {discarded, new_hand} = Enum.split(player.hand, num_cards)

    player
    |> Map.update!(:discard_pile, &(&1 ++ discarded))
    |> Map.put(:hand, new_hand)
  end
end
