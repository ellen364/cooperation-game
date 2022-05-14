defmodule Cooperation.Rules do
  alias __MODULE__

  defstruct state: :players_join,
            players: [:player_1],
            turn: nil

  @spec new() :: %Rules{}
  def new(), do: %Rules{}

  # TODO spec suggests I'm using weird types?
  @spec check(%Rules{}, atom | {atom, any}) :: {:ok, %Rules{}} | :error
  def check(%Rules{state: :players_join} = state, :add_player) do
    # TODO add player to players list
    case max_players?(state) do
      false -> {:ok, state}
      true -> {:ok, %Rules{state | state: :setup}}
    end
  end

  def check(%Rules{state: :players_join} = state, :start_game) do
    {:ok, %Rules{state | state: :setup}}
  end

  def check(%Rules{state: :setup} = state, :setup_done) do
    {:ok, %Rules{state | state: :choose, turn: :player_1}}
  end

  def check(%Rules{state: :choose} = state, {:play, player}) do
    case players_turn?(state, player) do
      true -> {:ok, %Rules{state | state: :play}}
      false -> :error
    end
  end

  def check(%Rules{state: :choose} = state, {:discard, player}) do
    case players_turn?(state, player) do
      true -> {:ok, %Rules{state | state: :discard}}
      false -> :error
    end
  end

  # Am I missing a transition?
  def check(%Rules{state: :play} = state, {:played, player}) do
    # TODO what if board in win or lose state? Don't go to draw, go to :game_over
    case players_turn?(state, player) do
      true -> {:ok, %Rules{state | state: :discard}}
      false -> :error
    end
  end

  def check(%Rules{state: :discard} = state, {:discarded, player}) do
    case players_turn?(state, player) do
      true -> {:ok, %Rules{state | state: :draw}}
      false -> :error
    end
  end

  def check(%Rules{state: :draw} = state, {:drawn, player}) do
    case players_turn?(state, player) do
      true -> {:ok, %Rules{state | state: :choose, turn: next_player(state)}}
      false -> :error
    end
  end

  def check(_state, _action), do: :error

  @spec max_players?(%Rules{}) :: boolean
  defp max_players?(state) do
    players = Map.fetch!(state, :players)
    Enum.count(players) == 5
  end

  @spec players_turn?(%Rules{}, atom) :: boolean
  defp players_turn?(state, player) do
    player == state.turn
  end

  # TODO refactor
  @spec next_player(%Rules{}) :: atom
  defp next_player(state) do
    index = Enum.find_index(state.players, state.turn)
    end_index = Enum.count(state.players) - 1
    next_index = if index + 1 <= end_index, do: index + 1, else: 0
    Enum.at(state.players, next_index)
  end
end
