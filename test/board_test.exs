defmodule Cooperation.BoardTest do
  use ExUnit.Case, async: true
  doctest Cooperation.Board

  test "play card" do
    assert Cooperation.Board.play_card([], 1, 1, 3) == {:ok, []}
  end
end
