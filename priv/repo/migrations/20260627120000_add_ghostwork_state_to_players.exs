defmodule Shunt.Repo.Migrations.AddGhostworkStateToPlayers do
  use Ecto.Migration

  def change do
    # TODO: add the ghostwork_state column, mirroring AddWebLedgerToPlayers:
    #   alter table(:players) do
    #     add :ghostwork_state, :map, default: %{}, null: false
    #   end
    # Holds %{"mastery" => %{family => count}, "nodes" => %{node_id => %{"banked_layer" => n,
    # "hardened" => bool}}}. See priv/docs/SHUNT_ghostwork_v1.md "Player State".
  end
end
