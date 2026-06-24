defmodule Shunt.Events.Event do
  @moduledoc false

  @enforce_keys [:id, :title, :steps]
  defstruct [:id, :title, :description, :steps]
end
