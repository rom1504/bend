# First-request compiler attribution

Phase59 measures the unchanged Phase58 genuine B2 against pinned TypeScript on
Lexer and Evening. It changes diagnostic tools only. The
[report](../../../../implementation/phase59/README.md) explains results and the
[design](../../../../design/phase59/first-request-attribution.md) fixes scope.

- [Clean and first-window CPU/allocation commands](latency/README.md): private
  preparation, ordinary fresh-process compilation, complete output oracles.
- [Stage clock boundaries](stages/README.md): nested exclusive attribution in an
  insertion-only private driver; no production-driver edits.
- [Source-operation counters](counters/README.md): SCC-aware diagnostic B2 copy,
  separate cache preparation, exact uninstrumented output equality.
- [Profile ancestor attribution](analysis/README.md): saved-data replay only.
- [Preservation and raw publication](publication/README.md): unchanged compiler,
  historical campaign, installed release and protected working files.

Every target runs serially under one resource guard. Data analysis stays on CPU0;
targets use CPU3, 1 GiB Node heap, 2 GiB tree RSS, 4 GiB available-memory floor.
Use fresh outputs for replay and never mutate a consumed method or closed raw
campaign. The [verified raw capsule](artifacts/raw/README.md) preserves all 518
campaign files. Profiles, stage clocks and counters are diagnostic; their times must
not replace clean timing samples.
