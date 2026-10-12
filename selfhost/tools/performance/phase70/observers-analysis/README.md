# Bounded observer analysis proposals

These files are source proposals and diagnostics. They are not the installed
compiler and must not be used as unchecked optimization permission. The root
agent owns every compiler, native and Node target execution. Source/data work
here uses CPU0; Phase69 artifacts remain closed.

- `capture-core*.mjs`: append-only checked-B1 diagnostic queries. V1/v2/v3 are
  preserved separately. They capture actual definitions and metadata before
  native emission; they do not implement an optimizer.
- `reference-analysis.py` and `reference-core03.json`: initial pure-data shape
  feasibility. The Python model predates demanded zero-argument and exact
  immediate-kind fixes. Its output is **not a correctness validator** or a
  production plan. The String refusal comes from the captured product metadata.
- `observer-layout-v1.bend`: bounded typed parameter, root and result schema.
- `observer-literals-v1.bend`: exact numeric literal kinds and demand barriers.
- `observer-analysis-v1.bend`: bounded CPS symbolic evaluation, ordered scalar
  residuals, scoped origins, return identity and structurally smaller recursion.
- `observer-plan-v1.bend`: checked-permission query bridge. The optional caller
  excludes bang owners before calling `no_observer_plan`.

V1 source snapshots were frozen when root copied them for the first checked
analysis-only build. Corrections after that point belong in fresh successors.
Do not rewrite a consumed snapshot or its raw query evidence.

An accepted plan is produced only through the schema and typed evaluator.
`NO_Layout` alone is insufficient proof: owner and field kinds live in `NO_Spec`,
entry kinds in parameter Vars, and virtual atoms carry exact kinds. Scalar
arguments/results and recursive slots are checked before residual construction.
A handwritten or mutated residual is not an accepted plan. Emission repeats
structural checks but trusts this closed construction boundary for semantic
kinds. A future public plan-loading API would require an independent validator.

No source-name admission exists. Native representation names identify runtime
layouts only. Result roots occur once each in a fixed wrapper, map to specific
parameter origins, and stay owned in the adapter while cursors are borrowed.
Both branches of a dynamic matcher share one global budget but keep separate
facts. Helper source IDs are invocation-scoped; generated runtime IDs are
fresh. `fresh` always means the next **counter** for `nc_id`, not an absolute ID.

Source checks completed before the first compiler query: balanced delimiters,
unique helper names, no collisions with production names, and no unresolved
nonlibrary helper references. Actual syntax, type, admission, refusal, emission,
runtime, raw/device and performance results must come from root's fresh gates.

Successor source gates:

- `observer-analysis02` preserves the v1 failed checked build: callback inputs
  read several times needed explicit sharing annotations. V2 marks shared
  callback and record binders and also fixes the corresponding schema/bridge
  sharing sites; literal helpers remain v1.
- `observer-analysis03` preserves the v2 failed checked build: the local branch
  fact list needed a bidirectional type annotation. `observer-analysis-v3.bend`
  adds that annotation only. Layout and bridge remain v2.

Neither failed build installed an observer. A reviewer also examined a proposed
partial-function demand counterexample and withdrew it after checking
`jd_arity`/`jd_raise`: raising stops at the demanded Let and checked native
entries use this same arity. Saturation semantics remain unchanged; a separate
partial-factory regression control is still useful.

Native Nat representation clarification: the current C runtime defines
`NAT_IMM = (1ull << 48) - 1`; `nat_chk` reports overflow beyond that bound rather
than creating a boxed big integer. A valid checked native Nat is therefore an
immediate word, including values larger than U32. The schema note's generic
warning about a possible large Nat representation does not describe this C ABI.
Raw malformed values still use the ordinary fallback, and numeric literals
recognized here are the source U32 payload subset of that valid range.

Root's analysis04 checked image subsequently accepts both motivating functions
and two structurally unrelated Strand functions in their own checked fixtures.
`audit-plans-v1.py`/`residual-audit01.json` independently check the four actual
residual plans as pure data using captured primitive signatures. This validates
finite residual typing, scopes, wrapper multiplicity and loop-origin conditions;
it is not a compiler fallback, runtime test or source-semantic proof. See the
Phase70 design for exact query paths and the retained wrong-entry refusal.
