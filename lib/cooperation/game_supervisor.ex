defmodule Cooperation.GameSupervisor do
  use Supervisor
  alias Cooperation.Game

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([Game], strategy: :simple_one_for_one)
  end

  # TODO when should the public ID be generated? (Currently passed to start game, meaning it must be generated earlier.)
  def start_game(public_id) do
    Supervisor.start_child(__MODULE__, [public_id])
  end

  # TODO investigate warnings about Supervisor being deprecated
  def stop_game(public_id) do
    Supervisor.terminate_child(__MODULE__, get_process_id(public_id))
  end

  def generate_public_id() do
    0..6
    |> Enum.map(fn _ -> Enum.random(?a..?z) end)
    |> to_string
  end

  defp get_process_id(public_id) do
    public_id
    |> Game.registry_tuple()
    |> GenServer.whereis()
  end
end
