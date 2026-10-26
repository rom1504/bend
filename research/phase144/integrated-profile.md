# Integrated Phase144: measured work removed and remaining costs

The new capture confirms that the parser index and shared ownership facts removed
the work they targeted. It also shows why further progress requires several
stages: initial optimization and verification remain essentially unchanged,
while registry construction and output still consume 65.23 diagnostic seconds.

This is an **offline comparison of two completed captures**, with no new target
executions. [Derived data, exact artifact pins and reproduction method](integrated-profile-v2.json)
retain all stage intervals, active owners, physical leaves and original receipts.
The earlier summary is preserved; v2 corrects the register-helper classification
(`p111_set_regs`, rather than a nonexistent name containing `register`).

## Identity, quality and clock boundaries

The new engine is integrated source
`992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b`,
N1 program object `f08bda546c00a7671634d66eb19ac4778b132701fe49589c66da3030218f3269`.
Its actual compiler QBE is 117,055,961 bytes, hash
`4b913b26a9f007aa9296cb99be189f636d9ff32b49a6150c634219859764394a`.
Both engines compile the same frozen Phase142 source, hash
`15f5cada2710119cce19a0cfe961c21f61edc5f0b048f90359090a0c1817dac1`,
and produce exactly 115,909,112 bytes, hash
`1dca2d0ea568b2e28db87066ed10dbef01a385f4e38dd4d18c99e1074d128643`.
Source, object, linked binary, carrier, sampler and marker identities remain
separate in the receipts. This profile does not itself establish native qualification.

The integrated capture has **9,158 samples at 32 ms, zero drops or overruns,
an intact handler and 99.545% sampled-thread/process CPU coverage**. All required
markers passed order and multiplicity checks, including the exact Lexer pilot.
The three new ownership entry points are explicitly mapped to their corresponding
old boundaries. The optional final verifier occurs once here; its interval is
nested, not additive. Interior profiles exclude one sample at each boundary;
intervals below 500 samples are descriptive distributions only.

There are 8,798 known dispatch IDs, 362 samples without a resolved active source
owner, and 428 without a resolved physical function. The difference between
unknown IDs and unknown owners is retained. All remain in the denominators.
The selected libc unwind table recovers all 411 eligible callers; it does not
recover the other 8,747 callers or constitute a logical Bend stack.

| Clock/scope | Before | Integrated | Change |
| --- | ---: | ---: | ---: |
| Clean ordinary runtime, fresh matched source requests | 304.534 s | 266.862 s | −12.37% |
| Sampled stage diagnostic, original runtime family | 330.816 s | 294.871 s | −10.87% |
| Separate integrated serial-runtime request | — | 249.679 s | Not profiled here |

These are single observations, without a confidence interval. The diagnostic
runtime also changed from the phase-specific marker implementation to the
qualified generic implementation. Diagnostic/clean ratios are 1.0863 and 1.1050;
they combine instrumentation, layout and temporal variation and are not precise
overhead estimates. Therefore stage deltas explain the location and mechanism
of gains, but cannot be apportioned mechanically into the clean 12.37% result.
The separate serial-runtime binary must not inherit this profile's timing claims.

## Disjoint stage budgets

These are entry-to-entry wall clocks, including intervening continuations and
reference management. They are not exclusive source-function timings.

| Stage partition | Before | Integrated | Difference |
| --- | ---: | ---: | ---: |
| Base preparation | 0.231 s | 0.233 s | +0.002 s |
| Frontend through erasure | 117.000 s | 94.833 s | −22.168 s |
| Admission, static preparation, raw lowering | 50.806 s | 44.819 s | −5.986 s |
| Initial optimizer and first independent verifier | 64.031 s | 64.431 s | +0.399 s |
| Observer work and selected final admission | 28.434 s | 25.150 s | −3.284 s |
| Registry | 18.284 s | 17.400 s | −0.884 s |
| Render/output/exit tail | 51.845 s | 47.831 s | −4.015 s |

The output-opening interval is below 0.1 ms. The disjoint sum is 294.697 s,
covering all but approximately 0.174 s of the child wall observation.

The useful finer boundaries are:

| Computation | Before | Integrated | New interior samples |
| --- | ---: | ---: | ---: |
| Parse/load | 47.950 s | 35.906 s | 1,121 |
| Checking/publication | 37.327 s | 37.672 s | 1,175 |
| Checked context | 3.959 s | 3.921 s | 121 |
| Annotation/reach | 6.976 s | 6.458 s | 200 |
| Layout check | 2.560 s | 2.531 s | 77 |
| Erasure/finalization | 15.785 s | 5.899 s | 182 |
| Static preparation | 4.986 s | 5.020 s | 155 |
| Raw generic/private lowering | 44.631 s | 38.690 s | 1,207 |
| Initial optimizer | 41.635 s | 42.945 s | 1,340 |
| First independent verifier | 22.396 s | 21.485 s | 669 |
| Observer composition and selected final admission | 24.219 s | 21.599 s | 673 |
| Registry preparation | 18.184 s | 17.300 s | 539 |

The conditional final-verifier entry-to-writer interval is 10.351 s, versus
10.056 s previously. It lies **inside** observer composition; summing both would
double-count it. Small movements in unchanged stages are not established regressions.

## What disappeared, and what merely moved

