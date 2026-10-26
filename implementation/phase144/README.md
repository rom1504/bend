# Phase144 — profiler-led cold compilation

The final same-source cold build takes **247.000 seconds**, versus a fresh
**319.652-second** Phase143 baseline: **22.73% less time**, or **1.29× throughput**.
Compiler execution falls **304.534→231.682 seconds** (23.92% less); QBE,
assembly and linking take another **15.318 seconds**. The **50-second target is
not achieved**. These are controlled single observations in separate windows,
not confidence intervals.

[Design](../../design/phase144/README.md) ·
[Exact metrics](final04/metrics.json) ·
[Evidence inventory](evidence01/inventory.json) ·
[Final composition](../../design/phase144/final04-composition.md) ·
[Program-quality evidence](programs/final04-quality.md) ·
[Profiler findings](../../research/phase144/final-profile.md) ·
[Reproduction guide](../../selfhost/tools/performance/phase144/README.md).

## Measurement and checkpoint scope

The frozen input is Phase142 source `15f5cada…dac1`, 2,946,225 bytes. Each
request starts a new native process on CPU3 with the same immutable prepared
Base. It reuses no source-specific semantic state or generated machine objects.
OS caches are not flushed. Compiler acquisition and qualification are charged
separately. Including request/build supervision, the comparison is323.488→249.231s. The complete figure adds fresh compiler execution and machine
construction; it does not include source-independent supervision.

| Observation | Compiler request | What changed |
| --- | ---: | --- |
| Fresh qualified Phase143 N2 | 304.534s | Current baseline |
| Source01, original runtime | 266.862s | Parser index, shared ownership facts, rendering and dead capture |
| Same Source01 object, serial runtime | 249.679s | Runtime-only causal comparison |
| Final03 N2, serial runtime | 251.861s | Append admission and positive predicates |
| Final04 N2, serial runtime | **231.682s** | Remove unprofitable append admission and outer range pass; batch prefix-disjoint query |

Source01 saves 12.37% with complete original QBE equality. Relinking that exact
object with the serial runtime saves another 6.44%. Do not add these percentages,
kernel improvements or diagnostic stage clocks to the final measured gain.
The final03 composition did not demonstrate an extra compiler win. Its separate
self-source request is250.296s and uses a different input from this comparison.

Final04 emits115,914,052 bytes for the frozen input. Its full source contains
64,751 physical lines and7,020 definitions, versus63,983 and6,939 in Phase143:
**+768 lines, +81 definitions**, with the same683 laws. This is an optimization
campaign, not a source-size reduction. Final04's native self-product is117,187,645
bytes. Text-size reduction is not the source of the gain.

The independently qualified final03 checkpoint remains pinned in
[candidate.json](candidate.json) and [qualification.json](qualification.json).
Final04 is now independently native-qualified. Its precise policy scope is recorded separately
in [final04/candidate.json](final04/candidate.json) and
[final04/qualification.json](final04/qualification.json);
those immutable final03 receipts are not overwritten. Installed/default selection
remains unchanged. Keep Phase137 and Phase143 recovery paths.

## Work removed

- An exact parser-prior index preserves first-prior and shadowing behavior while
  avoiding repeated scans. The actual extracted native parser falls44.572→31.175s
  with complete graph/checksum agreement. That is not a30% whole-build gain.
- Request-local constructor ownership facts survive preparation and actual
  erasure, so consumers stop rescanning immutable declarations.
- Body/footer flattening shares a final traversal and removes intermediate
  String construction. An unobserved rollback capture is removed only from the
  native session adapter; the original generic rollback implementation remains.
- A guarded runtime uses ordinary reference-count word updates with **one Bend
  heap mutator**. Overflow, final-owner and reclamation behavior remain. Compute
  pools, GPU and incompatible entry modes are refused. Detached host IO workers
  still exist; arbitrary concurrent foreign embedding is outside the contract.
