# Runtime callers: valid one-frame capture, bounded attribution

The completed capture identifies **2,269 immediate runtime callers in 5,429
samples**, with zero overruns/loss and 99.338% main-thread/process CPU coverage.
The strongest newly localized operation is linked-string construction during
QBE rendering. It does **not** explain the full cold-build gap or establish a
100-second route.

[Compact data and exact input hashes](runtime-callers.json) accompany the
[run receipt](../../selfhost/build/phase171/runtime-callers-full01/report.json)
and [stage observation](../../selfhost/build/phase171/runtime-callers-full-stages01.json).
The diagnostic request took **175.011s wall / 174.970s CPU**, peaking at
788,916 KiB RSS. It emitted the exact **97,488,970-byte** S0 oracle, SHA256
`661b62664acdac83d12bc3192b5f9113a2bb946dd331433e64ca0452f6f83850`, with empty
stderr. This is compiler execution with diagnostic hooks, not a clean complete
build including QBE, assembly and linking. The retained diagnostic ELF is
unchanged; only the sampler's one-frame CFI table changed.

## What the extra frame resolves

These classes are disjoint and exhaust the full capture:

| Immediate caller result | Samples | Share of all samples |
|---|---:|---:|
| Generated compiler function | 966 | 17.79% |
| Runtime intermediary or other function | 1,303 | 24.00% |
| No caller supported by this CFI table | 3,160 | 58.21% |

All 2,269 eligible samples recovered a symbolized caller; no inferred symbol or
unsupported-frame guess was used. Of the 966 generated callers, only 99 carry
recorded lexical-owner metadata. The others still identify an exact generated
function symbol, but that is a narrower claim than authenticated source ancestry.
The existing emitter-owner contract remains a condition, not a new proof.

Separately, 1,800 samples land directly in generated compiler code. Selecting
**the generated leaf, otherwise its recovered generated caller**, identifies
2,766/5,429 samples (50.95%) without double counting. The other 2,663 remain
without an observed generated frame. Dispatch context is not added to either
total: it can remain stale across direct calls.

The largest recovered callers illustrate why the remaining distinction matters:

| Actual physical caller | Samples | Interpretation |
|---|---:|---|
| `p111_rt_sink` | 430 | Runtime intermediary; source caller still unknown |
| TRMC worker for `String.append` | 223 | Named generated function |
| `ctr_take.cold` | 204 | Runtime intermediary |
| `p125_rt_take2.cold` | 157 | Runtime intermediary |
| `p111_rt_take` | 97 | Runtime intermediary |
| `p125_rt_take4.cold` | 96 | Runtime intermediary |
| `span_fade` | 93 | Runtime intermediary |
| Direct `index_find` | 79 | Named generated function |

For example, 430 samples are `term_drop` called by `p111_rt_sink`; this does not
identify which compiler operation requested the drop. There is no second-frame
recovery, inclusive stack attribution, or allocation-count inference here.

## The concrete rendering finding

Across every emitted `String.append` variant, **273 disjoint samples (5.03%)**
land in append itself or one selected runtime callee whose recovered caller is
append. The specialized TRMC worker contributes 223 runtime-callee samples:
117 in `p125_rt_take2` and 106 in `p118_rt_extend1`. Its own body contributes
another 38; other append variants contribute 12.

The stage-local distribution is much more informative than the whole-request
share:

| Disjoint stage window | Wall | Samples | Append leaf or immediate callee |
|---|---:|---:|---:|
| Load/parse: `p86_plan` → `p86_plan_loaded` | 30.522s | 952 | 0 |
| Check/publication: loaded → checked | 19.339s | 602 | 0 |
| Raw candidates: `p113pl_candidates` → `p168_candidates` | 24.501s | 764 | 22 (2.88%) |
| Original verification: `p169s_lowered` → `p169a_original` | 9.565s | 297 | 8* |
| Registry: `p169c_output` → `p169s_registered` | 12.173s | 378 | 42* |
| Cursor rendering/output/exit | 31.937s | 960 | **183 (19.06%)** |

`*` These windows fail the maintained 500-sample threshold; their counts are
descriptive, not admitted quantitative per-stage profiles. All windows exclude
boundary samples. The 183 rendering samples are a physical subset of that
window, not the inclusive cost of all string production or a predicted saving.

The source already addresses two obvious pitfalls:

- [`nt_text_finish`](../../selfhost/src/back/native/text.bend#L22) appends each
  new chunk to the growing suffix, avoiding repeated traversal of that suffix.
- [`p134e_next`](../../selfhost/src/back/qbe/stream-emission.bend#L76) and
  [`p134w_step`](../../selfhost/src/back/qbe/stream-emission.bend#L206) stream
  successive output pieces; there is no single 97MB whole-output String.

The remaining boundary still constructs linked Strings for argument fragments,
lines and complete function pieces. For example,
[`p111q_args`](../../selfhost/src/back/qbe/emit.bend#L109) materializes type/value
fragments, and `p134e_private`/`p134e_public` return a String before `File.write`.
`String.append` is already tail-recursion optimized in this image. Adding that
optimization again or reversing chunk order is not the proposed next step.

The smallest worthwhile falsifier is **one complete render operation that
preserves text fragments until bounded output**, eliminating intermediate
linked-string materialization between the IR renderer and writer. Keep final
verification, exact bytes/order, escaping, symbol spelling and write failures
unchanged; charge all fragment construction, buffering and teardown. Use the
existing real verifier/Map output as the fast loop before one full S0 check.
Avoid a syscall per tiny fragment. This is distinct from the already neutral
`render-clean` predicate-sharing experiment.

The measured rendering window is only about 18.3% of this diagnostic request;
even deleting that entire window cannot account for the roughly 80-second
remaining cold-build gap. The narrower observed append subset is only 5.03%.
This capture therefore supports a bounded rendering experiment, **not a new
30% whole-compiler forecast**. Large producer/consumer work elimination in the
frontend or shared function semantics still needs separate evidence.

## Reproduction and limits

The existing offline `attribute.attribute` function consumes the run row's
`analysis`, `callers` and `contexts`, plus
`runtime-callers-prep01/unwind/table.json` and
`candidate-profile-prep01/owners.json`. The summary classifies generated symbols
with `p(?:111|112w|113d)_FID_`, selects leaf before caller, and buckets sample
ordinals using the validated stage interval bounds. `runtime-callers.json`
pins these exact inputs and methods and retains every stage's counts.

The 1ms pilot is preserved as rejected timing evidence: 560 delivered samples
versus about 2,224 expected, with overruns. Its exact output/caller bindings were
useful integrity checks only; none of its samples are pooled here. The repeated
32ms pilot passes integrity checks but remains below the minimum profile sample
count; only this 32ms full run passes the quantitative profile quality gates. The new
runtime CFI table does not include the earlier libc-only caller table; those old
observations are also kept separate. No compiler target, production edit,
runtime change or installed selection was made during this offline analysis.
