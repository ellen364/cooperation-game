defmodule Cooperation.GameSupervisor do
  alias Cooperation.Game

  def start_game(name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Cooperation.Game, name: registry_tuple(name)}
    )
  end

  # def stop_game(public_id) do
  #   Supervisor.terminate_child(__MODULE__, get_process_id(public_id))
  # end

  def generate_name() do
    0..6
    |> Enum.map(fn _ -> Enum.random(?a..?z) end)
    |> to_string
  end

  def registry_tuple(name) do
    {:via, Registry, {Registry.Game, name}}
  end

  defp get_process_id(name) do
    name
    |> registry_tuple()
    |> GenServer.whereis()
  end
end