- Positive Boolean predicates avoid unnecessary continuation work in69 supported
  literal-lambda branches. The argument does not extend to arbitrary effects.
- Final04 omits the second, outer range pass and its commit, preserving the inner
  pass and independent final verifiers. On all45 program wrappers, this omission
  alone produces byte-identical machine objects despite different QBE text.
- The complete prefix-disjoint constructor query uses one exact local index.
  Rebuilding the index separately per declaration was slower and was rejected.

The broad String.append admission was **removed** after independent runtime
checks found an8.79% serialization regression. The heap-only helper/live-register
composition remains and preserves the RLE improvement.

## Profiler improvements and findings

The reusable native profiler now records exact stage entries, monotonic
timestamps and sample ordinals. Once/first/optional markers describe real
conditional stages. Missing or duplicate required entries invalidate attribution.
Source, retained object, linked runtime, ELF roles and dispatch pointers are bound
explicitly. An ELF ambiguity between a function and a same-named data symbol is
resolved by required role; ambiguous functions are still rejected. Nineteen
attribution tests and ten stage-contract tests pass.

Three full captures were used. Parent and Source01 profiles have zero lost
samples and over99.5% CPU coverage. Final03's actual serial-runtime capture has
8,681 samples, zero drops/overruns and99.497% coverage. Its complete output matches
the clean image. This is **not a final04 profile** and diagnostic time is not clean
execution time.

| Disjoint diagnostic interval | Phase143 | Source01 atomic | Final03 serial |
| --- | ---: | ---: | ---: |
| Frontend through erasure |117.00s|94.83s|88.45s|
| Admission/static/raw lowering |50.81s|44.82s|43.44s|
| Initial optimizer and first verifier |64.03s|64.43s|56.25s|
| Observer composition/final admission |28.43s|25.15s|23.35s|
| Registry |18.28s|17.40s|17.65s|
| Rendering/output/teardown |51.85s|47.83s|49.96s|

`f_find` falls480→31 active samples; the old `nc_ctor_owned` scan falls610→0.
Drop/fade's physical share falls24.53→17.04% between Source01 and Final03, while
product take/reconstruction and register transport remain. Physical leaves,
active source owners and stage attribution overlap and cannot be added.

A new opt-in [concat counter extension](../../research/phase144/concat-profile.md)
records attempts, visited nodes, success and refusal causes. Row32 refuses90.50%
of2,064 attempts; Unicode64 refuses54.53% of1,412. This explains why legal fast
paths can add work. Counts are not time saved. The independent counter fixture,
source audit and exact counters-off/on output checks have separate scopes.

## Generated-program performance

The original broad comparison used the frozen45 wrappers,44 timed plus a zero
control, with four position-balanced rounds across four products. The final03
serial product's descriptive geometric ratio was0.9740× the fresh Phase143
product. Some4–8ms cases are strongly quantized, so do not treat this as a precise
2.6% general speedup or a new upstream comparison.

The final04 gate freshly emits and executes every wrapper. **44 of45 final
machine objects equal the original Phase143 objects**; RLE retains the known
improved object. Thirty-five complete loaded products, including the runtime,
match already measured serial products exactly. Their timing evidence is inherited
explicitly; it is not a new measurement. The other ten cases receive eight fresh
alternating pairs each.

Row32 now measures509→505ms versus original Phase143, resolving the observed
regression. Relative to intermediate final03, restoring conservative append
admission sacrifices some wins: morning+2.61%, Unicode16+3.85%, Unicode64+4.96%.
The other six changed cases are approximately flat or slightly faster. Those are
honest tradeoffs, not a claim that every intermediate improvement was retained.
There is **no newly measured final04 full-corpus geometric mean**.

A suspected5.86% ray regression disappeared on recheck:371→371ms. The two products'
loaded sections and machine objects were identical. This was not an optimization
work-removal effect.

## Correctness and policy boundaries

