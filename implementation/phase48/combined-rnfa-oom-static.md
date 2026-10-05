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
  explicit new recursive type traversal. This initial finding did not examine
  strict operand demand deeply enough; the later rejection-order finding below
  supersedes any inference that normalization only received actual types.
- The native candidate changes JW String.append emission only. The finite-F32
  candidate transforms only typed canonical finite F32 literal leaves. Local-row
  itself has U32 literals, but library mode retains nonnative Base roots too;
  source-local absence of F32 cannot exclude whole-library F32 work.
- The source-aware Base cache and driver are byte-identical to checked array06.
  Cache content/creation and marshalled ownership still need dynamic evidence;
  unchanged producer bytes alone do not rule out a candidate-specific input or
  retained graph difference.

## Corrected predicate finding and trace confound

The initial graph inspection missed an evaluation-order bug despite correctly
finding no new recursion through composite/literal-root selection. Bend Bool.and
is strict. In RNFA02, j_array_effect_native demanded j_array_effect_definition
even when the call name was ordinary/nonnative; the definition helper's eager
binding then normalized the first live call argument as an erased type. Large
live computations can therefore be demanded by an otherwise rejecting predicate.
The lowerer supplied the reviewed array-effects-lazy-v1 overlay with kc fences
for native shape/arity, owner and erased telescope, and corresponding array
shape fences. The concrete premature demand is established statically. Its
attribution as the cause of the OOM is still a hypothesis pending reacquisition.

The earlier suggestion to set BEND_TYPED_TRACE=1 on the unmodified emit-worker
command was ineffective: emit-worker.mjs line21 deletes every BEND_* environment
variable before importing the driver. Thus the retained absence of driver stage
logs provides no evidence that execution stopped before the backend. The driver
supports stage/ABI tracing, but this worker's environment reset must be addressed
in a separately versioned diagnostic producer if tracing is needed later. Root
has deferred further trace work until the predicate correction is qualified.

RNFA03's strict checked build passes in 50.4437 seconds using the same 1,024 MiB
heap. Its full corpus acquisition is underway. The checked build alone does not
establish that local-row acquisition now succeeds or that the OOM cause is proved.
See [the current integration report](combined-rnfa-integration.md) for exact
successor identities and unchanged runtime evidence.

No target or Node job was executed by this agent for the static diagnosis or
report updates. No frozen source, consumed tool or failed evidence was edited.

## First-source reacquisition outcome

RNFA03 successfully acquires the same historical local-row source that failed
under RNFA02: `combined-rnfa03-full/emit-00/process.json` reports return code 0,
6.1255 seconds and peak process-tree RSS 553,205,760 bytes. Its exact checked
module receipt is `combined-rnfa03-full/modules/local-row.mjs.json` (SHA256
`332b3eefe73b52f2be6cfd4e990f51b75f3a472facd7fa730f4d27533e631cec`); emitted module SHA256
`822156fcf6deec02d910fd5e8e042616e600ff42d09386693d0efa0f92a4cb15`.

The source input and heap limit are unchanged; source comparison finds only the
lazy array-effects overlay changed. Success with roughly half the former peak
RSS strongly supports premature predicate demand as the failure cause. This
single before/after acquisition is not a memory benchmark or an independent
predicate-demand control; the latter remains pending. Root reports 13/23 source
acquisitions passed at this update, so no full-corpus pass or promotion is claimed.
