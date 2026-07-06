# Windlass Ghostwork gear pilot — the :cloak STARTER (quiet, slow; the clean way to down a :sentry
# before its bleed costs you). Skimmed at the Fitworks. Near-zero Trace is the whole point. Numbers
# are the agreed design; tune for feel.
#
# TODO: finalize `name` + `text` against docs/SHUNT_LEXICON.md + docs/SHUNT_STYLE_GUIDE.md, then tune.
%{
  id: "dampener",
  name: "Dampener",
  action: :cloak,
  progress: 3,
  trace: 1,
  on_weakness: %{progress: 6, trace: 1},
  text:
    "Folds your signal down under the watchdog's noise floor. Slow work, but the log barely stirs."
}