**Parser scans:** active `f_find` samples fall from 480 to 27; parse/load falls
12.04 s. That is consistent with the indexed prior/local lookup changes, which
cover more actual consumers than the initial four-site hypothesis. The remaining
parser is distributed: `f_eq`105, `f_grow_base`55, `f_pattern_sub`34 and
`f_ctor_lookup`31 samples. `f_eq` delegates to borrowed string equality. Further
optimizing the already-removed `f_find` scans cannot recover the remaining 35.91 s.

**Ownership:** active `nc_ctor_owned` falls from 610 to zero samples. Erasure
shrinks by 9.89 s, raw lowering by 5.94 s, and observer composition by 2.62 s.
The request-local ownership view replaces repeated whole-book searches while
preserving first-match semantics and fallback. Zero active samples do not prove
zero calls or zero replacement cost: synchronous private workers can retain an
outer owner, and catalogue construction/querying/destruction remain charged to
the real intervals. The transfer across multiple stages is stronger evidence
than a helper-only microbenchmark.

**Renderer:** output-tail `String.append` falls from 350 to 240 samples while
the tail drops 4.01 s. Whole-request append samples fall 488→385. The body-tail
change flattens the existing reversed chunks directly into the caller suffix,
removing an extra complete-body copy. `p111q_body_text`104→0 and
`p144e_body_tail`0→110 primarily show a moved implementation, not eliminated
flattening. `p111q_memory`136→135 is unchanged: individual instruction strings,
number/name formatting and remaining construction still need work.

## Residual active and physical costs

Active families below use disjoint name sets, but are **not** independent of the
physical view or the stage budgets. Count×32 ms is an approximate diagnostic
CPU equivalent, never clean time or an achievable speedup prediction.

| Active family | Samples | Whole-capture share | Approximate sampled CPU |
| --- | ---: | ---: | ---: |
| `p111v_*` verification helpers across stages | 1,343 | 14.66% | 42.98 s |
| String append/equality and `p88_string_eq` | 776 | 8.47% | 24.83 s |
| Patricia/index operations (`p131i_*`, `index_*`) | 637 | 6.96% | 20.38 s |
| `lookup` and `constructor_exists` | 484 | 5.28% | 15.49 s |
| `p113k_*` optimization fact helpers | 268 | 2.93% | 8.58 s |
| `nc_uses_term` and `nc_uses_list` | 156 | 1.70% | 4.99 s |

`p111v_get` alone has 485 active samples. In the selected source it hashes a
String and searches a KDef-backed index; `p111v_put` constructs a wide KDef
record, and `p113k_get` obtains such a record before extracting scalar facts.
`p111v_name_chars` repeatedly validates string spellings. Compact per-function
identities/facts remain a substantive hypothesis **across** optimization and
verification, with the original independent gates retained. Eliminating only
the two final gate intervals would neither be legitimate nor reach 50 seconds.

Physical `term_drop` and `span_fade` account for 1,482+764 samples, **24.53%**,
down from 2,624 samples but still widespread. Take helpers account for 922
(10.07%); constructor helpers 424 (4.63%). Direct `p111_set_regs` costs 201
samples and selected libc leaves called by it another 411: the disjoint union
is 612 samples, **6.68%**. These views overlap active source owners; adding them
to the previous table is invalid. The separate serial-runtime result provides
a reason to investigate that execution path, but it has no fresh profile yet.

## Highest-value next questions

1. **Compact verifier/optimizer facts:** test a complete real function, charging
   table construction, update/join, lookup and destruction, while comparing the
   original verifier result. The 64.43 s optimizer/first-verifier region is
   unchanged and has broad source evidence. Do not count all `p111v_*` time as
   removable lookup time or bypass independent validation.
2. **Remaining output construction:** registry plus output is 65.23 s. The
   registry includes continuation-region discovery and up to six passes, not
   just symbol numbering. `p112r_buffer_sites` also reconstructs candidate
   scratch names inside scans. A small allocation-free predicate can be tested
   separately; a larger output change must measure a complete body and preserve
   exact bytes, not merely rename or move flattening.
3. **Constructor existence and real frontend work:** `constructor_exists` is
   still a linear top-level/child search: 142 checking samples and 81 checked-
   context samples. An exact shared view may transfer the ownership lesson,
   but its observed approximately 7.14 s entire-helper ceiling is modest and
   cannot explain all 37.67 s of checking. Parser and checker improvements now
   need evidence of a different dominant computation.
4. **Representation/runtime costs:** widespread drop/take and register-bank
   costs motivate preserving borrowed values and reducing intermediate records
   across whole computations. They do not justify attributing every reclamation
   sample to one allocation source. Profile the faster serial runtime before
   estimating how much of this category remains there.

The successful changes removed repeated semantic searches and a redundant copy.
The residual is no longer dominated by those same searches. Reaching a 50-second
request requires improvements across execution, optimized IR/facts and emission;
there is no measured single helper whose removal establishes that outcome.

Reproduction, offline only: run
`python3 selfhost/tools/performance/phase144/profile/integrated-summary-v2.py`
after preserving/removing its generated destination in an isolated replay copy.
It refuses to overwrite existing evidence, authenticates actual captures and
uses the existing profiler's ELF/context/physical attribution rather than
executing a compiler. No capture, compiler source or production selection changed.
