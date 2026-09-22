# Emission costs: traversal, strings and closed type facts

No production rewrite follows from this probe. Replacing right-recursive
`j_defs` concatenation with a disposable JavaScript fragment array did not give
a consistent benefit. A separate guarded experiment did isolate redundant
substitution work in deep lambda emission; it needs a suitable Bend representation
and realistic checked-book measurement before promotion.

[Evidence](evidence/emission-analysis.json) retains operation counts, all timing
samples, checked input/output hashes, direct semantic controls and artifact/tool
identities. Raw disposable APIs and inputs are under
`selfhost/build/phase3/emission/{scaling,facts}/`.

## Workloads and controls

The immutable phase 2 B1 API was
`794cbf5f00a0a3a29f53821d530d27211c217a0636da14082adcbb18f4e5f2b6`.
Each synthetic book passed its unchanged checker and was annotated before
emission. Seventeen books independently varied definition count (16–1,024),
name/output length (16–1,024 characters), constructor nesting (8–512), and lambda
depth (8–128). This is emitted library text from prepared books; source parsing,
checking, annotation, API startup and full-program execution are outside the
emission timer.

A disposable instrumented API counted emitter/type helper entries and 234 static
string-addition sites. Every instrumented output equaled the unchanged output
exactly. These operation counts are separate from timing. The string counters
sum operand lengths; they do **not** measure bytes copied by V8.

Plain versus experimental emission used five alternating samples per size on
CPU 0, Node v24.18.0, a 4 MiB stack and 4 GiB heap. Each result was fully consumed
by SHA-256 over UTF-8 bytes after emission. Generation and consumption intervals
were recorded separately. Samples share a warmed process, and other agents used
other CPUs. Small cases and single-process ratios are noisy; this is causal
component evidence, not a full-compiler performance claim.

## Definition concatenation: no warranted change

`j_defs` emits one definition, then its suffix, and appends the former to the
latter. Its left operand is not a growing prefix. On the definition-count series,
that operand stayed at most 55 characters; its total length grew from 838 to
55,210 characters as the definition count grew from 16 to 1,024. The summed
right-operand lengths grew quadratically, but that metric alone does not imply
quadratic copying in a rope-capable JavaScript runtime.

The experimental replacement emitted definitions in the same order, gathered
fragments, and joined them. It preserved exact bytes on all 17 cases. At 1,024
definitions, unchanged versus joined median fully consumed emission took
369.9 versus 386.6 ms, with 55.6 KB output. There was no consistent gain across
sizes. A production builder rewrite is therefore unwarranted on this evidence.

Constructor depth 8→512 grew output from 640 to 11,224 bytes, emitter expression
entries from 18 to 1,026, and substitutions from 8 to 512. Increasing one quoted
name from 16 to 1,024 characters increased character-escape visits from 88 to
1,096. These controls primarily show linear traversal in the scaled dimension.
Large summed append operands do not override the observed operation/timing
behavior or establish native-runtime copying costs.

## Deep lambdas: repeated type substitution

The closed telescope series produces repeated walks even though none of its
remaining types depends on the removed binder:

| Lambda depth | Output bytes | `subst` entries | From `j_lambda_bind` | From `j_l_lam` |
| --- | ---: | ---: | ---: | ---: |
| 8 | 578 | 64 | 64 | 0 |
| 16 | 713 | 256 | 256 | 0 |
| 32 | 985 | 1,024 | 1,024 | 0 |
| 64 | 2,396 | 9,216 | 5,120 | 4,096 |
| 128 | 7,457 | 46,853 | 30,469 | 16,384 |

`j_lambda_bind` substitutes the remaining telescope at each binder.
Above the closure-lifting threshold, `j_l_lam` traverses the telescope again
while constructing lifted factories. The threshold changes the path and output,
so a single fitted complexity exponent would obscure what these counts show.
At depth 128, the first scaling run spent about 81.4 ms generating just 7.5 KB;
its separate output consumption median was about 0.13 ms. Output finalization
was not the dominant measured interval on that fixture.

A naive “variable absent means skip substitution” shortcut is incorrect:
`subst_node` calls `core_rebuild`, which beta-reduces application nodes even if
the substituted variable never occurs. The direct control retained in the
archive demonstrates that requirement.

The second disposable experiment instead computes a conservative per-emission
fact: **there is no `Var` and no `App` anywhere in this term**. Only that case
returns the unchanged term. All other cases use the original substitution
implementation. Facts are memoized by immutable term identity in a JavaScript
`WeakMap`, discarded after each emission, and recomputed inside every timing.
There is no cache across books, changed contexts or requests.

At depth 128 the experiment reduced entered substitutions to 445, with 16,384
fact-node visits. The latter is still substantial because annotated suffixes
contain distinct term objects; this is not a claim of linear work. In that run,
plain versus fact-assisted median fully consumed emission was 70.40 versus
18.11 ms. At depth 64 there was no gain (16.56 versus 16.87 ms). Most non-lambda
controls were unchanged or noisier, including a slight regression for the largest
constructor case. This is a bounded causal result, not a uniform multiplier.

All 17 original books and two additional checked dependent-identity/beta-type
books emitted exactly the same bytes with facts enabled. Four direct
substitution controls also matched structurally: absent-variable beta reduction,
dependent replacement, replacing a variable with another name at the same ID,
and a closed application-free tail. The dependent identity exercised only the
original fallback path.

A next candidate would carry a proven, immutable closed/application-free fact
in a compiler-owned annotation structure, scoped to the emitted book. First
measure how often actual compiler telescopes satisfy it, how much duplication
annotation introduces, and what computing/storing the fact costs in Bend.
Do not add a generic kernel “unused substitution” fast path from this experiment,
or reuse facts across changed terms merely because binder IDs coincide.

## Reproduction

The repository tools are
[`emission-probe.mjs`](../../selfhost/tools/performance/phase3/emission-probe.mjs)
and
[`emission-facts-probe.mjs`](../../selfhost/tools/performance/phase3/emission-facts-probe.mjs).
The following commands reproduce the shapes using fresh output directories;
`timeout` supplies an external bound for new attempts:

```sh
timeout 180s taskset -c 0 node --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/performance/phase3/emission-probe.mjs \
  selfhost/build/phase3/baseline/api/b1.mjs \
  selfhost/build/phase3/emission/scaling-new

timeout 180s taskset -c 0 node --stack-size=4096 --max-old-space-size=4096 \
  selfhost/tools/performance/phase3/emission-facts-probe.mjs \
  selfhost/build/phase3/baseline/api/b1.mjs \
  selfhost/build/phase3/emission/scaling-new \
  selfhost/build/phase3/emission/facts-new
```

The original completed probes used the same commands without the external
`timeout` wrapper and used the recorded Node executable. No compiler, host,
harness or shared kernel source was edited.
