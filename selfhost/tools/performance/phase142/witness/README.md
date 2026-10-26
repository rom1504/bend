# First raw-admission witness experiment

Append-only, fixed-producer experimental Bend entry on exact Phase141 source
`f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
No original definition is overridden. This directory was prepared without
compiler/target execution; root owns source checking, finite gates and timing.

Module order: model-v01, generic-v01, raw-bridge-v01, verifier-v01, session-v01,
then the independently authored controls-v01. All have `.bend` suffixes.

Exports for checked acquisition:

- `p142w_seed(seed: P86Seed) -> P142WSession`
- `p142w_named(session,path,text,hint,owner) -> P142WResult`
- `p142w_diagnose(session,path,text,hint,owner) -> P142WResult`
- `p142wt_controls() -> List<String>` (independent finite diagnostics)

`P142WResult` fields are `emission`, `cache` (the next `P142WSession`), `stats`
(the original concatenated front/raw/backend counter order), and `counts`.
`P142WCounts` fields are `retained`, `compared`, `mismatches`. Diagnostic mode
runs the original complete segment comparator on every claim. A mismatch stops
before optimization and returns an error plus the exact prior session; it cannot
be erased by downstream fallback. Ordinary mode omits that duplicate comparison.

## Authority and actual skipped work

`p142w_seed` fixes the actual prepared Base seed inside the capsule. A request
extracts both prior generic-owner cache and prior first-open verifier cache from
that single successful `P140SCache`; they cannot be supplied independently through
the experimental entry. New local runs exist only between raw production and the
first verifier. Successful emission planning constructs a new complete capsule;
errors return the prior capsule. As with the original pure session API, an IO
adapter must install the returned pending capsule only after successful output
completion/close. No native adapter is added here.

This is a trusted internal construction invariant, not a cryptographic/private
Bend datatype or a permission to accept forged/deserialized capsules. Low-level
`p142v_open`, raw functions and capsule constructors are not public authority
exports. Copying a valid capsule to branch two experiments is sound because each
branch obtains both prior caches from its own complete baseline. Crossing an
executing producer/schema epoch requires a new seed/session.

The original `p140og_old` predicates are retained exactly: complete raw global
admission, matching owner position/name, equal incoming fresh counter, clean
source/derived dependencies. Only that branch mints `retained=True`. Runs count
segments during the reversal that the original loop already performs. Counter
saturation disables subsequent witness use, never wraps into a trusted length.
Zero lengths likewise cause conservative fallback. There are no per-node IDs,
hashes, new dependency rules or extra complete-body scans.

The unchanged `p140v_context` still compares all ordered segment headers/flags
and constructors. Only **first raw-body equality** is bypassed on retained runs.
Prior verifier success, main/namespace/metadata checks, static-image validation,
all direct-function comparisons, the second array/raw verifier and the projected
final verifier remain original. A reused generic product does not authorize
reuse of a direct function after readiness-dependent optimization.

The generated entry segment uses the unchanged fixed scratch prefix and the
retained code body. Continuation bodies are retained. Marking modifies flags,
which the unchanged context gate compares. `p111_finish_show`, `p112s_finish` and
`p113d_finish` preserve raw bodies before this first admission boundary.

## Cost and stop rule

The experiment adds explicit orchestration copies so the old path remains an
independent oracle. Those copies are experimental cost, not simplification.
Do not wire production or acquire a complete native compiler merely for hit
counts. Early root attribution places Lexer raw admission near0.034s in a2.571s
warm request: the first boundary may have only a1–2% hosted ceiling. Preserve
that negative/foundation result if complete requests do not improve; use measured
adjacent boundaries before expanding the campaign. Distinguish diagnostic,
ordinary witness and original-session timing, including run allocation/reclamation.

Independent controls include genuine prior cache construction and deliberately
false local claims only in diagnostic mode. Those are verifier inspections of
invalid IR, never target emissions or executions. Root's source-family screen
must additionally test actual raw-loop minting, complete emitted QBE, edited
source, failure/recovery, revert, changed dependency and conservative context
refusal. Source checking and finite equality are not a whole correctness theorem.
