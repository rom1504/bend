# P5-003 — Equality derivation across genuine checked builds

- Owner: lexer-analysis; independent review requested from root/workflow owner.
- Started: 2026-09-22, Phase5; first falsifier bounded to about 30 minutes.
- Correctness: planned; measurement: none; decision: investigate.
- Scope: explicit derived B1 compiler-host artifact, standard unmodified JavaScript
  built-ins and ordinary compiler data. Not arbitrary reflective/getter/proxy ABI
  equivalence, not a checked bootstrap, and not a transformation of public H.

## Claim and cheapest disproof

The successful P4-024/P4-026 primitive-string equality substitution can recognize
new genuine checked B1 builds without admitting changed equality semantics. Keep
the original bootstrap API/report; verify its full provenance and pinned Base,
parser/emitter and build recipe. Require the reviewed runtime prefix and all
eleven equality dependency bodies, unique top-level bindings and supported
generated module structure. Reject unknown scope, duplicate/rebound dependencies,
unsupported sources, missing provenance or changed consumed files.

Insert only the existing primitive-well-formed-string guard; malformed strings
and all non-string values execute the original body. No compiler Bend source,
emitter, upstream or default artifact changes. Each output has a separate
derivation report and API identity/cache namespace, never a bootstrap sidecar.

Cheapest disproof: fail recognition or find differing value/error/demand behavior
on two newly checked, genuinely different isolated source builds. Stop for an
unclear binding/origin proof rather than broadening acceptance heuristics.
Source-level equality remains an alternative but risks disabling H's existing
native intrinsic and invalidates source self-reproduction evidence.

## Planned gates

1. Refuse changed body/dependency/runtime, duplicate/nested/rebound bindings,
   unknown module forms, forged/missing/incomplete/drifted lineage and existing
   destinations. Preserve structured failure reports when destination is fresh.
2. Two normal checked bootstraps in isolated projects, one containing a small
   deliberate diagnostic-only source variation; record real API/source hashes.
   This disposable variation is never promoted to production.
3. Derived/control Unicode, non-BMP, combining characters, malformed UTF-16,
   non-string fallback, early mismatch/exhaustion and staged-call controls.
4. Selected positive/parse/type/import compiler observations and emitted output
   equality for each corresponding build. Verify derivation replay and hashes.
5. Independent review before workflow promotion or any timing/full-source gate.

CPU2, Node24, 4 MiB stack/4 GiB heap for correctness; no timing claims. Fresh
output directories; freeze consumed sources/tools before execution. Maintained
helper location agreed with workflow owner: tools/development/equality.mjs.
Results, commands, retained failures and preservation links will be appended in
implementation/phase5/equality-derivation.md; root owns commits and strategy.

## First result — 2026-09-22, 21:58 UTC

Both genuine normal 54-export builds complete with different source/API hashes.
Each passes ten final focused helper groups (900 value pairs plus nine long
prefixes and scope/provenance/demand controls). The selected third compiler
attempt passes all 24 observations and six byte-exact emitted/executed program
pairs. Failed attempts one/two are probe fixture/directory errors, retained with
their consumed tools. Independent workflow-owner review led to stronger
parameter-shadow refusal; final verifier replay preserves both candidate bytes.

Correctness: these selected gates pass. Measurement: not run. Decision: helper
ready for reviewed optional workflow integration; no default/API/source change.
Pause timing until root schedules the combined-source comparison. See the
[implementation and evidence](../../implementation/phase5/equality-derivation.md).
