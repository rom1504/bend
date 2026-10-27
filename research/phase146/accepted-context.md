# Retain the ordinary backend's existing accepted context

Source audit and isolated candidate, 2026-10-27. Parent is qualified Phase144
final04, `selfhost/build/phase144/final04-source01/compiler.bend`, SHA256
`865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed`.
No compiler or benchmark was run by this investigation. Source checking,
performance and selection remain separate root-owned gates.

## The smallest useful boundary already exists

`p128raw_session_finish` (55986) opens a `P114SLowered` with the original
`p114s_open_lowered`, optimizes its boundary, then immediately discards the
boundary through `p114s_close_lowered`. The boundary contains exactly the useful
facts: `P114SBoundary{original, ids, functions, valid}`.

`p114s_open` (48271) checks the complete raw/static original, constructs
`p114s_ids` (48241), and checks the initial direct functions. Success therefore
binds these IDs to this immutable original. Inline/commit preserve original and
IDs on acceptance and rollback; invalid cannot become valid. Final04's outer
`p114s_ranges` is identity, but the retained construction also survives the
original range wrapper. Later `p128raw_lowered` (55977) calls `p113a_verify`,
which repeats `p112s_verify` and reconstructs the same direct-verifier IDs.

The isolated [candidate](../../selfhost/tools/performance/phase146/context-v01.bend)
overrides **only `p128raw_session_finish`**. It retains that existing boundary
through the original transformations and original close/finish constructors.
On empty lowering error and a successful original opening, it checks **every
actual transformed direct function afresh**, using the held IDs, then runs the
unchanged array and transport namespace gates. The same assembled object goes
to checking and `p128raw_verified`/emission. Failed opening or lowering follows
the complete original `p128raw_lowered`, preserving errors and their precedence.
The independent late `p126bp_complete` and every protected verifier remain
unchanged. No global cache, new compiler data type, digest or equality walk is
introduced. The authority is the private local call graph, not an unforgeable
Bend constructor or a public Boolean certificate.

This removes one complete raw-body/schema/flow verification, one static-image
check and one `p113e_originals`/`ns_ctor_index` construction per accepted ordinary
request. A diagnostic raw-only helper rebuilds those two indices, permitting
separate attribution of judgment reuse versus metadata reuse.

## What should not be shared indiscriminately

There are several similarly named but semantically different indices:

| Product | Required payload |
| --- | --- |
| Raw verifier functions, `p111v_functions` (39908) | Validated name, arity and incoming count; capacity/error bounds |
| Direct original functions, `p113e_originals` (44396) | Arity/incoming plus flags/result for public-ABI checking |
| Direct constructors, `ns_ctor_index` (35510) | Constructor arity |
| Static constructors, `p112s_ctors` (41582) | Ordered constructor ordinal and arity, then effect exclusions |
| Emitter IDs, `p111q_ids` (40245) | Ordered output FID/CID ordinals |

These are not interchangeable KDef maps. Sharing a richer future constructor
table could eliminate hashing/traversal across several consumers, but requires
changing their projections and exact duplicate/error behavior. First test the
existing held-ID seam, which needs none of that conversion.

Direct ready signatures are **ordered prefixes**, not one all-function map:
using a full map would admit forward calls. `p134v_commit` (57808) already skips
unchanged direct bodies after header/body comparisons; adding another general
memo would duplicate an existing mechanism. A retained sequence of ready-prefix
maps could save construction but extend persistent-map lifetime and reclamation.
It is not yet supported by an exclusive measured budget.

Local schema also depends on the actual body and parameters. Inline/range
transforms can change it. Retaining old schemas for changed functions would be
wrong; deriving final schemas independently remains part of this candidate's
fresh transformed-body check. A compact schema/flow representation is a separate
promising experiment, not a free extension of raw acceptance reuse.

## Measured ceiling and negative evidence

Phase145 proves two raw/static checks see the same Lexer object and complete
27,479-object content. It does **not** measure their exclusive native time.
The entire later initial-verification stage is 159.53ms Lexer, 162.43ms Map and
12.37ms closures; raw/static checking is only part of it. These give loose
ceilings, roughly 13%, 8% and 3% of the corresponding diagnostic stage totals,
before retained direct checks and new transport overhead. They are not expected
gains. Final03's 56.25s initial optimization/check interval is likewise not a
duplicate-check budget and is not a final04 full-build measurement.

Phase142 previously attempted the incremental/session analogue. Its same-API
hosted complete-request results were Lexer +3.63% and Map -2.57%, with order
effects and no robust broad gain. That path retained prior-cache context/body
comparisons and did not test today's simpler ordinary pipeline. Preserve the
negative: source-level redundancy alone does not establish a speedup.

## Cheap gates and escalation

The new [24 finite controls](../../selfhost/tools/performance/phase146/controls-v02.bend)
use real `p114st_*` fixtures and call the original opening factory each time.
They compare full errors across baseline/raw-only/held-ID checks, assert expected
success and opening status, and cover changed bad bodies, callee order, public
ABI, duplicates, namespaces, malformed raw/static/effect data, fallback and
lowering-error prefixes. Version01's missing local type annotation is retained
as a source-check failure; version02 adds explicit types without changing cases.
The independent [eight supplemental controls](../../selfhost/tools/performance/phase146/supplemental-controls-v03.bend)
exercise the actual replacement entry on failures, rather than merely comparing
two invocations of the old fallback checker. Root owns execution of these gates.
Invalid IR is checked only, never executed.

Reuse Phase142 `same-request/diagnostic-v01.bend`'s complete original comparator
and 26 controls when testing conservation; its comparator includes effects,
whereas `p134v_boundary_same` omits original and IDs. Do not transplant its
incremental override or stack it with the cross-revision witness.

For a native falsifier, the existing Phase144 `verifier-lexer-slice01` and
`verifier/native-slice-v01.py` supply eight real raw bodies and complete metadata;
those are useful for the raw-only budget, but do not cover the whole accepted
context, optimizer or transformed-direct check. Prefer one same-API whole
open→transform→check comparison on Lexer/Map/closures, byte-exact final products,
then a native complete-computation proxy including initial acceptance, retained
state and destruction. Escalate to a compiler image only if the full region
improves beyond noise with an acceptable source/memory cost. Reuse existing
Phase145 same-source fixtures and strict product oracles; do not infer gains
from counters or omit original acceptance from the measured work.
