defmodule Cooperation.Game do
  use GenServer

  alias Cooperation.{Deck, Player, Rules}

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_) do
    # TODO should be game struct?
    {:ok, %{players: %{1 => Player.new()}, rules: Rules.new()}}
  end

  # TODO shouldn't allow > 5 players (bug in rules?)
  def handle_call(:add_player, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, :add_player) do
      game_state
      |> add_player
      |> update_rules(rules)
      |> reply(:ok)
    else
      :error -> {:reply, :error, game_state}
    end
  end

  # TODO after setup, transition to choose for 1st player
  # (Don't bother having a :setup state? Game handles it almost instantly)
  def handle_call(:start_game, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, :start_game) do
      game_state
      |> setup_draw_piles
      |> setup_hands
      |> update_rules(rules)
      |> reply(:ok)
    else
      :error -> {:reply, :error, game_state}
    end
  end

  def handle_call({:play, _player} = action, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, action) do
      game_state
      # |> play_card
      |> update_rules(rules)
      |> reply(:ok)
    else
      :error -> {:reply, :error, game_state}
    end
  end

  def handle_call({:discard, player} = action, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, action) do
      game_state
      # |> discard_cards(player_id, num_cards)
      |> update_rules(rules)
      |> reply(:ok)
    else
      :error -> {:reply, :error, game_state}
    end
  end

  def handle_call({:draw, _player} = action, _from, game_state) do
    with {:ok, rules} <- Rules.check(game_state.rules, action) do
      game_state
      # |> draw_cards(player_id, num_cards)
      |> update_rules(rules)
      |> reply(:ok)
    else
      :error -> {:reply, :error, game_state}
    end
  end

  defp reply(game_state, message) do
    {:reply, message, game_state}
  end

  def get_next_id(%{}), do: 0

  def get_next_id(players) do
    players |> Map.keys() |> Enum.max() |> Kernel.+(1)
  end

  defp update_rules(game_state, rules) do
    %{game_state | rules: rules}
  end

  defp add_player(game_state) do
    next_id = get_next_id(game_state.players)
    put_in(game_state, [:players, next_id], Player.new())
  end

  defp num_players(game_state) do
    Enum.count(game_state.players)
  end

  def setup_draw_piles(game_state) do
    num_players = num_players(game_state)

    cards = Deck.new() |> Deck.split_cards(num_players)

    players =
      game_state.players
      |> Enum.zip(cards)
      |> Map.new(fn {{key, player}, cards} -> {key, %{player | draw_pile: cards}} end)

    %{game_state | players: players}
  end

  def setup_hands(game_state) do
    # Guess I might be able to do this with get_and_update_in ? The help includes an example where each age gets updated
    players = Map.map(game_state.players, fn {_key, player} -> Player.draw_cards(player, 5) end)

    %{game_state | players: players}
  end

  def discard_cards(game_state, player_id, num_cards) do
    update_in(game_state, [:players, player_id], &Player.discard_cards(&1, num_cards))
  end

  def draw_cards(game_state, player_id, num_cards) do
    update_in(game_state, [:players, player_id], &Player.draw_cards(&1, num_cards))
  end
end
