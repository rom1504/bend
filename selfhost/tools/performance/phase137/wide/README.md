# Four-bound wider borrowed-record rebase

Status: source-only candidate on qualified Phase134
`a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57`.
No target was checked, built or executed by this lane; root owns those gates.
The old Phase131 experiment is supporting prior evidence, not qualification of
this new compiler source.

Exactly four field-count limits change from 8 to 16:

| Declaration | Exact changed expression |
|---|---|
| `nol_fields` | `U32.is_le(left, 8)` → `U32.is_le(left, 16)` |
| `nol_ctor_fields` | `U32.is_le(da(ctr), 8)` → `U32.is_le(da(ctr), 16)` |
| `p131rg_width` | `U32.is_le(width,8)` → `U32.is_le(width,16)` |
| `p118b_project_borrow` | `U32.is_le(count,8)` → `U32.is_le(count,16)` |

The current parent implementations match the audited Phase131 wider module after
those single-expression substitutions. `prepare-v01.py` additionally proves a
source-text reconstruction property: reversing the four changes restores every
parent source byte before the control appendix. It records each declaration's
old/new hashes and verifies the exact unchanged 91 protected verifier bodies,
11 proof declarations, ordinary entry and late field template. Every other
original declaration is identical, allowing only the new appendix separator
after the final original declaration. There is no additional optimization pass.

The four guards admit the layout and its exact derived runtime-import contract.
They retain held-root provenance, root/child alias rules, scalar-only nonescaping
results, opaque-field restrictions, source telescope/dependency checks and
fallbacks. Constructor count, parameter count, continuation limits and packed
single-field constructors are not widened. The late inline read template remains
at its existing width bound; wider reads use the existing checked runtime helper.
Its scratch capacity and independent pointer/buffer verifier already admit 16
fields (128 bytes within 2,048 bytes). Runtime source/object remain unchanged.

The 17 finite predicates are the corrected Phase131 suite, copied exactly with
the private control prefix renamed `p131w_`→`p137w_`. They cover widths 8/9/16,
width17 and packed refusal, exact/mismatched/unknown constructors, state/result
types, insufficient/unknown/128-byte buffers, and unchanged late-template refusal.
These are finite contract screens, not exhaustive proofs of arbitrary record
telescopes or runtime ownership behavior. The previously incorrect Phase131
emitter-ID fixture is not reused; the corrected independent verifier catalogue
uses the original `p111v_put` metadata.

Source-only composition has run:

```sh
python3 -B selfhost/tools/performance/phase137/wide/prepare-v01.py \
  --out selfhost/build/phase137/wide-source01
```

Produced source SHA256:
`863e28f8bba8a285332875ce99bf82a20d2ea3052c6f4b6aed3606b0d67485b5`.
The exact changed-declaration audit and input identities are in
`selfhost/build/phase137/wide-source01/manifest.json`.

Root-owned next commands, each inside the existing resource guard:

```sh
python3 -B selfhost/tools/performance/phase111/check-api.py \
  --source selfhost/build/phase137/wide-source01/compiler.bend \
  --out selfhost/build/phase111/p137-wide-api01 \
  p88_cache_prepare p86_plan p111_runtime_admission p111_emit_admitted p137w_controls

node selfhost/tools/performance/phase137/wide/finite-v01.mjs \
  selfhost/build/phase111/p137-wide-api01/report.json \
  selfhost/build/phase137/wide-finite01
```

Follow with the separate query lane's two-by-two experiment: original versus
scalar-consumer source, emitted by parent versus wider producer, with identical
source paths, ordinary output oracles, ownership/fallback controls and actual
callsite inspection. Width admission alone does not prove the hot caller reaches
the reader, remove an escaping owned-result boundary or predict whole-compiler
speed. Preserve the qualified parent until separate integration gates justify
changing it. Do not fold a later inline-width experiment into this candidate.

Prior evidence and audit:
`research/phase131/wide-records.md` and
`selfhost/tools/performance/phase131/regions/identity-width-audit.md`.
