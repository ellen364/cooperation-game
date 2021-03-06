defmodule Cooperation.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      {DynamicSupervisor, strategy: :one_for_one, name: Cooperation.GameSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Cooperation.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
