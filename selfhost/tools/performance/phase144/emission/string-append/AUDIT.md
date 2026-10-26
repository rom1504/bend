# Isolated source admission and register-transport review

Status: source review by the implementation author, **not a second independent
reviewer**. No targets ran during preparation. Root owns checked/native evidence
and acceptance. This audit does not promote the source or runtime.

The parent is qualified Phase143 source SHA
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
The isolated candidate is `append-source01`, SHA
`913b0987502a1b420fc905836afc663995737b8e60498df58e2f006a4b022601`.
The Phase144 composer independently replays declaration overlays and preserves
the original complete verifier/proof declarations. The runtime remains the exact
qualified Phase128 `runtime-borrow01/runtime.o` SHA
`9b3f57afb46b4db8c63f6f3c5f1af1194e0854a7329de28f25d2e11aef887749`.

## Admission boundary

1. `db` is `KDef.native` (source47,5743). The original diagnostic mislabeled it
   `owned`; the receipt is retained and diagnostic version02 corrects the label.
2. A native-library marker is not itself intrinsic substitution. Actual native
   lowering uses `nc_native_def`/`nc_native_marked` (32146–32161) and explicit
   Foreign/Absent classification (35067). Source-backed native library functions
   follow `nc_erase(book,dv(d))` through `nc_definition_plain` (35086).
3. The new predicate requires Def, exact arity2, no templates, no actual native
   primitive, and no Foreign/Absent body. Global `j_fusion_def` remains unchanged.
4. All existing append-equation, finite syntax, parameter/result quantity and
   closed-owner predicates remain exact. Neither constructor nor function name
   determines admission. The equations forbid changed heads, reordered/effected
   evaluation, changed suffixes, arbitrary callbacks or different recursion.
5. The existing forwarding factory still checks its exact two-parameter,
   one-result shape and reserved local namespace. On a dynamic refusal it uses
   the exact old worker body, not a newly reconstructed substitute.

An actual native intrinsic bearing append-like fabricated metadata must still
refuse: its executable semantics may differ from its source body. The finite
suite tests that distinction explicitly. Invalid metadata tests exercise pure
predicates only; they never execute reflected native IR.

## Existing runtime contract

The operation is unchanged `p125_rt_concat_typed` (runtime.c:4674–4703).

- It scans the complete left spine before mutation. Static locations refuse.
  Every RFC cell needs acquired count1 and a dynamic resolved payload; a unique
  wrapper around a static payload still refuses. Raw dynamic cells rely on the
  existing ownership invariant, just as `ctr_take` does.
- A shared root, shared interior, or overlap with the right operand therefore
  cannot be mutated under valid runtime ownership. On refusal, neither input
  has been consumed, mutated or reference-count adjusted.
- On success, the sole mutation replaces the last nil tail with the already
  evaluated right operand. It uses the same capability/cold-constructor sealing
  rule as ordinary construction. It returns the original left root (or right
  for empty left). Heads, interior links and count1 wrappers remain intact.
- It does not bypass type checking or validate arbitrary externally forged heap
  graphs. The existing closed finite source datatype and checked source factory
  are required. The selected direct-QBE runtime is sequential; no new concurrent
  mutation claim is made.
- The entire operation is iterative. It introduces no native recursion and no
  extra scheduler transition. Source operand evaluation order remains unchanged.

`term_keep`/`rfc_seal` maintain the same owned-word invariant used by existing
constructor consumers (runtime.c:863–896). Merely seeing a root pointer is not
sufficient for uniqueness; the helper checks every spine node. Dynamic failures
and resource exhaustion are still subject to the existing runtime behavior;
this is not a proof of identical allocation/error timing.

## Why register-bank admission is safe

The unchanged helper reads `state->e` and constructor descriptor metadata,
accesses heap words, and may call `rfc_seal`/`rfc_wrap`/`heap_alloc`. These operate
on the Env heap; none reads or writes `P111State.regs`, stores its address, calls
Bend code or schedules a continuation. The helper receives owning Term words,
not a caller output buffer, and returns one Term word.

The added `p118z_runtime` symbol therefore preserves the live-register bank
certificate's actual obligation. The original full `p125p_import` verifier still
requires the exact `[ptr,u64,u64,u32,u32]` arguments, result width, declared local
types, distinct constructor identities, and arities0/2. Other transport guards
against state aliases/offsets and direct register reads remain unchanged.
Descriptor bit4 must be derived normally; the host must never patch it.

## Root-only execution plan

`jobs-v01.json` records ten sequential jobs and `commands-v01.sh` provides their
exact commands. They have not run. Every target job uses the existing Phase111
process-tree guard on CPU3,3GiB RSS,16GiB available-memory floor and64MiB file
limit. Root must coordinate that lane and stop on the first failed gate.

1. Check candidate source and acquire its API (90s deadline).
2. Require all23 new finite rows,12 original equation/factory rows and20 updated
   transport rows (30s). No native fabricated IR runs.
3. Inspect the actual library String.append certificate on a real checked source
   request; it should now be admitted (30s).
4. Emit the same two ordinary fixtures with the retained parent checked API and
   candidate checked API (120s each). `emit-v01.mjs` calls actual
   `p134e_plan/begin/next`; it does not generate or rewrite QBE. Each product is
   capped32MiB,20,000pieces. Ordinary verifier/admission remains inside Bend.
5. Read those products. The candidate direct String.append wrapper must contain
   one concat call and its original TRMC fallback, while the parent contains
   no concat call there. Both descriptors must retain sequential and live-bank
   capabilities. This is static placement evidence, not dynamic success counts.
6. Build/run each producer's two ordinary products with the unchanged aligned
   QBE builder and runtime (60s each,30s per builder child). Require the exact
   independently written11 String output lines and retained21 List/head/alias
   output lines, with no execution stderr.

These are correctness/capability gates, not a timing campaign. Before accepting
performance, measure dynamic success/refusal counts separately and clean paired
execution on a whole rendering request plus an unrelated append computation.
Some literal/shared inputs will correctly refuse; a fast path in generated text
alone is not a speedup. No full compiler image is acquired by this plan.

## First executed gates and a corrected inspection assumption

Root subsequently checked source01, ran all55 finite rows, confirmed actual
String.append admission, and emitted both ordinary fixtures with both producers.
Those gates passed. Native execution was still pending at this update.

The initial `inspect-products-v01.py` refused because it required live-bank bit4
in **both** producers. The historical List fixture already called concat and its
parent descriptor was11, without bit4. This is the known omitted transport
admission, not a candidate regression. String masks are15→15; List masks11→15.
Every other capability bit is unchanged. Both candidate String.append wrappers
contain one actual concat call plus the original TRMC fallback.

Version01 and its stopped root job are preserved. Version02 checks sequential
capability in both, requires live-bank bit4 in the candidate, and requires every
other baseline bit to remain exact. The bounded metadata inspection passed in
`selfhost/build/phase144/append-products02.json`. `build-commands-v02.sh` resumes
only the four original guarded native builds; it does not rerun completed jobs.
Future List timing must distinguish existing transport recovery from newly
admitted String append. The String fixture already has the same capability mask
and therefore avoids this particular confound.

## Composition

The three production overrides compose with current integrated-source01 because
that image changes none of them. Append `admission-v01.bend`,
`transport-v01.bend`, `controls-v01.bend` and `inspect-v02.bend` to the exact
integrated-source01 module inventory, adding only
`p125p_admitted,p118z_runtime,p127lb_controls` to the declared override list.
Root acceptance and fresh output-name coordination precede composition. Keep the
isolated source and its evidence immutable; the integrated image is a different
candidate requiring its own source and native gates.
