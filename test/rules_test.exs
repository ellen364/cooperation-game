defmodule Cooperation.RulesTest do
  use ExUnit.Case, async: true
  doctest Cooperation.Rules

  test "new rule" do
    assert Cooperation.Rules.new() == %Cooperation.Rules{}
  end

  test "add player" do
    assert Cooperation.Rules.check(Cooperation.Rules.new(), :add_player) ==
             {:ok, %Cooperation.Rules{state: :players_join, players: [:player_1], turn: nil}}
  end

  test "max players transitions to setup state" do
    initial_rules = %Cooperation.Rules{
      state: :players_join,
      players: [:player_1, :player_2, :player_3, :player_4],
      turn: nil
    }

    # TODO fix: new player not being added to players list
    assert Cooperation.Rules.check(initial_rules, :add_player) ==
             {:ok,
              %Cooperation.Rules{
                state: :setup,
                players: [:player_1, :player_2, :player_3, :player_4, :player_5],
                turn: nil
              }}
  end

  test "players join to setup" do
    assert Cooperation.Rules.check(Cooperation.Rules.new(), :start_game) ==
             {:ok, %Cooperation.Rules{state: :setup, players: [:player_1], turn: nil}}
  end

  test "setup to playing (player 1 chooses what to do)" do
    rules = %Cooperation.Rules{state: :setup, players: [:player_1], turn: nil}

    assert Cooperation.Rules.check(rules, :setup_done) ==
             {:ok, %Cooperation.Rules{state: :choose, players: [:player_1], turn: :player_1}}
  end

  test "choose to play card" do
    rules = %Cooperation.Rules{state: :choose, players: [:player_1], turn: :player_1}

    assert Cooperation.Rules.check(rules, {:play, :player_1}) ==
             {:ok, %Cooperation.Rules{state: :play, players: [:player_1], turn: :player_1}}
  end

  test "play card state to discard cards state" do
    rules = %Cooperation.Rules{state: :play, players: [:player_1], turn: :player_1}

    assert Cooperation.Rules.check(rules, {:played, :player_1}) ==
             {:ok, %Cooperation.Rules{state: :discard, players: [:player_1], turn: :player_1}}
  end

  test "discard cards state to draw cards state" do
    rules = %Cooperation.Rules{
      state: :discard,
      players: [:player_1, :player_2],
      turn: :player_1
    }

    assert Cooperation.Rules.check(rules, {:discarded, :player_1}) ==
             {:ok,
              %Cooperation.Rules{
                state: :draw,
                players: [:player_1, :player_2],
                turn: :player_1
              }}
  end

  # TODO fix syntax of test or main function (not sure which is broken)
  test "draw cards state to choose state (start of new player's turn)" do
    rules = %Cooperation.Rules{
      state: :draw,
      players: [:player_1, :player_2],
      turn: :player_1
    }

    assert Cooperation.Rules.check(rules, {:drawn, :player_1}) ==
             {:ok,
              %Cooperation.Rules{state: :choose, players: [:player_1, :player_2], turn: :player_2}}
  end

  test "other players can't act" do
    rules = %Cooperation.Rules{state: :play, players: [:player_1, :player_2], turn: :player_1}
    assert Cooperation.Rules.check(rules, {:play, :player_2}) == :error
  end

  test "can't skip steps (play card to next player choosing)" do
    rules = %Cooperation.Rules{state: :play, players: [:player_1, :player_2], turn: :player_1}
    assert Cooperation.Rules.check(rules, {:choose, :player_1}) == :error
  end
end
