# Common preparation versus fixture lowering

This is an offline analysis of the pinned Phase127 N1 manifest and
`selfhost/build/phase127/owner-survey01/report.json`. No compiler target was run
for this note. Owner samples are diagnostic active-dispatch attribution, not
clean inclusive function timings.

## What the observed decoder does

All three requests read the same 75,064-byte Base and 1,100,924-byte prepared
carrier. The carrier contains 47,662 records and 884 strings. It reconstructs
checked Base products; it does not contain the fixture's source or lowered IR.

The native entry selects preparation in
[`p111_compile_source`](../../selfhost/tools/performance/phase111/entry.bend#L35).
Cache mode calls
[`p88_cache_prepare`](../../selfhost/tools/performance/phase88/base/entry-cache.bend#L762);
live mode calls `p86_prepare`. Both feed the same `p111_compile_prepared`,
`p86_plan`, native admission, lowering and independent final verifier.
[`p111_native_request`](../../selfhost/tools/performance/phase111/entry.bend#L59)
reads the carrier only in cache mode. Each process prepares Base again; this
entry has no prepare-only or repeat-with-prepared-state CLI mode.

[`p88_digits`](../../selfhost/tools/performance/phase88/base/decoder.bend#L47)
reads canonical newline-terminated decimal U32 values from a linked String.
Its checks preserve digit bounds, leading-zero rejection, ten-digit limits and
U32 overflow rejection. It returns a nested `P88Number{P88Cursor{...},...}`.
[`p88_number`](../../selfhost/tools/performance/phase88/base/decoder.bend#L99)
reconstructs a `P88State`, cursor and boxed word inside a `P88Step` for each
record field. These are preparation functions, not the benchmark lexer.

The diagnostic event counts establish invariant preparation work across
lexer, closures and Map, without subtracting noisy timings:

| Phase126 owner/event | Count in each of the three requests |
|---|---:|
| `p88_digits` dispatches | 3,376,728 |
| `p88_digits` allocation calls | 974,868 |
| `p88_digits` constructor-take calls | 1,087,899 |
| `p88_number` dispatches | 648,138 |
| `p88_number` allocation calls | 1,620,345 |

These are execution-site counts. They do not identify allocation creation
origins, prove inclusive CPU cost or account for all preparation work.
In particular, generic String/Bool/Array helpers may execute under their own
dispatch owners. Conversely, private synchronous helpers retain an outer owner.
Do not classify every `p88_` function as carrier decoding: `p88_string_eq`, for
example, is a separate shared string helper.

## Cheapest useful next controls

1. **Same fixture, same binary, cache versus live.** Keep all argv unchanged
   except the `cache`/`live` token in the frozen N1 manifest. Both modes accept
   the existing carrier and stamp argv positions; live ignores them. Require
   exact complete QBE stdout equality against the existing per-version oracle,
   unchanged stderr and exit status. Alternate clean executions. This measures
   the net difference between live preparation and carrier reading/decoding.
   It does not measure either preparation cost in isolation.
2. **Repeat that comparison on the existing shortest qualified fixture**
   (`coverage-closures-256` already has a whole-QBE oracle). Combine clean
   timing with the existing constant decoder-event counts. This avoids a new
   compiler acquisition and avoids inventing an unqualified minimal program.
3. **Optional empty-source rejection control.** A zero-byte fixture reaches
   `p86_plan` only after successful preparation and then refuses the missing
   Base import, before fixture lowering. Establish its exact error/status with
   an independent qualified oracle before timing. This measures preparation
   plus startup, input reading, error processing and seed destruction. It is
   useful as a diagnostic floor, not an exact preparation timer.

For the successful control, the invocation remains:

```text
N1 --threads 1 --gpu off -- phase111 ABS_FIXTURE ABS_BASE live ABS_CARRIER STAMP
```

Do not combine cache/live captures into one profile identity: their arguments
and computation differ. Report the deliberate ablation separately. Also do not
report `T(real)-T(empty)` as pure lowering time: parsing, checking, reachable
Base selection, destruction, allocator state and output all change.

The saved event reports already give the cheapest verified separation of
*work counts*. Cache/live exact-output controls add causal timing evidence.
Precise stage timing would need an explicit scoped timer or prepared-state
entry; the current CLI cannot provide it without a source change.

## Conditional headroom, not predicted speedups

The table sums disjoint owner samples, using period-weighted fractions of all
Phase126 diagnostic samples. Decimal means exactly `p88_digits`, `p88_digit`,
`p88_number`, `p88_u32`. Decoder means definitions in `base/decoder.bend`, not
every function with a Phase88 prefix.

| Workload | Samples | Decimal owners | Decoder owners | Speedup if decimal cost halves | Ceiling if decimal cost disappears |
|---|---:|---:|---:|---:|---:|
| lexer | 1,071 | 10.49% | 14.46% | 1.055× | 1.117× |
| Map churn | 1,695 | 6.45% | 9.00% | 1.033× | 1.069× |
| closures | 305 | 36.36% | 53.18% | 1.222× | 1.571× |

The last row is below the 500-sample reporting threshold and is directional
only. All columns are diagnostic fractions; applying them to clean execution
assumes instrumentation has not materially changed the distribution. The
formulas are `1/(1-f+f/s)` and `1/(1-f)`. They are conditional bounds on the
named observed buckets, not hard ceilings on all preparation, whose shared
helper work is not fully inclusive here. Current register-clear remediation
overlaps these buckets; its gain must not be added to them. Refresh afterward.

The strongest small follow-up is a checked decoder control: preserve all
canonical-number and graph-admission laws, then test whether scalar reader
state and virtual nested returns remove per-field reconstruction. The existing
standalone decoder controls include U32_MAX, leading zeros, overflow, graph
references and malformed carriers, so a small generated executable can falsify
this before another full N1 build. A general return/consumer fusion capability
would transfer beyond this codec; rewriting the carrier format immediately
would introduce a separate representation and authentication burden.

For larger requests, preparation alone cannot establish parity. The same
survey attributes 24.50% of lexer and 20.62% of Map samples to the disjoint set
`index_find`, `index_bucket`, `index_insert`, `String.order`, `String.eq`;
halving those observed buckets would imply 1.140× and 1.115× respectively.
Map additionally spends 10.19% under `nq_uses`/`nc_uses_term` owners. Those are
separate later hypotheses about repeated analysis and name lookup, requiring
their own source tracing and cheap ablation; no speedup is demonstrated here.
