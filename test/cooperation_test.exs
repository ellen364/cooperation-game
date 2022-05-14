defmodule CooperationTest do
  use ExUnit.Case
  doctest Cooperation

  test "greets the world" do
    assert Cooperation.hello() == :world
  end
end
