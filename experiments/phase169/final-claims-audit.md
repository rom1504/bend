# Independent Phase169 claims audit

This is an offline receipt/source review. No compiler, generated program or
profile ran in this lane; no existing report or evidence artifact was modified.
The first snapshot included `cold-six-timing01`. The final metadata review below
supersedes that snapshot's pending native-transfer and broad-runtime gates;
the original findings remain preserved afterward.

## Final superseding results

No material numerical or image-binding blocker was found. Independently reading
the final receipts confirms:

- `quality-native-n2/report.json`: **147.763781s**, complete, on the exact
  **1,538,604-byte** combined quality native source. N1→N2 QBE, assembly and object
  agree. This audit rehashed the actual assembly/object/binaries and independently
  decoded all four ELF `PT_LOAD` descriptors and byte ranges: mapped images are
  identical. Whole ELF files are not byte-identical. The sub150s result must not
  be inferred for a larger input; this particular observation is2.236s below150.
- `quality-canonical01/report.json`: **185.189517s**, complete, on the identical
  **3,085,157-byte** canonical source used by `canonical-baseline01` at244.460650s.
  This is **24.245674% less time /1.320057× speedup**. The complete94,447,397-byte
  QBE stream matches the retained candidate oracle. The larger workload remains
  **35.189517s above150**. These are single-build observations, not a demonstrated
  repeatable bound or attribution to one pass.
- `quality-qualification01/report.json`: **64/64 pass**, zero failure or
  unsupported case, unchanged inputs, and exact binding to the final N2 image.
  This covers61 complete outputs and three refusals in the maintained finite
  ordinary QBE suite; it is not full-language conformance or a correctness theorem.
- `quality-six-native01` plus `quality-remaining-native01`: all **6+39** actual
  native candidate products acquired successfully. The following runtime result
  therefore belongs to final native N2 emission, resolving the earlier hosted-
  only quality caveat.

`quality-broad-timing01` preserves all45 points and360 correct output/count
observations. Its aggregate correctly remains incomplete because four timed
points are below100ms. The predeclared resolution repair selects exactly those
four points, the same frozen manifest/images, four balanced rounds and equal40×
repetitions for both roles. `quality-resolution01` adds32 correct observations;
every repaired interval is at least165ms. The policy file predates that guard
start, and its hash is included in the final summary. No unfavorable point was
discarded or replaced by a different source/input/oracle.

This audit independently recomputed medians from raw `elapsedMs / repetitions`,
then candidate/reference ratios and geometric means, without using the
collector's aggregate implementation. Results agree with
`implementation/phase169/program-runtime.json`:

| Metric | Independently recomputed |
| --- | ---: |
| Timed points / correctness-only points |44 /1|
| All correct original + repair observations |392|
| Equal-point geometric ratio |0.9689621986×|
| Equal-family geometric ratio,22 families |0.9589186446×|
| Worst point (`variation-symreg-4-17`) |1.0357751278×|
| Points above1.05× |0|

The separate equal-source ratio0.960379× uses23 source groups; it must not be
called the22-family metric. The original incomplete aggregate and40× repetition
repair remain explicit. A sum of original fixed-batch medians is descriptive
scale1 work only; it is not an end-to-end clock or a mixed-scale total.

The earlier19× editdist failure and subsequent composition/cold repairs remain
essential evidence. The final corpus supports performance preservation and a
modest aggregate improvement **against Phase152**; it is not a new upstream
parity measurement or a guarantee for arbitrary programs. Native final-image
quality, canonical exact emission and the finite qualification gates described
as pending below have now passed. Production installation, session/batch,
JS/C and parallel/GPU support remain outside this experiment. The narrow150s
result has only a small single-run margin; report that plainly rather than
promising a durable performance threshold.

## Earlier checkpoint audit, preserved

The strongest complete-build comparison is **244.460650→187.496130 seconds on
the identical 3,085,157-byte canonical source**, a23.302% reduction or1.304×
speedup. `canonical-baseline01` and `single-canonical01` pin source SHA
`027e1504…`, identical runtime `2d078323…`, and the same machine policy. Their
generated programs differ legitimately; the candidate reproduces its retained
94,447,397-byte QBE exactly. These are single complete-build observations, not
balanced repeated timing or proof that the final quality successor costs the same.

The **148.820649-second self-build is a different workload**: the1,509,504-byte
experimental native dependency closure, SHA`2e09b0ee…`. Its previous-producer
build is159.159684s. Both reproduce QBE, assembly and object; the one-byte ELF
difference is non-loaded filename metadata, as independently documented in
[the ELF audit](elf-reproduction.md). It supports a sub150s observation for this
smaller closure, not the full canonical compiler, all targets, or a qualified
replacement. The canonical result remains37.496s above150; a further20.0%
reduction from187.496 is required even before charging the quality successor.

The six-family runtime evidence is also correctly scoped. All three screens
have48 correct complete-output/count observations, four balanced rounds per
case, no low-resolution samples and fresh execution of both roles. Lower is
better:

