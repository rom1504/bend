# Identical compiler request under QBE N1 and x86 N2

The first bounded compiler-cost comparison uses Phase192's qualified same-source
N1 and N2 to emit one identical x86 object. Both images implement the same
`selected-source01/compiler.bend` (1,803,092 bytes, SHA256
`301435947ae813b64eebaf30610d2be4aa3be5b7ddd772bd0e68f1b6aac48c20`).
N1 is the QBE-produced `native-image01/program` (`4060b6b7…`); N2 is the
direct-x86-produced `native-self01/program` (`8065c04b…`). This measures the
machine-code implementation of a fixed compiler computation. Both emit x86
objects; it is not a comparison of emitting QBE versus emitting x86.

The fixed request is native45 `test-map-set-ops.bend`, a 7,234-byte real source
fixture. Its existing acquisitions took 4.031s N1 and 5.555s N2 in compiler
emission. Those historical values select a useful sampling duration; they are
not a fresh performance result. A full self-source build takes hundreds of
seconds and is deliberately deferred. This small request includes startup,
Base loading, checking, lowering, direct-object generation and stdout writes;
it cannot establish full compiler-source throughput or stage-specific costs.

`selfhost/tests/phase193/compiler-profile-plan.py` executes no target. It invokes
the maintained request planner, verifies image bindings and acquisition receipts,
and requires identical argument tails, fixture, Base, prepared carrier, stamp,
linked runtime and RTS convention. Common explicit argv0 is `compiler-work`.
The profiler launches each ELF directly. No shell/repetition wrapper changes the
sampled process. N1/N2 source identity is equal, but emitted compiler object
layout, instruction selection and allocation can differ; observed differences
do not identify a specific optimization as causal.

The independent stdout oracle is the already checked-hosted
`phase192/selected-emit01/test-map-set-ops/program.o`, 587,720 bytes, SHA256
`8f72c7a3e386b4e1f2e21437e23e1858294b36c25a1a3825d2e5e7ea675c8e98`.
The helper independently rehashes both native acquisition objects and requires
equality to this third artifact. It also retains hosted/native comparison and
generated-program oracle receipts. This is finite cross-host consistency, not
an independent proof of compiler correctness.

The existing Phase159 all-created-thread sampler is authenticated against its
completed build receipt and frozen source snapshots. No runtime relink or
compiler-source instrumentation is introduced. Sampled runs use 8ms and 13ms,
twice each; clean runs rotate the two image roles twice. Four sampled captures
per role should yield more than 500 pooled observations at historical duration.
No sample count is guaranteed: retain loss/overrun, lifecycle, process-CPU
coverage, period diversity and unknown-symbol gates. Diagnostic times never
replace clean timings. This collector cannot support chronological stage
inference or physical caller attribution.

Preparation completed at `selfhost/build/phase193/compiler-profile-plan02`.
The earlier plan01 is a superseded metadata draft (160s rather than 150s guard)
and its script pin is stale; do not execute it. Plan02's role manifest and plan
record full hashes. Its target budget is 12 requests, at most 12s each, under a
150s whole-run guard and 128MiB disk budget; historical expected child total is
57.52s. Root owns the single execution lane:

```sh
python3 -B selfhost/tests/phase193/job.py --file-mib 64 \
  compiler-profile01 150 128 \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest selfhost/build/phase193/compiler-profile-plan02/manifest.json \
  --out selfhost/build/phase193/compiler-profile01 \
  --modes clean,sample --rounds 2 --periods-us 8000,13000,8000,13000
```

After completion, the following are offline analysis only:

```sh
python3 -B selfhost/tests/phase193/check-profile-output.py \
  --roles selfhost/build/phase193/compiler-profile-plan02/roles.json \
  --report selfhost/build/phase193/compiler-profile01/report.json \
  --out selfhost/build/phase193/compiler-profile01/independent-output.json
python3 -B selfhost/tools/profiler/compare.py \
  --report selfhost/build/phase193/compiler-profile01/report.json \
  --reference qbe_n1 \
  --out selfhost/build/phase193/compiler-profile01/comparison.json
python3 -B selfhost/tools/profiler/render.py \
  --comparison selfhost/build/phase193/compiler-profile01/comparison.json \
  --out selfhost/build/phase193/compiler-profile01/summary.md
```

