# Prepared Base transport for the native QBE compiler

Phase130 changes how an already checked Base preparation is reconstructed for a
cold native compiler request. See the [design](../../design/phase130/README.md),
[contracts](../../design/phase130/contracts.md) and
[report](../../implementation/phase130/README.md) for current qualification and
measurements. The installed Phase102 CLI and Phase90 JS release are separate.

## What changes

The original private Phase88 carrier encodes integers as canonical decimal text.
Every request parses roughly325,000 such tokens, reconstructing the same checked
Base terms, definitions, fresh-name state, frontend catalogue and checker world.
A Phase129 profile established that this is repeated dynamic work, especially
visible in short requests.

The compact carrier encodes a U32 as two Unicode scalars in U+10000–U+1FFFF,
least-significant16 bits first. These are Unicode text, not raw native terms or
pointers. Encoding uses more UTF-8 bytes but fewer Bend String cells and avoids
variable-length decimal accumulation. String payloads retain their original
scalar lengths, payload and terminating LF. Node tags, fields, references, source
spans, bounds, readiness checks and object reconstruction remain shared.

A two-field cursor contains text and a finite mode:0 means failed,1 means decimal,
2 means compact. The entry chooses the format once from its first numeric token
and the explicit `p130-word-pair-v1:` stamp namespace. Numeric tokens never switch
formats in the middle of a carrier. Legacy decimal spelling, overflow and error
behavior remain checked. Arbitrary string payload is handled independently of
the numeric format.

The routing stamp is **not authentication**. The host must validate the complete
carrier and its receipt, exact producer API/cache, Base contents and absolute
source path/span, and term/span/world versions. `base/carrier.mjs` performs an
offline transport recoding with an exact inverse to the original carrier; it
neither checks programs nor constructs semantic AST/native heap objects. Bend
still performs reconstruction and all compiler transformations. There is no new
cross-request mutable cache, runtime ABI, thread support or machine backend.

## Experiments and reproduction

Tools live under `selfhost/tools/performance/phase130/`. Start with the exact
qualified Phase128 source/API/runtime identified in its candidate receipt.

- `base/carrier.mjs`: produce a fresh authenticated compact transport artifact.
- `prepare.py`: compose explicit checked-Bend source overlays; does not compile.
- `base-equivalence-v2.mjs`: compare complete old/new preparations and sharing,
  malformed inputs and source-to-QBE outputs against independent frozen evidence.
- `base/prepare-mode-proxy.py`: extract the exact native decoder for a cheap
  read/reconstruct/reclaim experiment before full compiler acquisition.
- `native-request.py`: authenticate inputs and capture a native request's raw QBE
  with a watchdog and a blocking timer. It makes no qualification claim.
- `timing-run.py`: retain the frozen three-request comparison, upstream tools,
  independent outputs and machine-build policy while selecting an authenticated
  carrier separately for each native compiler role.

Use fresh output directories and the existing CPU3 process-tree guard. The
report binds actual source, API, compiler images, carriers and qualification;
never apply a receipt to a changed source or treat a successful link as proof.
No installed selection changes automatically when an experiment passes.

## What the measurements mean

Decoder process time includes file input, reconstruction and reclamation. Cold
compiler request time includes source/Base/carrier reads and complete QBE output.
Upstream emits C; machine-build time is a separate clock. Native prepared Base
and cached runtime are explicit policy advantages, not evidence that source-Base
checking is free. N1 and N2 denote successive **native QBE compiler images**;
they must not be conflated with the earlier JS B1/B2 comparison.

This change targets compiler execution, not the speed of user-program code.
Exact emitted QBE, unchanged runtime and toolchain provide a stronger preservation
check than a noisy program-runtime rerun for programs whose bytes are unchanged.
The historical45 runtime wrappers and ordinary45 correctness inputs are distinct.