| Family | Initial native route | Hosted ordinary composition | Hosted composition + cold metadata |
| --- | ---: | ---: | ---: |
| editdist |19.1925×|1.0079×|1.0000×|
| tree-bitonic |1.1407×|1.1197×|1.0115×|
| lexer |1.2505×|0.9832×|0.9940×|
| RLE |0.9829×|0.9795×|0.9863×|
| Map/set |0.8626×|0.8601×|0.8616×|
| raytrace |1.5655×|1.0456×|1.0469×|
| Equal-point geometric mean |1.8200×|0.9962×|0.9816×|

Receipts are `program-screen-timing01`, `ordinary-six-timing01` and
`cold-six-timing01` under `selfhost/build/phase169`. The latter two contain native
program executions **emitted by checked hosted B1**, whereas the first was
emitted by native `N2-P169-single`. None is an upstream comparison or the full45
result. A neutral aggregate alone would have concealed the ordinary variant's
11.97% tree regression. The cold successor's largest observed slowdown is
raytrace4.69%; these small single-campaign differences are screens, not precise
population estimates.

Array mode alone left editdist14.90× slower. Ordinary composition restores the
actual complete64,068-byte row function to reference QBE identity and recovers
runtime. This is stronger mechanism evidence than a capability-bit or function-
count correlation. The major failure was losing composition between otherwise
valid optimizations; the early19× result must remain in the final account.

The complete ordinary controls contain144 finite observations; the cold
successor contains152. The separate six literal error-priority controls pass
after the documented v1 source-check failure and explicit-type v2 correction.
These support their stated boundaries, not a new proof theorem or broad native
qualification.

## Remaining gates and recommendation

1. Acquire the exact combined quality native source and authenticate its image
   binding. Compare its complete emission against the checked hosted successor
   on the six wrappers, or repeat their independent value/count and balanced
   runtime gates through that native image. Hosted quality is not inherited by
   a new native generation merely because its source extracts correctly.
2. Compile the identical canonical source with that image. Require the predicted
   exact candidate QBE on the false-certificate path, then measure complete
   compiler/QBE/assembly/link time. Extra source-permission/certificate traversal
   is real work even when no representation changes. Do not combine the earlier
   187.496s speed with newer quality results as one already-measured version.
3. Before general promotion, run the maintained focused and broad ordinary QBE
   qualification, including exact negative diagnostics and live/cache controls,
   against the final image. Finish the original45 runtime qualification when
   claiming general performance preservation. Keep session/batch, JS/C and
   parallel/GPU support explicitly outside this private entry's evidence.
4. Preserve source checking, independent result oracles, final-IR checking,
   bootstrap agreement and performance as distinct gates. No passing one
   substitutes for another. Retain Phase152 as the installed compiler until
   final-image qualification and the requested public-entry scope are resolved.

Recommendation: complete this one combined native transfer and its exact
canonical clock before adding another optimization. The evidence now supports
continuing the architecture, with restored capabilities; it does not support
declaring the full150s/quality target achieved or forecasting another free20%.

## Reporting and collector review

The README initially referred to its “last two rows” as same-source despite the
last row being canonical. Root corrected that to name the159.160→148.821 closure
rows explicitly during this audit. Its checkpoint narrative should also be
updated with the now-completed ordinary/cold screens while preserving their
hosted-versus-native distinction and the initial rejection.

`tools/collect.py` initially omitted benchmark `aggregate`, `cases`, `plan`,
`wallSeconds`, `status` and `budgetOverrunSeconds` from its compact metrics.
Root added them during review. This prevents the machine-readable summary from
silently dropping the strongest negative and recovery evidence. Raw reports
were already selected for the capsule.

At the inspected collector SHA`55144a07…`, capsule selection still includes
literal `manifest.json`, but not necessarily `programs.manifest.json` or
`compiler.manifest.json`; it also omits raw files named `stdout`/`stderr` while
including `*.stderr`. Include these bounded evidence files or explicitly index
their independently verified external archives. Report hashes alone do not make
the capsule self-contained for reproducing raw complete-output and timing-input
checks. Avoid indiscriminately adding compiler stdout, which may contain100MB
QBE: pin its separately retained/archive location instead.

Root subsequently corrected this selection too: the collector now includes
`*manifest.json`, includes stdout/stderr files up to1MiB, and explicitly records
larger raw outputs as external pinned artifacts. These are resolved audit
findings, not outstanding blockers; the final capsule must retain the external
archive locations needed for those larger outputs.

The collector correctly refuses unfinished/unsealed guards and verifies its
reopened capsule. Run it only after all intended runs are sealed. Its summed
guard seconds measure execution-lane occupation, not all wall time, agent
reasoning, archive work or unavailable token/quota accounting. Its constant
`productionChanged=False` is a reporting assertion; the final Git/source and
selector review must establish that separately.
