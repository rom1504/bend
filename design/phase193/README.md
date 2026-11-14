# Phase193: generated-code improvements that also help the compiler

Start: 2026-11-13 22:14 UTC, branch selfhost/bootstrap at dc413be.
Reference: qualified Phase192 x86 N2 and the same-source QBE-built N1;
installed Phase189 stays unchanged. No assumed compiler/runtime speed transfer.

## Question and sequence

Which general x86 improvement removes real work in both the compiler executable
and unrelated programs? First compare identical complete compiler requests under
N1 and N2, with identical preparation, runtime and output oracles. Attribute CPU
with the existing native profiler, keeping sampling overhead, unknown samples,
physical symbol boundaries and clean timing separate. Start with a request that
lasts seconds, not another full self-build. This investigation has a 30–45 minute
decision budget; stop collecting when a falsifiable mechanism is clear.

In parallel, bounded read-only investigations inspect ownership/constructor fast
paths and local recursive-region control. The previous scoped-frame expansion
was rejected; do not repeat it without a new causal explanation. Per-definition
value identity remains an alternative, not a mandatory new IR.

Choose one shared hot mechanism. Quantify its measured share and removable work,
then test the smallest implementation in Bend against independent controls and
an unchanged baseline. Do not infer speed from fewer instructions or helper calls.
Candidate implementation remains separate until small experiments justify it.

## Experiment ladder and decisions

1. Freeze exact inputs/executables and expected objects; clean paired requests
   and two-period profiles. Require identical output semantics/products.
2. A bounded source/IR/machine witness, independent semantic adversaries, and
   compiler-hot extracted workload. Prefer a 30–90 second iterative gate.
3. Balanced timings on affected programs plus an unrelated transfer case and
   compiler-request cost. Record neutral and negative results. Stop a candidate
   whose work disappears without useful runtime improvement.
4. Freeze selected source, then full native45 with untouched oracles and historical
   geometric, positive-log, family, excess-time and regression diagnostics.
5. Only a convincing selected change warrants source acceptance, native64/runtime10,
   cross-host products and native N1/N2/N3 reproduction. No installed promotion is
   inferred. Keep source checking, finite behavior and formal proofs distinct.

Measured Phase192 frontier is 2.208723× mature C across 44 timed cases. Candidate
planning ranges are 4–10% suite reduction for ownership/fast paths and 4–12% for
simpler recursive control, with overlapping costs and a real possibility of no
win. These are not forecasts or reasons to relax gates. A 2× faster x86 compiler
could save at most about five minutes in the last campaign's affected qualification
jobs; actual research benefit must include hosted, validation and agent costs.

## Resources and evidence

One root-controlled CPU3 execution lane; independent agents inspect/prepare/review.
Use the maintained disk guard and closure receipts for every target job; 2 GiB
normal RSS, explicit larger API budget only if required, 5 GiB reserve. Disk is
currently tight: archive/verify reviewed cold duplicates before reclaiming them.
No deletion by age or whole-phase deletion. Preserve qualified images, all failed
attempts, exact source/tool/output identities and the historical workload split.

Keep a concise experiment ledger, costs and report in implementation/phase193.
Commit and push useful validated changes and negative evidence. Prefer one shared
capability to several overlapping passes, and do not claim recursive acceleration
without a controlled research-throughput experiment.

Phase193 held-out accounting excludes `test-map-set-ops`, whose compiler request
was used for profiling: ten development and 35 held-out programs, with the full
native45 definition unchanged. The separately extracted compiler kernel is a
development workload and does not enter the historical geometric mean.

## Selected experiment after the profile screen

The same-source x86 compiler takes 1.3795× the QBE compiler's request time on
Map-set-ops. Inspection identifies a missing general public fallback route:
ready helpers exist, but H-region refusal leaves their public caller on the
scheduler. QBE already consumes the original bounded closed-continuation fusion
and public-tail plans. Adapt those same verified plans into x86 structured scalar
instructions, below existing direct/H precedence, with whole-segment rollback.
Keep scratch argument snapshots, capture order and the pending caller return.
Do not change admission or the original final verifier.

The 17.8 KB extracted workload uses actual compiler KDef/index routines, collision
keys, persistent overwrite/read behavior and an independent digest oracle.
Its 7.7% paired runtime improvement and gains on four unrelated development
programs justify the next gate: freeze source, acquire N1 with the unchanged
qualified QBE seed, and measure same-producer compiler request overhead. Only
then pay for native self-reproduction and the complete unchanged native45 suite.
This distinguishes extra optimizer cost from faster execution of that optimizer.

The selected source is SHA256
`6a3c990b2a28454cae16c81757675162b92acaa5f0df2e94b8b202698f2a44ec`.
The adversarial controls execute its exact 24 adapter definitions through both
ELF-object and GNU-as routes; their source acceptance and finite observations
are not an end-to-end proof. The installed release remains unchanged.

## Cost gate and final policy refinement

The first full N1→N2 build costs302.204s versus the previous254.875s observation
and produces a12.8% larger compiler binary. Source growth alone is0.82%; public
bodies account for99.45% of measured text growth. The four small N1 requests had
shown only1.6% extra cost, demonstrating why their screen cannot certify scale.
Conversely, the resulting N2 executes those requests10.3% faster than Phase192.
These are distinct acquisition and execution results, not a contradiction.

Before qualifying N3, separate fusion-only and tail-only policies on the real
compiler kernel. Both contribute; combined runtime is0.9254×baseline, fusion-only
0.9324×, tail-only0.9489× in a fresh20-round four-role comparison. Then test a
profitability-only consumer cap: permit the original complete fusion result when
its existing structured statement count is at most2×original+16. Rejection still
allows ready-tail conversion on the entire original segment. Keep original
legality, final verification, effect ordering and fallback intact.

The budgeted kernel object is200,552bytes versus218,048 for the first candidate;
its runtime0.93039×baseline preserves most of the first candidate's0.92466×gain
in a fresh18-round three-role screen. Four development programs stay within1%
of the first candidate. These measured results justify final native qualification
of source SHA256`fd95adc1bdc210bc3827c9dd3536b8e7289fb60c4e983f0e008714665239428a`
at selected-source02. All source01 artifacts remain frozen. No binary-size or
full-build benefit is claimed until this second native acquisition measures it.


Final outcome: the budgeted source passes native qualification and the complete
runtime campaign. It reduces native compiler request time9.32% and program
runtime4.16%, with explicit source/build costs and remaining regressions.
See [Phase193 report](../../implementation/phase193/README.md) for final identities,
metrics, rejected attempts and limits. The installed release remains unchanged.
