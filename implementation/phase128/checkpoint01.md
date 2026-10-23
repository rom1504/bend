# Phase128 first checkpoint: ownership work is removable

This is an experimental checkpoint, not native qualification or a new selected
compiler. Phase126 and Phase125 qualified images remain available.

## Measured results

On the unchanged, independently checked Phase127 name-search kernel:

| Producer | Five-run median | Relative to upstream |
|---|---:|---:|
| Parent QBE, same additive runtime | 1.495623s | 14.678x |
| Scalar borrowed observers | 0.830423s | 8.150x |
| Borrowed scalar helper composition | 0.764804s | 7.506x |
| Pinned upstream C/Clang | 0.101891s | 1x |

The composition removes 48.86% of parent runtime on this kernel. These are
generated-program measurements of an extracted real compiler computation,
not whole-compiler throughput or the broad benchmark geometric mean.

The first scalar-only candidate's separate counters show constructor takes
55,924,305 -> 4,617,945 (91.74% fewer), destruction entries
66,530,802 -> 22,687,307 (65.90% fewer). Allocation/free counts remain exactly
63,613 each; dispatch remains187, frames and register clearing remain zero.
Thus the gain removes ownership traffic rather than allocation or scheduling.
Clean acceptance timings exclude diagnostic instrumentation. The short new
sample captures have zero loss but fewer than500 samples individually and are
not accepted for quantitative CPU attribution; event counts remain valid.

The scalar candidate passes61 finite interface/admission predicates and22
ordinary output lines covering shared/unique/mixed roots, aliases, Unicode and
shared descendants. The helper-composition version also passes the ordinary
controls and both checked request/final verifiers. Its new negative interface
controls and broad/native qualification remain work in progress.

## A useful negative result

Skipping late flat candidates with an already-ready exact symbol preserves
complete Map QBE bytes, but three paired cold hosted requests show only
20.9051s -> 20.6092s (1.42%); the integrated stage is15.9901s ->15.9078s (0.51%).
This is too small to establish a worthwhile win. It skips one candidate family
but still repeats preparation and boxed lowering. The next experiment retains
the immutable **raw** candidate list across initial and late closure. Reusing
only admitted functions or SCC-transformed candidates would change semantics.

## Research and direction

[The research survey](../../research/compilers_architecture_and_techniques/phase128-fast-compilers.md)
finds the closest match in Lean's explicit borrowing and upstream Bend's own
borrow/lend analysis. Zig's compact identities suggest later amortized lookup;
its debug-backend speedups must not be imported as N1 runtime forecasts.

The next bounded tests are borrowing nested fields across verified calls,
building the reachability membership index once, and retaining immutable
request-local candidate preparation. A full native acquisition follows a useful
composition; repeated early full-image rebuilds would slow discovery.

All evidence paths, commands, frozen source identities and rejected acquisitions
are retained under `selfhost/build/phase128`, `phase111/p128-*` and
`phase118/p128-*`. A repository evidence archive will accompany the final report.
Storage recovery preserved all paths/bytes for303 exact duplicate historical
artifacts and retained split archives while removing redundant joined copies,
recovering approximately1.23GB before large compiler acquisition.
