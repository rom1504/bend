# Bounded worker optimization: defer the first implementation

2026-10-04. **Decision: retain worker02 as a tested experiment; do not select or
promote the405-line pass.** The coordinator will preserve its independent
source patch and checked snapshot, then remove its integration from maintained
compiler source. No replacement pass is implemented in this report.

The measured change is small leaf-call expansion, with no demonstrated aggregate
elimination in the two timed corpus programs. Preliminary2–4% speed differences
do not justify shipping the current amount of additional compiler machinery.
Compiler cost has not been measured in a controlled comparison. There is no
full-corpus qualification or promotion claim.

## Evidence and scope

This report reads saved JSON and parses generated JavaScript as data. It does
not import or execute an emitted program or compiler. Before/after modules are
the exact selected23 baseline and checked worker02 modules joined by the
screen's manifest and timing receipt.

| Receipt under `selfhost/build/phase47/` | Scope / SHA256 |
| --- | --- |
| `checked-worker02/attempt.json` | Checked derivative; `36b965e7bd1423a64fd92f1e438efc3a1496e721f7aa59888906501eb03bc00c`. |
| `worker02-ir-controls/report.json` |18 independent finite-IR controls pass; `4b26c640d0d8a4c991141749e85ddd4801bf5b655b3b08a9b1f07e0e39094398`. |
| `jw-worker02-controls/observations/report.json` |72 source oracles and11 public/error boundary controls pass; `1419909d9d3c58601c1057abb4dbb572fc8289fdd742446c47ae2abd22e65836`. |
| `worker02-canaries/report.json` | Five canaries pass; `99b97fa8a29692c63ce38f3319813b92608cec9487641a6e2bcba4feb721fd46`. |
| `worker02-screen/manifest.json` | Six compiled source modules; `3d33ba29f7961b6a1fac5e6c171376a9464a5d0ecd2041a527ad29f4413c450c`. |
| `worker02-timing/report.json` | Two-case execution screen; `cbb5f12960a8c74467bd3020beece75290a81cac494746089a0d56f77d881b6e`. |

These controls establish their stated finite scopes. The18 IR cases include
actual call/projection reduction on a synthetic witness; that does not mean
the same allocation-elimination mechanism activated in the corpus.

Worker01's parser failure remains preserved. Worker02 uses named match
scrutinees and has source-module hash
`80f3639c8f8aa13d3ae0a85fa97115887e82821cef0995f94143678de5f3f12d`.
Its immutable source is in `source-worker02/src/back/js/ir/worker-optimize.bend`
under the same build directory. The candidate API is
`6991c98ae87bf471250237ab1ebb5caa1d83a40c4cd6ec3ed4b2ef9530f07d8e`;
the runtime is unchanged from selected23.

## The short timing result

Both programs pass their independent expected outputs. The screen uses three
balanced rounds,350ms warmup,40ms calibration and150ms target samples, on CPU3.
Its total wall time is15.2317s. These are generated-program execution timings,
excluding checking, emission, compiler build and JavaScript import.

| Program and input | Selected23 median | Worker02 median | Baseline / candidate | Candidate / pinned TS |
| --- | ---: | ---: | ---: | ---: |
| Map churn `(128,123)` |1.441868ms |1.386127ms |1.04021× |1.75038× |
| Records `(256,123)` |1.971195ms |1.933893ms |1.01929× |1.53186× |

The corresponding median time reductions are3.87% and1.89%. The screen is
preliminary, not a stable improvement estimate: Map candidate second-half
drift ranges from−22.93% to−10.79%, versus−6.46% to−5.27% for baseline. Records
ranges from−10.56% to+27.62% for candidate and−14.76% to+19.30% for baseline.
These drift magnitudes exceed the proposed benefit. A longer confirmation was
not run for this pass.

RLE, bitonic, expression and closure-chain modules are byte-for-byte identical
to the selected baseline. This is a real code-generation result: those four
programs receive no emitted change from this candidate. It is not evidence
that the pass improves their speed.

## What actually changed

Complete assignment AST comparison finds **only `G["bench"]` changed** in Map
and records. Every other public assignment is unchanged. Within those roots,
all private helper declarations remain, including those whose calls expanded.

| Static emitted measure | Map before → after | Records before → after |
| --- | ---: | ---: |
| Module bytes |246,492 →246,942 (+450;0.183%) |239,842 →240,762 (+920;0.384%) |
| Physical lines |879 →879 |876 →876 |
| Function declarations inside `bench` |81 →81 |82 →82 |
| Calls to private `$R…$tree` helpers |243 →234 (−9) |245 →229 (−16) |
| Array literal sites inside `bench` |197 →205 (+8) |205 →221 (+16) |
| Tagged object literal sites |550 →558 (+8) |564 →580 (+16) |
| Numeric field reads excluding machine-register indexing |198 →216 (+18) |202 →234 (+32) |
| Private named-field reads `._N` |217 →217 |222 →222 |
| Assignment expressions |2,281 →2,306 (+25) |2,341 →2,389 (+48) |

