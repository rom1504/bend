# RNFA02 local-row acquisition failure: static diagnosis

The combined checked B1 passed its strict build, then the first full-library
acquisition failed before producing a module or receipt. Preserve
`selfhost/build/phase48/combined-rnfa02-full/emit-00/stderr.log` and
`process.json`. The process used a 1,024 MiB Node old-space limit, returned -6
after 35.7839 seconds, reached 1,190,522,880 bytes process-tree RSS, and had at
least 26,839,740,416 bytes system memory available. This is a bounded Node heap
failure, not a system-memory-floor rejection. No heap increase is proposed.

The last reducing mark-compact retained approximately 925.7 MiB. That shows a
large reachable heap near failure; it does not identify its owner or prove an
infinite planner, cache leak, output-size explosion, or V8 regression.

## Static findings

- Frozen RNFA02 manifest: 92 unique existing module paths, no duplicate textual
  definition names, no patch backup artifacts. Strict checked acquisition also
  passed. No manifest dependency defect was found.
- New composite planning only runs when the original region plan returns empty
  code. It retains scalar-input and flat-array-record-output admission; its
  helper walk retains depth <16, at most 32 helpers, and shared 32,768 fuel.
- The A literal adapter only runs after a non-strong region plan and empty code,
  and requires a bounded syntactic ALeaf/ANode witness before region_prefix.
  The original plan, composite plan, and literal plan can therefore perform
  separate bounded walks. Their budgets restart between attempts. There is no
  new planner reentry from these selection functions.
- Typed array proof delegates normalize element/telescope terms and accept
  canonical U32/F32 operations. Their new call chain does not recurse back into
  composite or literal-root selection. Pair and array proofs contain no new
  unbounded type traversal.
- The native candidate changes JW String.append emission only. The finite-F32
  candidate transforms only typed canonical finite F32 literal leaves. Local-row
  itself has U32 literals, but library mode retains nonnative Base roots too;
  source-local absence of F32 cannot exclude whole-library F32 work.
- The source-aware Base cache and driver are byte-identical to checked array06.
  Cache content/creation and marshalled ownership still need dynamic evidence;
  unchanged producer bytes alone do not rule out a candidate-specific input or
  retained graph difference.

## Cheapest discriminator for root

The frozen `snapshot/tools/typed-driver.mjs` already checks BEND_TYPED_TRACE at
line32 and enables codec ABI onPhase events at line210. Its phase labels cover
source discovery, loading/elaboration, checking, pruning, annotation, runtime
layout validation and emission. A root-owned bounded diagnostic at the same heap
can identify the last entered/returned exported API without a proxy or a source
edit. Trace bytes and any failed diagnostic remain distinct from clean timing.

If the failure reaches JS emission, per-definition entry/return observations
around j_l_def_callback and root planner selection can distinguish pair/batch
scalar traversal from row.probe composite traversal. A save-JS API derivative
would be diagnostic only, and must not replace the checked emitter identity.
If the failure precedes emission, backend-plan ablations cannot explain it.

No target or Node job was executed for this static diagnosis. No frozen source,
consumed tool or failed evidence was edited. A cause remains unproved.
