# Phase147: integrated native compiler profile comparison

The integrated compiler reduces the clean, fixed-source full build from **262.496s to 246.745s (6.00%)**. Independent diagnostic captures localize most of that gain: renderer/output CPU falls **8.225s (17.3%)**, and initial optimizer CPU falls **3.534s (12.2%)**. Together these explain 94.4% of the measured staged CPU reduction. Parsing, checking, registry preparation and independent verification remain substantial costs.

This analysis ran no compiler targets. Exact values, input hashes, all 23 stage comparisons and owner/leaf tables are in [profile-comparison.json](profile-comparison.json).

## Comparable inputs and measurement quality

Both compilers process the same 3,010,912-byte source (`00940ed5…fb5e`), Base carrier, serial runtime configuration and pinned QBE toolchain. The old qualified N2 image and new candidate N1 image have different identities. The candidate profiler regenerated symbol addresses, FIDs, source ownership, unwind data and stage markers from its own object and retained QBE. See [candidate profiler preparation](../../implementation/phase147/candidate-profiler-preparation.md).

Both captures emitted the same complete **117,232,528-byte QBE** stream, SHA-256 `dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010`. Both exited successfully with empty stderr and unchanged pinned inputs. This is a complete-output oracle for this fixed request, not a claim that every program or the new self-hosting generation has been qualified.

| Quality measure | Baseline N2 | Candidate N1 |
|---|---:|---:|
| Sampling period | 32ms | 32ms |
| Total samples | 7,794 | 7,405 |
| Exclusive-stage samples | 7,750 | 7,362 |
| Boundary/outside samples retained separately | 44 | 43 |
| Sampled-thread fraction of process CPU | 99.46% | 99.43% |
| Loss, delivery, handler and lifecycle checks | PASS | PASS |

All 23 required stage boundaries resolve with the same names, order and interval definitions. Quantitative within-stage sample attribution requires at least 500 samples; smaller stages still have measured milestone CPU durations, but their leaf distributions are descriptive only. Unknown owners/leaves remain in the denominator.

## Keep the clocks separate

| Clock | Baseline | Candidate | Reduction |
|---|---:|---:|---:|
| Clean full source-to-executable wall | 262.496s | 246.745s | 6.00% |
| Diagnostic compiler wall | 251.358s | 238.697s | 5.04% |
| Diagnostic staged thread CPU | 249.365s | 236.915s | 4.99% |

The clean build includes overlapped compiler emission/QBE execution, assembly and linking after preflight. Its emission+QBE pipeline is 256.054s → 239.702s; that is not an isolated compiler or QBE time. The baseline retained emitted IR, while the candidate checked it against the exact reference without retaining another copy. There is one full clean build and one full diagnostic capture per version, not a randomized repeated full-build campaign. Diagnostic relinking/instrumentation and the absent machine-build tail prevent treating its wall clock as the headline cold-build metric.

## Exclusive stage comparison

Thread CPU seconds below are disjoint milestone intervals. Positive deltas indicate more CPU. The optional final-verification subinterval is reported separately because it is nested. The JSON includes the remaining stages below one second.

| Stage | Baseline | Candidate | Delta | Candidate samples |
|---|---:|---:|---:|---:|
| Render/output and teardown until milestone exit | 47.469 | 39.244 | −8.225 | 1,224 |
| Raw generic/private lowering | 36.937 | 36.395 | −0.541 | 1,135 |
| Parse/load | 32.292 | 33.062 | +0.770 | 1,031 |
| Checking/publication | 31.546 | 31.561 | +0.015 | 984 |
| Initial optimizer | 28.861 | 25.327 | −3.534 | 789 |
| Observer composition and selected final admission | 20.064 | 19.841 | −0.223 | 618 |
| Registry preparation | 16.879 | 16.834 | −0.045 | 524 |
| First independent verifier | 8.323 | 8.234 | −0.089 | 256 |
| Annotation/reach | 6.200 | 5.956 | −0.244 | 185 |
| Erasure/finalization | 5.430 | 5.429 | −0.001 | 168 |
| Static preparation | 4.615 | 4.487 | −0.127 | 139 |
| Layout check | 2.516 | 2.381 | −0.136 | 72 |
| Proof report | 2.307 | 2.312 | +0.005 | 70 |
| Observer discovery | 2.298 | 2.253 | −0.045 | 68 |
| Observer permission | 1.370 | 1.353 | −0.018 | 40 |
| Initial private admission | 0.966 | 0.959 | −0.007 | 28 |

The nested conditional final verification remains **9.324s → 9.220s** (289 → 286 samples, below the within-stage attribution threshold). It is part of observer composition, so adding it to this table would double count.

## What disappeared, and what did not

The compact verifier is selected only at `p114s_open_functions`, `p114s_commit` and the changed-body admission path `p134v_check`. It keeps exact-name schema lookup and semantic rules, while carrying assignment/capacity facts in a compact numeric flow structure; scalar observations avoid unnecessary result products. Original raw verification, final independent verification and session verification remain selected unchanged. The large initial-optimizer improvement is consistent with eliminating work from repeated changed-function admission, not with skipping the final verifier. The interval named “initial private admission” itself is almost unchanged; do not confuse its name with all calls to admission helpers.