These are static syntax counts, not dynamic allocation counts or sampled CPU
shares. In particular, copying a helper into a caller adds literal sites while
the original helper remains; it does not imply the program now allocates more
objects for the same source operation. Much generated code is on a single line,
so physical JavaScript line counts are not useful complexity evidence here.

The removed calls have an exact source explanation. Private function names
encode instance indices; joining those indices to the root's ordered `$guards`
array identifies the original source helper:

| Module | Private instance / source helper | Static calls before → after |
| --- | --- | ---: |
| Map |35 / `Map.del.fin` |1 →0 |
| Map |38 / `Map.lo` |6 →2 |
| Map |39 / `Map.hi` |6 →2 |
| Records |31 / `Map.lo` |12 →8 |
| Records |32 / `Map.hi` |12 →8 |
| Records |36 / `Map.lo` |6 →2 |
| Records |37 / `Map.hi` |6 →2 |

Map's changed emitted functions are private instance36, `$worker40` and
`$native40`. Records changes `$worker33`, `$native33`, `$worker38` and
`$native38`. Native and continuation-machine bodies duplicate source edges;
their static counts must not be added as executed calls on one input.

`Map.lo` and `Map.hi` each project a result pair, reconstruct one persistent
`MNode`, wrap it in another result pair, and return it. The pass expands that
same work into selected caller sites. The result is still transported across
the component's return boundary. The node and result-pair allocations therefore
remain in each expanded body; the source inspection shows no shell disappearing
from these affected sequences.

`Map.del.fin` illustrates the limitation particularly clearly. Omitting only
renamed registers, the changed caller goes from:

```js
pair = pop(map, key);
result = del_fin(pair);
return result;
```

to:

```js
pair = pop(map, key);
first = pair[0];
unused = pair[1];
return first;
```

The unused second projection is retained. The current discard predicate only
admits copies/Nat leaves and already-materialized private shells, so it cannot
delete that read without a stronger private-field effect fact. The emitter also
declares some now-unused registers because it uses a numerical register bound.

Thus the corpus result is call expansion plus administrative-copy cleanup.
The aggregate fact/use infrastructure works on the synthetic witness but has
not shown a corpus allocation benefit here. The earlier
[opportunity census](worker-opportunities.md) correctly warned that many
returned pairs cross recursive/component boundaries and that `Char.cmp`,
String reconstruction helpers and branchy RLE work lie outside this first slice.

## Could a smaller pass be worthwhile?

**Do not retain405 lines merely as enabling infrastructure.** Preserve the
implementation, test witnesses and refusal counterexamples for reuse when a
consumer demonstrates a benefit. They are useful experiment outputs, but they
are not performance or simplification credit for the installed compiler.

There are three distinct smaller directions; none is authorized or implemented
by this report:

1. **A bounded return-summary inliner.** Restrict leaf summaries to projections
   and tuple/tagged construction over stable parameters, and require stable
   actuals or explicit ordered materialization. A single expression-summary
   substitution may replace general slot cloning, a forward fact map and much
   of the cleanup machinery. This could reproduce the observed helper-call
   reductions with substantially less machinery. It would still perform the
   same persistent reconstruction and transport allocation; the present screen
   offers no reason to forecast more than the same small, unconfirmed benefit.
2. **Discard unused proven-private field reads.** A small backwards-use
   consumer could remove reads like the second `Map.del.fin` projection if
   lowering supplies a total, immutable own-field permission. It must exclude
   public objects, native String/Char observations, unknown projections and
   malformed input. V8 may already eliminate such reads, so expect a useful
   counterexample/measurement before a compiler build, not an assumed gain.
3. **Keep local aggregate forwarding without inlining.** This would remove
   some code from the implementation, but none of the measured corpus changes
   establishes that it helps independently. A no-inline ablation is required;
   there is currently no benefit to assign to this option.

The more consequential representation opportunity remains producer/consumer
transport across private call and return boundaries: pass scalar components
through tail edges or summarize returned fields without building a pair.
That is a separate, larger proof than copying a helper. The next experiment
should identify executed transport allocations and test one general boundary
rewrite in saved output before implementing another broad pass. It should not
relax proof or effect boundaries to rescue this result.

For this phase, defer the pass and prioritize the stronger independently
measured Array result. Keep higher-order target discovery as a separate coverage
problem: this worker pass neither discovers unknown closures nor admits
function-valued signatures.

## Exact module identities

| Module | Baseline SHA256 | Worker02 SHA256 |
| --- | --- | --- |
| Map churn |`652574426a7a8c234dbda91841ec3505dd655da08b5c357451d67ed3aa7ac998` |`1eb928b356babd50d9770aa79b212831a301683ecfeb0fd730e1eb76d32f2254` |
| Records |`5ba71c4ff05b1c9af4f3af39cac5fbc36a0b276511a0c46a5d0c51e6795c6c94` |`c2f084c3a40f9d9884fd8c2f93194a02dc412857cd952fc885d898c314fe0140` |

Candidate modules are in `worker02-screen/modules/`. Exact extracted baseline
modules are in `worker02-timing/modules/baseline/baseline/modules/<SHA256>.mjs`,
under the build directory above. These paths identify current raw evidence;
durable preservation belongs to the campaign archive and independent source
patch, not to a promise that ignored build paths are permanent GitHub links.
