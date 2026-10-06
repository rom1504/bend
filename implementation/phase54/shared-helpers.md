# Phase54 shared backend helpers

Source refactor, manifest integration, independent static review and checked
builds are complete. The isolated helper candidate preserves the Phase53 API
and core8 output bytes. Final combined qualification is reported separately in
[qualification](qualification.md). No compiler, generated target or benchmark was executed
by this author. Existing names and complete definition/law bodies are preserved;
this is boundary cleanup, not an optimization or new proof rule.

## Actual split

| Module | Definitions | Responsibility |
| --- | ---: | --- |
| `selfhost/src/back/common/literals.bend` | 6 | Strip annotations; inspect U32/Word literals; classify finite binary32 bits. |
| `selfhost/src/back/common/queries.bend` | 19 | Environment/type/application queries; checked constructor lookup, specialized telescopes and residual counts; binder context/body; whole-type IO recognition. |
| `selfhost/src/back/common/native-facts.bend` | 2 | Inspect native flags and definition/constructor kinds for the checked U32/Word/Bool Base declarations. |
| `selfhost/src/back/js/shared-text.bend` | 7 | JavaScript string quoting, finite binary32 expression text, and `.js` foreign-path selection. |

The common queries include `j_env`, `j_type`, `j_type_on`, `j_app_type`,
`j_call_spine`, `j_context`, `j_body`, `j_find_ctor`, `j_found_ctor`,
`j_specialize`, `j_arm_type`, `j_arm_tel`, `j_layout_ctor`,
`j_constructor_count`, `j_count_constructors`, `j_io_type`, `j_io_shadow`,
`j_io_shadow_def` and `j_io_spine`. Their existing `j_` names are retained to
avoid changing callers or mixing a naming migration into the source move.

Native-facts predicates establish checked declaration ownership only. They are
not complete structural proofs or permission to inline arbitrary native
operations. Literal readers still recognize existing literal spelling/shape;
callers retain their native provenance checks. IO recognition retains its exact
whole-type policy and shadowed-book normalization behavior.

JavaScript runtime representation, native layout decisions, intrinsics, numeric
matcher rows, guards, worker/region admission, readback emission and library
policy stay under `back/js`. Target-specific text is not moved into a supposedly
neutral core. The `.js` foreign selector remains a JavaScript utility even though
its result is a source path rather than emitted code.

## Integration and evidence

Root integrated these modules, in this order, before
`src/back/js/foreign.bend` in `src/compiler.json`:

```text
src/back/common/literals.bend
src/back/common/queries.bend
src/back/common/native-facts.bend
src/back/js/shared-text.bend
```

This author did not edit the manifest, direct/native modules or host tools. Six
legacy JavaScript files lost moved definitions: `emit.bend`, `literals.bend`,
`private-float.bend`, `u32.bend`, `validate.bend` and `foreign.bend`. The integrated
order resolves all moved common `j_*` references inside the common modules;
JavaScript utility references remain within its utility module.

[Inventory](../../selfhost/build/phase54/helper-separation01/inventory.json)
records each moved law/definition's exact byte hash, new module identities,
before/after source hashes and every direct consumer-to-helper owner. Original
files and the pre-integration compiler manifest are preserved beside it in
`before/` and `compiler-manifest-before.json`.

The multiset audit confirms exact definition and law bodies across all 3,124
source definitions, including existing duplicated names/nonmanifest source.
The assembled 103-module baseline has 3,004 definitions; the helper-only 107-module
source still has 3,004. The initial snapshot physical assembled lines rise 26,151 → 26,170, entirely from
new imports/header comments. An EOF-whitespace followup removes five redundant
blank lines, so the final helper-only source is 26,165 lines (+14). Thirty-four definitions move rather than duplicate.
These are static source counts, not generated-code size or compile-time results.

All 62 direct consumer/helper ownership rows now point to the common modules or
`back/js/shared-text.bend`; none resolve through legacy emitter/planner files.
The direct backend files themselves are unchanged. This does not claim that
all legacy helpers are removed from the assembled compiler: the compatibility
backend remains supported and still has its own modules.

The extraction script completed the moves, then its first audit rejected a
pre-existing duplicated `index_set` name because it assumed global uniqueness.
The corrected multiset audit compares name, kind and full body, preserving those
pre-existing duplicates exactly. This data-tool failure caused no compiler
execution or semantic alteration. Delimiter and bare-match-form checks pass for
all four moved modules. Independent review also compared all 278 definition/law
blocks across the six original files, their remainders and four new modules,
confirming no additions, removals or body changes. The protected 103 inherited paths have no intersection
with the six modified source paths.

The helper-only build and output comparison have passed. The later graph
candidate changes separate analysis code and has its own API identity; final
semantic, output-retention and release evidence belongs to the linked
qualification report. Exact moved bodies do not establish faster compilation
or qualify an unrelated graph change.

## Checked helper-only followup

Root reports the helper-only checked build passed in 61.607 seconds with the exact
Phase53 API hash unchanged. All eight core emissions are byte-identical to their
Phase53 counterparts. This establishes the checked source move without an API
or emitted core8 change; it is not a new runtime timing or fixed-point claim.

The subsequent staging whitespace check flagged five trailing blank lines. Only
EOF whitespace in the three common modules, shared-text and private-float was
trimmed (`rstrip` plus one newline).
[Followup receipt](../../selfhost/build/phase54/helper-separation01/whitespace-followup.json)
preserves before/after hashes. The first inventory remains the exact initial
snapshot; the final graph02 build checked the whitespace-clean source and
passed all 36 strict frontend witnesses.
No manifest or graph file was edited by this followup.

The isolated `checked-helpers01` API is
`3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9`,
exactly Phase53. The combined `checked-graph02` API is
`d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857`;
it includes separate graph work and is intentionally a different compiler
image. The isolated identity result must not be attributed to the combined
candidate. Final semantic, native and full emitted-output qualification passes;
see [qualification](qualification.md) for the separate scopes and retained failures.
