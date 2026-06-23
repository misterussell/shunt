defmodule Shunt.World.Exit do
  @moduledoc false

  @enforce_keys [:to]
  defstruct [
    :to,
    requirements: [],
    tags: [],
    travel_text: nil
  ]
end
