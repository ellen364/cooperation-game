defmodule Cooperation.Deck do
  alias __MODULE__

  @spec new() :: list
  def new() do
    number_cards = 1..80

    Stream.cycle([:win])
    |> Stream.take(5)
    |> Stream.concat(number_cards)
    |> Enum.shuffle()
  end

  def split_cards(to_deal, num_players, dealt \\ [])
  def split_cards(to_deal, 1, dealt), do: [to_deal | dealt]

  def split_cards(to_deal, num_players, dealt) do
    num_cards = cards_per_player(to_deal, num_players)
    {cards, remaining} = Enum.split(to_deal, num_cards)
    split_cards(remaining, num_players - 1, [cards | dealt])
  end

  defp cards_per_player(cards, num_players) do
    cards |> Enum.count() |> div(num_players)
  end
end
