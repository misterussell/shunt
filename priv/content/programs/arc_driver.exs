# Windlass Ghostwork gear pilot — the :overload UPGRADE (stronger, a touch quieter than powerspike).
# Loot: dropped by windlass_anchor_vault's vault subroutine (crack->loot), not sold. Numbers are the
# agreed design; tune for feel.
#
# TODO: finalize `name` + `text` against docs/SHUNT_LEXICON.md + docs/SHUNT_STYLE_GUIDE.md, then tune.
%{
  id: "arc_driver",
  name: "Arc Driver",
  action: :overload,
  progress: 8,
  trace: 5,
  on_weakness: %{progress: 13, trace: 3},
  text:
    "A shaped arc that walks the lock's own tolerances until it fails clean. Still loud — just loud on purpose, in one place."
}