The independent output checker uses its own SHA256 loop, authenticates the
preexisting hosted comparison, and requires exactly two clean and four sampled
complete outputs per role. Standard profiler analysis supplies pooled quality
gates and physical leaf/category estimates. Cross-image segment ordinals are
not source identities. Compare recognizable runtime helpers and authenticated
symbols; do not claim source ownership from an anonymous symbol number.

At preparation time no compiler or sampling job was run by this helper. Future
results belong in the final Phase193 report with clean sample distributions,
profile admission/rejection and exact evidence links.

## Completed root-controlled capture

Root executed the prepared command once. All twelve requests pass both the
profiler contract and the separate complete-output rehash. Evidence:
[`report.json`](../../selfhost/build/phase193/compiler-profile01/report.json),
[`independent-output.json`](../../selfhost/build/phase193/compiler-profile01/independent-output.json),
[`comparison.json`](../../selfhost/build/phase193/compiler-profile01/comparison.json),
[`summary.md`](../../selfhost/build/phase193/compiler-profile01/summary.md),
[`findings.json`](../../selfhost/build/phase193/compiler-profile01/findings.json).

| Metric | QBE-produced N1 | x86-produced N2 |
|---|---:|---:|
| Clean wall seconds, two samples | 4.076689, 4.164492 | 5.745198, 5.623367 |
| Clean wall median | 4.120591 | 5.684283 |
| Clean CPU median | 4.093320 | 5.660730 |
| Median peak RSS, KiB | 44,282 | 50,864 |
| Accepted pooled samples | 1,686 | 2,292 |
| Rejected captures | 0 | 0 |
| Period-weighted unknown leaf fraction | 1.349% | 1.383% |
| Sampled/clean wall median | 1.0248 | 1.0179 |

N2 is 1.37948× the wall time and 1.38292× the CPU time of N1 on this fixed
request: +1.56369s wall and +1.56741s CPU. Both pooled profiles pass sample,
loss, lifecycle and process-CPU coverage gates; absolute estimates are enabled.
Five individual captures have fewer than 500 samples and are admitted only by
compatible pooling, preserving all other quality checks. Two clean observations
are a bounded screen, not confidence intervals or a full-build throughput claim.

The standard summary ranks physical leaves separately for both roles. The table
below highlights approximate clean CPU, obtained by multiplying period-weighted
leaf share by that role's own clean CPU median. Each request is executed once,
so no repetition normalization is needed.

| Physical leaf | N1 share | N1 CPU s | N2 share | N2 CPU s |
|---|---:|---:|---:|---:|
| `term_drop` | 12.01% | 0.4917 | 9.40% | 0.5319 |
| `span_fade` | 6.93% | 0.2838 | 5.05% | 0.2858 |
| `p125_rt_take2` | 5.18% | 0.2121 | 5.66% | 0.3207 |
| borrowed `p88_string_eq_go` | 4.88% | 0.1997 | 5.85% | 0.3312 |
| borrowed `index_hash` | 4.77% | 0.1953 | 3.61% | 0.2042 |
| `p111_rt_sink` | 4.69% | 0.1919 | 3.58% | 0.2025 |
| borrowed `String.order.go` | 3.90% | 0.1598 | 4.59% | 0.2601 |
| `work_loop.constprop.0` | 2.11% | 0.0863 | 3.13% | 0.1770 |

`profile-findings.py` aggregates direct/read-borrow/owned-borrow symbol spellings
with the same lexical name, checks exact physical-module versus assembled-source
declaration bytes, and retains anonymous/generated groups separately. This is
not the profiler's fully authenticated emitted owner map, nor inclusive source
ownership. In particular, a runtime `take` sample is not reassigned to a caller.

The largest exact compiler-declaration name groups are:

| Lexical declaration | N1 CPU s | N2 CPU s | Difference s | Source |
|---|---:|---:|---:|---|
| `p88_string_eq_go` | 0.2332 | 0.3830 | +0.1499 | `core/consuming-strings.bend:5` |
| `index_hash` | 0.2063 | 0.2219 | +0.0157 | `core/index.bend:66` |
| `p98_tag_eq` | 0.0374 | 0.0895 | +0.0521 | `core/consuming-strings.bend:72` |
| `index_find` | 0.0481 | 0.0768 | +0.0287 | `core/index.bend:116` |
| `p131i_insert` | 0.0442 | 0.0673 | +0.0231 | `core/index-queries.bend:9` |
| `p88_string_eq` | 0.0437 | 0.0656 | +0.0218 | `core/consuming-strings.bend:17` |

