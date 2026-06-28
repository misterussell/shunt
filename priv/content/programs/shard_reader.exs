%{
  id: "shard_reader",
  name: "Shard Reader",
  action: :decrypt,
  progress: 3,
  trace: 2,
  on_weakness: %{progress: 7, trace: 1},
  text: "Works an encrypted shard one patient pass at a time. Slow going, but it barely stirs the log."
}
