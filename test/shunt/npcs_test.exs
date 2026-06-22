defmodule Shunt.NpcsTest do
  use ExUnit.Case, async: true

  alias Shunt.Npcs

  # TODO: describe "list/0" — assert it returns 5 npcs, sorted by :name ascending
  # (assert Enum.map(Npcs.list(), & &1.name) == Enum.sort(Enum.map(Npcs.list(), & &1.name)))

  # TODO: describe "get!/1" — assert Npcs.get!("tally").name == "Tally", and assert
  # Npcs.get!("unknown") raises a RuntimeError (delegates straight to Store.fetch!/1)
end