Anonymous/generated names contribute 0.2349→0.4613s (5.74→8.15%); their
physical leaves are resolved, but this simple lexical analysis assigns no source
declaration. `String.order.go` belongs to the prepared Base/lowered names and
does not appear in the compiler assembly map. Its aggregated 0.1630→0.2621s
is preserved as a lowered name, not falsely mapped to a compiler declaration.

The measured gap spans compiler string readers, runtime take/dispatch, and
unassigned generated code. `term_drop` remains the largest individual leaf but
its absolute estimate grows only about 0.040s; a smaller percentage does not
mean it became faster. These data justify inspecting the actual hot string/read
worker and dispatch code before claiming one global ownership or allocator
bottleneck. No compiler transformation or causal speedup follows from this
profile alone.

## Exact hot string machine witness

The two exact borrowed workers have physical CPU ratios 1.6584× for
`p113d_FID_$p118borrow.read.p88_string_eq_go` and 1.6271× for
`p113d_FID_$p118borrow.read.String.order.go`. The first maps lexically to
`core/consuming-strings.bend:5`; the second retains its Base/lowered name.

[`machine-witness01/report.json`](../../selfhost/build/phase193/compiler-profile01/machine-witness01/report.json)
pins the exact selected executables, `objdump`, extraction method, symbol spellings,
full disassemblies and finite static path witnesses. Reproduce offline with
`selfhost/tests/phase193/string-machine-witness.py --comparison .../comparison.json
--roles .../compiler-profile-plan02/roles.json --out FRESH`. This performs no
target execution. Fixed address decisions intentionally fail on another binary.

| Continuing direct/unshared SCon/SCon path | N1 instructions | N2 instructions | N1 frame memory instructions | N2 frame memory instructions |
|---|---:|---:|---:|---:|
| Equality with previous `same=True` | 97 | 213 | 12 | 27 |
| Ordering with previous `order=EQ` | 101 | 154 | 15 | 17 |

These are static selected-path counts, excluding callee bodies, not dynamic
instruction counts or measured path frequencies. Both equality paths make zero
calls; both ordering paths call `p111_rt_op` once. Conditional branches are
10→12 and 9→11 respectively. Frame-memory counts exclude LEA, and refer to
instructions with an RBP memory operand, not cache misses or DRAM traffic.
Profile PCs also occur on the shared-payload decoding paths; the unshared static
witness must not be reported as the measured dominant branch or average iteration.

N2 equality repeats constructor-tag extraction and Boolean materialization
(`cmp; setcc; movzbl; mov; test; branch`) and spills the second-string tag-test
intermediates through frame slots `-0xa40` to `-0xa70`. Character narrowing and
comparison use further `-0xb18`, `-0xb20`, `-0xb28` slots. Before narrowing,
N2 performs two always-true comparisons at `0x4074ed` and `0x407507`: copying
R14/RSI to RDI and comparing each copied value with its original, then expanding
the result through `sete; movzbl; mov; test; je fail`. N1's character path at
`0x40b18e` directly zero-extends and compares characters without these guards.
Ordering likewise has self-comparison/failure branches at `0x40869d` and
`0x408902`. A general fact/predicate consumer or redundant machine-comparison
elimination therefore has a concrete hot-loop witness, separate from a proposal
to change the String representation. The listing alone does not prove its total
speed benefit or explain runtime helper differences.

The dispatcher also grows from approximately 0.08628s to 0.17705s (36→75
physical samples), `p111_rt_return` 0.01809→0.05436s (8→21), and
`p111_set_regs` 0.02249→0.05062s (9→21). Public `p131i_insert` is sampled
17→25 times and estimated 0.04424→0.06733s. Public `index_leaf`, `index_remove`
and `p111v_put` have only 2–7 samples per role. These support inspecting missing
ready/public-call routes while remaining too sparse for trustworthy individual
call-count or allocation attribution. Shared runtime bytes do not imply identical
runtime call counts: differences in which compiler lowering routes are consumed
can change dispatcher, continuation, allocation and reclamation work.
