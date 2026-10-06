# Full direct compiler-image emission

The bounded 25 ms CPU-profile run **completed the exact B2 → B3 emission**.
It took 269.031668 seconds under the supervisor and peaked at 1,488,642,048 bytes
tree RSS (about 1,420 MiB). The unchanged limits were 420 seconds, 1 GiB Node heap,
2 GiB tree RSS and a 4 GiB available-memory floor. These are diagnostic timings,
not a clean throughput comparison or an improvement over Phase56.

Both complete images are **3,896,951 bytes**, SHA256
`3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`.
The 77 requested roots and 3,167 selected entries / 3,054 definitions match the
original generation. This inherits provenance from the completed checked-source
acquisition; it does not repeat the independent source self-check or install a
different image. All 3,012 compiler-source definitions are explicitly `@unsafe`.
Their earlier fresh check established type acceptance, with
`kernelChecked: false` and failed proof trust. The raw `inherited-exact-bootstrap` label denotes
provenance, **not a kernel proof or mathematical validity**.

## Method and accounting

[emission-profile-v2.mjs](../../selfhost/tools/performance/phase57/emission-profile-v2.mjs)
retains the complete Phase56 reproduction pipeline and calls
`jd_library_selected(context, selected)` once, without splitting the emitter.
Only emitted reachability and final library emission receive CPU captures;
all other stages run once without sampling. The frozen
[profile-v3.mjs](../../selfhost/tools/performance/phase57/profile-v3.mjs) uses a
25,000 µs interval. Separate sessions provide stage attribution without aligning
different clocks. Captures include marker IO and wrapper overhead; source counts,
setup, import, byte comparisons and final hashing are outside them.

[emission-profiles-v3.py](../../selfhost/tools/performance/phase57/analysis/emission-profiles-v3.py)
verifies worker and supervisor lineage, original emission, image bytes, every
profile and summary, and the exact source-span inventory. It independently
recomputes frame self weights and sample counts, reuses the reviewed signed-delta
policy, then rehashes all inputs. Both weighted views are admitted. Separate
sample-count views agree on the leading frames. Inclusive stacks overlap and
must not be added together.

## Observed hotspots

| Stage | Function wall time | Capture time | Samples |
|---|---:|---:|---:|
| Emitted reachability | 93.197668 s | 97.376354 s | 3,701 |
| Unsplit library emission | 115.284440 s | 121.157472 s | 4,536 |

Self percentages below use the entire corresponding capture denominator.
The anonymous constructor-search frame is mapped by its exact byte span to the
generated `j_found_ctor` definition.

| Frame | Reach weighted % | Reach count % | Emission weighted % | Emission count % |
|---|---:|---:|---:|---:|
| `kt` | 33.3868 | 33.5855 | 27.5512 | 27.8439 |
| `missing` | 30.2962 | 30.3972 | 23.5108 | 23.7654 |
| Anonymous frame within `j_found_ctor` | 8.0945 | 8.1329 | 6.5291 | 6.6358 |
| `run_loop` | 3.0132 | 2.9722 | 4.3703 | 4.2769 |
| GC | 2.8186 | 2.6479 | 3.9178 | 3.7478 |
| `lookup` | 2.7318 | 2.7560 | 2.2066 | 2.2046 |
| `sk_char` | 1.3567 | 1.2969 | 5.5903 | 5.5335 |

`kt` plus `missing` account for **63.683%** of reachability self weight and
**51.062%** of final-emission self weight. Those are disjoint self weights, not
allocation counts or a predicted removable fraction of runtime.

The source explains a concrete mechanism to investigate.
[j_find_ctor](../../selfhost/src/back/common/queries.bend) scans declarations and
calls `lookup(dc(d), name)` for each owner. An unsuccessful owner probe returns
[missing()](../../selfhost/src/core/term.bend), which constructs a KDef containing
two `atom("Absent")` KTerms. A **successful overall constructor search** can still
perform many such intermediate misses. The profile therefore does not imply that
the compiler is repeatedly encountering unknown source names.

Remaining callers include `j_arm_type`, which performs global constructor search
to recover matcher-row telescopes, and the intentionally unannotated
`jd_raise_head` fallback in [direct/model.bend](../../selfhost/src/back/js/direct/model.bend).
These are distinct from Phase55's completed annotation-aware arity fast path.
The exact caller/name distribution and visited-owner counts were not measured.
The [source comparison](implementation-comparison.md) records the remaining call
sites; counters by caller, constructor name and owner probes would distinguish
them before selecting a change.

Emitted reachability renders definitions to discover `JD_REF` markers: its name
does not isolate graph traversal. Final emission repeats relevant lowering work
and includes host exports. These captures show constructor-query/term-building
cost prominently; they do not show host-export marshalling as the leading self
cost or establish the gain from any proposed optimization.

## Preserved failure and limits

The first attempt sampled all stages at 1 ms. It hit the tree-RSS guard after
155.257536 seconds. Emitted reachability's compiler call had **returned after
94.480872 seconds**, but its profile finalization did not complete before the
kill. Eight earlier captures remain finalized and independently analyzed.
There is no B3 or final byte-equality result for that attempt. This is a failed
instrumented capture under the RSS guard, not evidence of a production compiler
out-of-memory failure.

The successor reduced sampling frequency and sampled only the two large stages;
it did not increase memory or time limits. Its successful capture is still
instrumented. Do not compare these runs as a compiler speedup.

Two data-only reader failures are also retained: the source inventory names its
identity path `path`, while receipts use `file`; the original emission records
`utf8Bytes`, while reproduction records `bytes`. Narrow successors repair those
joins without weakening any content, hash, size or whole-image byte assertion.

## Exact evidence

Raw paths are under `selfhost/build/phase57/`:

- `emission-profile01/` and `emission-profile01-supervisor/run.json`: failed
  1 ms capture, with eight finalized profiles.
- `emission-profile01-analysis/`: validated partial extraction;
  `workloadPassed: false`, `byteEquality: null`.
- `emission-profile02/` and `emission-profile02-supervisor/run.json`: complete
  25 ms successor, two finalized CPU captures and exact image equality.
- `emission-profile02-analysis/report.json`: complete independent extraction,
  SHA256 `398a873506ffa27b03c26c20f59b2fc35ed9b50e3193576716d8d58e696d15f4`.
- `emission-profile01-analysis-failure01/` and
  `emission-profile02-analysis-failure01/`: preserved reader setup failures.

The first worker, profiler and reader versions remain unchanged. This report
adds no compiler-source change, new bootstrap trust or promotion claim.
