# Reading the retained evidence

`profiles.tar.gz` contains `INVENTORY.json`, with a SHA256 for every member.
Its paths are repository-relative; paths inside original receipts preserve the
actual execution environment. Extract into a separate directory for inspection.
The archive receipt verifies all1,797 payload files after compression.

Unless noted otherwise, the following paths are under `selfhost/build/phase127`.

| Question | Authoritative retained evidence |
|---|---|
| How much native compiler time did the same-source repair save? | `live-bank-paired01/report.json`, `live-bank-comparison02.json` |
| Does the result transfer to the full compiler source? | `full-clean02/report.json`; one clean pair, not repeated statistical qualification |
| Did compiler instructions change? | `live-bank-full-comparison01.json`, `machine-identity02.json` |
| Which runtime operations changed? | `live-bank-event-comparison01.json`, `events01`, `live-bank-diagnostic01` |
| Where did the old libc fill happen? | `physical-attribution02`, `physical02`, `libc-unwind01/table.json` |
| What remains hot at full scale? | `full-physical01`, `full-profile01`, their `*-attribution` summaries, `full-comparison01.json` |
| Does the computation mix change during compilation? | `full-timeline01/timeline.json` and `timeline.md` |
| Is native lowering repeated on Map? | `repeated-work01.json`; counts are not inclusive stage durations |
| How much does prepared Base already save? | `cache-live01/report.json`; same binary and output, only preparation mode differs |
| Does profiling work on ordinary programs? | `programs02/run01`, `programs02/comparison02.json`, `refresh-survey01` |
| Does the repair help ordinary tree code? | `tree-live-bank01`, `tree-live-bank-comparison01.json`, `tree-machine-identity01.json` |
| Does a small real compiler kernel reproduce the ownership cost? | `name-search-profile01` clean/events, `name-search-profile02` accepted samples, `name-search-comparison02.json`, `name-search-attribution02` |
| What did upstream emit for that kernel? | `name-search-upstream01/source.1.c` and its checked acquisition receipt; QBE is in `selfhost/build/phase118/p127-name-search-emit03/compiler-name-search.ssa` |
| Are counter hooks checked independently? | `runtime-control01`, `runtime-drop-control02`; read the original failed expectation too |
| What did acquisition and failures cost? | `*-guard/process.json`, final report's `research-cost.json` and `figures/data.json` |

## Evidence that must not become a successful result

- `name-search-profile01` CPU captures all have timer overruns. Their clean
  timing and event runs are valid; their CPU percentages are excluded. The
  successful repeat uses8/13ms. Even there upstream's38 samples remain below
  the quantitative threshold. Counts, loss gates and workload identity are
  separate checks.
- `live-bank-comparison01.json` predates the explicit separation of context-only
  and counter-enabled overhead. Use `live-bank-comparison02.json` for final
  diagnostic timing. Do not mix those distributions.
- `followup01/machine-identity.json` is the initial ad hoc section inspection
  that treated ELF NOBITS as file data. `machine-identity02.json` is the corrected
  full-compiler comparison. Both remain for transparency.
- `runtime-drop-control01` failed its initial hand-derived count expectation.
  The corrected expectation traces the extra RC wrapper explicitly; it is not
  presented as an independent blind prediction.
- `name-search-preparation01/02/03` retain the incomplete source extraction and
  rejected scaffolds. The executed final source has SHA256
  `c599109a40883b3136fc0d0e5c56243e3a1046f0a54d3c1dcb7f9be8fbd20b1b`.
- Two API acquisition guards stop at2GiB; the successful checked acquisition
  uses4GiB. No killed job is treated as an OOM crash or completed acquisition.
- `report-figures01` preserves data for an early figure based on individual dispatch FIDs.
  The final committed figure aggregates all FIDs belonging to each lowered
  owner. Raw attribution remains available for either view.

Individual short samples can fail their own minimum-count gate while compatible
zero-loss captures pass a pooled threshold. Pooling never admits loss,
incompatible arguments/binaries, or inadequate thread coverage. The final
comparison reports retain the reason for every exclusion.

Full native executables, runtime objects and99.5MB compiler QBE products are not
included in this capsule. Their exact hashes, source/runtime origins and checked
rebuild commands are retained. The archive supports independent inspection of
the observations and bounded emitted code; it is not a self-contained portable
compiler distribution.
