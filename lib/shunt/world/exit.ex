defmodule Shunt.World.Exit do
  @moduledoc false

  @enforce_keys [:to]
  defstruct [
    :to,
    id: nil,
    requirements: [],
    tags: [],
    travel_text: nil
  ]
end
