# Windlass Ghostwork gear pilot — the :cloak UPGRADE (the anti-sentry weapon: big on_weakness at
# ~zero Trace). Loot: dropped by windlass_skim_registry's watch_ring layer (crack->loot). Numbers are
# the agreed design; tune for feel.
#
# TODO: tune the profile for feel once the Windlass district is playable.
%{
  id: "nullsleeve",
  name: "Nullsleeve",
  action: :cloak,
  progress: 4,
  trace: 1,
  on_weakness: %{progress: 9, trace: 1},
  text:
    "Sleeves the whole handshake in dead air. A read a watchdog is trained on simply never happened — and it never raises its head."
}
