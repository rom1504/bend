# Reuse actual successful verifier judgments

Experimental, not selected or native-qualified. No original declarations are
overridden. Active module `core-v02.bend` is appended with `controls-v01.bend` to
qualified Phase137. `core-v01.bend` and failed API01 remain immutable evidence of
a source match-order refusal. Checked source02 SHA-256:
`dbab7a102a2f039c1cece4a6866c7188b792cc4bd4a379051266b0f52f16e538`.

## Interface and trust

- `p140v_check(current: P113DProgram, prior: P140VCache) -> P140VChecked`
  is the cached counterpart of `p113e_verify` / `p113d_verify`.
- `p140v_open(current, prior) -> P140VOpened` returns the ordinary exact optimizer
  boundary plus the successor cache and counts.
- `p140v_array(current: P113AProgram, prior) -> P140VArrayChecked` additionally
  reruns the original array/transport namespace checks, matching `p113a_verify`.
- Count order is raw hits, raw misses, private-function hits, private misses.

The initial cache is `P140VEmpty{}`. Retain only caches actually returned by a
successful fixed-producer session. They are private proof provenance, not a
persistent artifact schema and not unforgeable data accepted from arbitrary
callers. No cached successful Boolean is accepted without its retained exact
program input. A forged `P140VCache` remains outside this internal contract.

Use separate pre-inline and post-inline slots when integrating the wrappers.
Publish a successor request's caches only after complete request success. An
error returns an empty proposed cache; the session may retain the previous
committed state for a later retry. Source/producer/runtime changes invalidate
all retained caches.

Exact ordered raw headers and constructors preserve raw/direct original IDs.
Exact ordered private headers preserve ready-map context, including absence.
Every reused body is exactly equal; changed/unknown bodies use original body
verifiers. Global metadata, capacity, duplicate, main, and static-image checks
still run. Namespaces still run. Every current direct signature is published in
its original order. The final `p126bp_complete` projected verifier is unchanged.

See [source audit](../../../../../implementation/phase140/audit/optimizer-reuse.md)
for the whole pipeline and remaining opportunities. In particular, the final
projected verifier alone does not cover all generic segment bodies: this cache
reuses actual prior judgments; it does not delete that verification obligation.

## Evidence

- `selfhost/build/phase111/p140-verify-api02/report.json`: checked18 exports;
  guard12.52s, peak1.61GB.
- `selfhost/build/phase140/verify-finite02/report.json`: all25 finite controls.
  First host adapter expected `:pass`; the actual existing formatter emits
  `PASS `, so `finite-v02.mjs` fixes only that observer. All25 underlying results
  already passed in retained failed finite01.
- `selfhost/build/phase140/verify-screen01/report.json`: two actual substantive
  fixture edits, fresh raw lowering on each side, three alternating-order pairs.
  Guard24.69s, peak435MB. Original verifier is the independent oracle. Complete
  opened state matches, including IDs; array wrapper error matches. An invalid
  raw body is rejected with the identical error and publishes no ready cache.

| Edited workload | Raw hits / total | Private hits / total | Warm/fresh verifier ratios |
| --- | ---: | ---: | --- |
| Lexer shift13→12 |264/265|30/31|0.225,0.269,0.186|
| Map multiplier31→29 |665/666|34/34|0.109,0.212,0.176|

These are **hosted isolated-verifier** measurements, not native performance or
complete request gains. They include equality and current metadata/static-image
checks; they exclude parsing/preparation/raw lowering and acquisition, which the
receipt reports separately. Small sample/JIT effects are evident. No full image
or native compiler was rebuilt for this experiment. Prior IR retention, eventual
reclamation, repeated private transformations and full final projection remain
costs to measure at integration.

Reproduce by using `phase140/prepare.py` to append the two modules, the standard
checked API exporter for the18 exports in API02's receipt, then guarded
`finite-v02.mjs` and `screen-v01.mjs`. Supply fresh output paths. The observer
pins its methods, API, source/toolchain inputs and fixture identities; it never
implements compiler transformations on the host. Pure malformed-IR controls go
only to the verifier, never to generated native execution.