The first independent verifier stays 8.323s → 8.234s, and the nested final verifier stays near 9.2s. Their persistence is expected. Optimizing them would require a separately justified preservation strategy, rather than globally replacing `p113e_functions`. The compact candidate already passed complete-region controls and unrelated Lexer/Map/compiler slices; those regional 11.9–22.5% gains are not whole-build gains. See [verifier machine inspection](verifier-machine-inspection.md) and [integration audit](integration-audit.md).

Renderer changes replace avoidable intermediate textual work in `p111q_args`, `p111q_memory` and `p112a_original_stmt`. In the renderer interval, active `String.append` ownership falls from 242 to 95 samples, and `p111q_memory` from 135 to 40. Physical `p125_rt_take2` falls from 239 to 128 and `p118_rt_extend1` from 122 to 65. These are sampled observations, not construction counts. The same complete emitted bytes plus the stage reduction support removal of transient rendering work; the joint integration does not individually isolate all six changed definitions.

## Remaining hot regions

Counts below are candidate samples within each region; owner and leaf views overlap and must never be added. The JSON retains all available top rows, including unknown entries.

| Region | CPU | Leading active owners | Leading physical leaves |
|---|---:|---|---|
| Render/output | 39.244s | Unmapped 193; `p144e_body_tail` 149; `String.append` 95; `p111v_get` 43 | `p125_rt_take2` 128; `ctr_take` 96; `term_drop` 85; `p118_rt_extend1` 65 |
| Raw lowering | 36.395s | `nc_uses_term` 80; `lookup` 69; `nc_uses_list` 62; unmapped 49 | `term_drop` 112; borrowed `p88_string_eq_go` 84; `span_fade` 78; work loop 62 |
| Parse/load | 33.062s | `f_eq` 84; `f_grow_base` 49; `f_pattern_sub` 44; unmapped 43 | `term_drop` 114; `span_fade` 93; borrowed string equality 64; sink 56 |
| Checking/publication | 31.561s | `p131i_insert` 109; `book_final_seen` 57; `lookup` 55; `index_remove` 49 | `term_drop` 119; `span_fade` 83; unmapped 50; borrowed string equality 46 |
| Initial optimizer | 25.327s | `p111v_get` 81; `p111v_name_chars` 56; `p113k_get` 43; `p131i_insert` 41 | `term_drop` 95; `span_fade` 56; borrowed `index_hash` 44; work loop 42 |
| Observer composition | 19.841s | `nol_scalar_specs` 73; `p111v_get` 64; `lookup` 45; `p131i_insert` 32 | `term_drop` 95; `span_fade` 55; borrowed `index_hash` 40; work loop 29 |
| Registry preparation | 16.834s | `String.eq` 71; `String.append` 66; `p118z_runtime` 32; `p112w_ready` 27 | `term_drop` 52; borrowed `String.cmp` 49; work loop 32; `p125_rt_take2` 32 |

The strongest remaining hypotheses are structural, not another global cache by default:

1. **Continue the output-fragment work across complete bodies.** Rendering still costs 39.244s, with `p144e_body_tail`, string append and ownership leaves prominent. Registry preparation adds 16.834s and is unchanged. First separate unavoidable serialization from rebuilding/transferring intermediate fragments; a sampled string operation alone is not evidence that it is redundant.
2. **Remove repeated name/ownership work in raw lowering and the frontend.** Raw lowering is 36.395s; parsing plus checking is 64.623s. `nc_uses_term`/`nc_uses_list`, name lookup, publication/index operations and reclamation recur. Numeric identities or shared semantic facts should be tested across conversion, traversal and teardown, not with lookup-only microbenchmarks.
3. **Broaden compact semantic observations only where complete-region evidence supports it.** Initial optimizer still costs 25.327s and retains named verifier/contract queries; observer composition costs 19.841s. The original final verifier deliberately remains a separate guard. A new optimization must preserve this distinction and demonstrate whole-request savings.

These are hypotheses, not quantified future speedups. The current staged CPU total is 236.915s. Even deleting the entire remaining render stage would leave roughly 197.671s in this diagnostic clock; reaching a 100s cold build requires improvements across multiple large regions. A projection from one stage or a few sampled owners cannot justify that target by itself.

## Method preservation and limits

The consumed baseline summary method is preserved byte-for-byte under `selfhost/build/phase147/method-history/809e78ff4a47755597558c4c879b93e41c897a5885a97ae2fa619faab24ddc5f/profile-summary.py`. The maintained method now uses the generation-neutral title “Native compiler diagnostic stage profile”; its only difference is that title. SHA-256 changes from `809e78ff…c5f` to `1e7df772…a6f`; the computation is unchanged. The baseline controller and captures were not rewritten.

This comparison provides one controlled full-request observation per image and localization evidence, not confidence intervals, proof of per-function causality or recursive research acceleration. Small positive changes such as parse/load (+0.770s) should not be declared regressions without repeats. Generated-program quality is protected here by exact emitted output for this request; the complete phase report must retain the separate broader correctness, program-runtime and native self-hosting gates.
