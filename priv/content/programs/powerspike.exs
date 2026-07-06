# Windlass Ghostwork gear pilot — the :overload brute STARTER (loud, strong; answers fat :barrier
# cores). Skimmed at the Fitworks (see priv/content/locations/windlass/windlass_fitters_floor.exs).
# Numbers are the agreed design; tune for feel once the Windlass nodes are playable.
#
# TODO: finalize `name` + `text` against docs/SHUNT_LEXICON.md + docs/SHUNT_STYLE_GUIDE.md
#   (Collective/Fitworks-cut gear voice), then tune the profile for feel.
%{
  id: "powerspike",
  name: "Powerspike",
  action: :overload,
  progress: 6,
  trace: 6,
  on_weakness: %{progress: 11, trace: 4},
  text:
    "Dumps a raw current-spike straight into the lock. It opens — and every reader on the segment hears it open."
}
