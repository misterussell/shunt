defmodule Shunt.Content.Store do
  @moduledoc false
  use GenServer

  # TODO: define @sources as a list of {table :: atom(), content_dir :: String.t()}, per
  # priv/docs/architecture.md Section 4:
  #   {:npcs, "priv/content/npcs"}
  #   {:fencing_items, "priv/content/fencing"}
  #   {:raws, "priv/content/raws"}
  #   {:recipes, "priv/content/recipes"}
  #   {:heat_events, "priv/content/heat_events"}
  #   {:skill_trees, "priv/content/skills"}

  # TODO: implement start_link/1 and init/1 mirroring Shunt.Npcs.Store.init/1 today: for each
  # {table, dir} in @sources, :ets.new(table, [:set, :public, :named_table,
  # read_concurrency: true]), then for every *.exs file under Application.app_dir(:shunt, dir),
  # Code.eval_file/1 to get the item and :ets.insert one {item.key, item} entry - except for
  # the :skill_trees source, which loads a single file containing the whole tree list (not one
  # file per item, since it's one nested structure, not independently-keyed items); insert it
  # as a single {:skill_trees, the_list} entry so Shunt.Content.all(:skill_trees) returns that
  # list directly.

  # TODO: once this module is implemented and wired into lib/shunt/application.ex (replacing
  # the Shunt.Npcs.Store child), delete lib/shunt/npcs/store.ex and
  # test/shunt/npcs/store_test.exs - the :npcs source above covers the same content and this
  # module replaces it entirely. See the TODO left in lib/shunt/npcs/store.ex.
end
