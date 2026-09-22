# P4-018 — Native annotation can use an immutable declaration split

- Owner: lexer-analysis; reviewer: root, pending independent implementation review.
- Started/evidence cutoff: 2026-09-22, approximately 17:45–17:49 UTC; bounded read-only assessment.
- Objective: shorten native full-source compiler wall time using existing CPU fork/join execution. This is investigator-proposed multicore work, not a single-core speedup claim.
- Correctness status: source-level dependency assessment only; no candidate binary or tests.
- Measurement status: not run. No profile percentage or predicted overall speedup is established.
- Decision: **defer annotation prototype to the next campaign; reject naive parallel checking against a final book**.
- Related: [P4-017](P4-017-native-frontend-feasibility.md), [native final measurements](../../implementation/phase4/native-final.md), [full proposal](../../design/phase4/native_annotation_parallelism.md).

## Claim and cheapest disproof

`annotate_selected` maps independent `ka_def` computations over one immutable full `book_context`, retaining the selected list order. A checked native wrapper can split that list once into contiguous chunks, run the unchanged `ka_defs_except` concurrently, then concatenate in order. No prior annotated result feeds the next declaration. The pinned runtime already emits CPU fork/join tasks for multi-binding lets.

The first falsifier is exact annotated-tree inequality or unintended context rebuilding. The next is a one-worker wrapper overhead above 5%, less than 20% annotation-wall reduction on two workers in opposite-order trials, or peak RSS above 1.5× serial. These are predeclared proposed gates; nothing has been measured here. Retain the unchanged serial checker, gates and layout/emission phases.

`check_book` has a different invariant: each event uses its exact preceding context, a body-absent current declaration, ordered event errors and a deliberate suffix lookup for unsafe law fills. Template extensions are local. Selecting the lowest-index failure after speculative checks does not preserve demand behavior if later work diverges or exhausts resources. Rechecking every definition in a reconstructed book is expressly excluded.

## Controlled setup proposed, not executed

Use the final Phase 4 frozen compiler source SHA `34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122`, checked B1 SHA `0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810`, unchanged pinned TypeScript C emitter at `6018e28ecc67cf1fffc0c20c64b11023474c2df8`, and the existing canonical Base/runtime identity. Parent owns CPU allocation; no timed jobs were started by this assessment.

The future wrapper must report checked build/O2 costs, exact source/C/binary hashes, annotation-only and split/join-inclusive timings, output consumption, process wall, total CPU and peak RSS. Same binary at one/two/four workers plus the original serial wrapper distinguishes scheduler effects from algorithm changes. Retain all samples and use physical affinity appropriate to the worker count. The inherited 245.364-second whole-native median does not establish an annotation fraction or parallel ceiling.

## Read-only observations

| Source | Finding | Consequence |
| --- | --- | --- |
| `src/check/kernel.bend:1033–1103` | Ordered `check_events`, prior-context `event_error`, own `declared(d)`, suffix `signature_mode` | No final-book parallel checker substitution |
| `src/check/kernel.bend:1186–1195` | Template binders extend only their recursive checking book | Worker-local state must not become a shared update |
| `src/check/annotate.bend:149–187` | Same context per definition, ordered map, explicit local environment | Annotation-only split/combine candidate |
| `src/core/index.bend:215–246` | Persistent book updates and immutable cache sentinel | Build/share one context, preserve first-match and binder bound |
| pinned `comp.ts:2557`, `4790–4837`, `5290` | Existing fork/join, pthread pool, serial fallback | No scheduler redesign needed |
| pinned `comp.ts:3976`, `4113` and `tests/reg/borrow_fork_hold.bend` | Shared ownership and borrowed-reader support | Inspect actual compiler context captures; RC/copy costs remain unknown |

## Decision and preservation

The [design](../../design/phase4/native_annotation_parallelism.md) records exact split/combine semantics, checker obstructions, runtime feasibility, memory/error-demand limits, proposed gates and an estimated 60–90-minute first implementation before broad validation. No production source, wrapper, binary, cache or completed proof was changed. The source is retained in the repository/pinned checkout; final source/API identities and native evidence are already archived by their linked reports. There are no omitted measurements or generated candidate artifacts. Root will link this assessment into the ledger; no promotion is implied.

## Authorized isolated falsifier

At approximately 17:51 UTC root authorized a disposable checked wrapper and component experiment, bounded until **19:15 UTC**. The earlier defer decision remains the read-only assessment; this is a new explicitly authorized attempt. CPU3 is reserved for build and initial serial checks. Two/four-worker runs require fresh CPU coordination after root's active gates release their cores. No production modules or default APIs may change. Exact small-tree oracles and actual emitted fork inspection precede timing. Stop and retain a build/ownership/protocol obstruction if the checked integration cannot be completed credibly within the window; do not weaken gates or substitute unchecked compilation.