Final04 is independently source-checked and passes198 finite controls. The101
protected declarations and11 inherited proof declarations retain exact bodies.
Three separate Boolean chooser laws are independently accepted by BendTT/Lean,
with a false law rejected. They prove total Boolean equalities, not the compiler,
its effect ordering or arbitrary applications of the transformations.

Qualified final03 N2 builds final04 N1, N1 builds N2, and N2 reproduces complete
Q2 as Q3. Both generations pass focused19; N2 passes all45 ordinary output oracles.
Native reproduction is not an independent semantic proof.

A supplemental batch smoke initially failed **cross-route byte equality**:
ordinary final04 skips the optional outer range pass, while batch/session retains
its existing pass. This is a genuine policy difference and is preserved as a
failed historical invariant. The independent checked hosted session route now passes separate cold A/B
and warm A/B/A/B exact products. Ordinary native Lexer, Map and closure products
also match the independent ordinary hosted compiler byte for byte. The final native
path, publish/EEXIST, Unicode readback, batch and A/B session smokes all pass
against the corresponding mode-specific references. This does
not restore ordinary/session byte identity. Broad incremental qualification
remains false. See the [route audit](../../research/phase144/final04-mode-divergence.md).

An earlier final03 host smoke incorrectly expected an ordinary IO return value to
set process status. Source review established that `IO.die` controls exit status;
EEXIST17 and file preservation were correct. The failed receipt and harness-only
correction are retained.

## Negative evidence, resource costs and next direction

- Compact verification gained1.9% in its slice after losing direct workers;
  explicit absence recovered workers and reached11.06%. Producer/conversion costs
  and the lack of whole-compiler evidence prevent a production claim.
- Selective product retry recovered five workers in that modified prototype,
  none in the original hot verifier. Its7.51% slice gain is unintegrated.
- Capturing a renderer constant timed out before IR. Narrower symbol encoding
  had only a3.51% text-size ceiling.
- Native-only source packaging cuts source44.8%, but actual compiler emission
  only11.62% and QBE text0.039%. This different-input experiment is not a qualified
  replacement or an additional same-source algorithm gain.
- Tiny register-copy specialization passed overlap and boundary controls, but
  its small paired loop was effectively neutral. The prepared full run was not
  executed and the runtime change is not selected.
- C emission succeeded. Clang O2 and O1 acquisitions both hit the explicit6GiB
  process-tree bound. There is no C executable or same-source C execution ratio.

One root-owned CPU3 lane serialized target work. Ordinary jobs retain3GiB tree
RSS and16GiB available-memory bounds; bounded agents inspect, prepare and review
independent work. Byte-verified hardlinks recover disk space without deleting
old paths or changing contents. Compiler acquisition, profiling, verification,
failed attempts and host overhead are accounted separately in the
[final cost ledger](costs-final02.md) ([data](costs-final02.json)).
All199 guards are closed, with no overlap:162.77 minutes total; acquisition64.79,
measurement48.16, native qualification22.58, profiling22.34 and other checks4.91.
Twenty-two failed guards account for15.34 minutes, including the useful partial
benchmark. Time outside these guarded intervals is unclassified, not measured
reasoning or idle time.
Token/quota billing is unavailable; wall time is not a quota measurement.

The broad timing observer hit its400s bound after707 observations. Its704 complete
rows were retained and the final complete case rerun, rather than repeating the
campaign. A successor observer reduces720-observation report writes1,442→47;
this demonstrates less serialization, not a measured67-second end-to-end saving.

The next substantial experiment should remove complete representation boundaries:
carry compact identities through one hot verifier computation, or stream already
ordered output fragments through a generic byte sink. Charge construction,
conversion, verification and teardown together. More local caches or runtime
helper tweaks cannot plausibly account for the remaining roughly6.7× compiler
execution reduction needed for a50-second build with the current15.3-second
machine-construction tail. See the [ranked remaining opportunities](../../research/phase144/final-opportunities.md). No recursive research acceleration,
new upstream ratio, PR comment or installed/default change is claimed.
