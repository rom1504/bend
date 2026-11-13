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
