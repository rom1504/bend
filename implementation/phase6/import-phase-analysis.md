# Missing-import phase analysis

Read-only conclusion: all five reported fixture gaps have the same host boundary cause. Tagging only `ENOENT` from an explicit imported target's `realpathSync` as `parse` is a plausible narrow repair; no compiler semantic change is needed. **No patch or compiler probe was run.** The [design](../../design/phase6/import-phase-boundary.md) states the proposed contract and gates.

The retained final observations are `selfhost/build/phase5/integration/attempt-05/validation-001/frontend.json` (SHA `bc233aef92977a0acdc2b5c7a03a707709a5dbb300b9d0ab8b20e58f6bda5d22`) and live reference `integration/reference-03.json` (SHA `f3abefb8d7e9db2ee09847422db08ddf023e70358b84be256c55a579b857716a`). Each of the following has identical status/checked/exit classifications across both lanes, differing in `load` versus `parse` and diagnostic text:

| Fixture | Requested absent target | Current Bend error path |
|---|---|---|
| `import/cross_file_io.bend` | `/shared/io_tree.bend` | `/shared` |
| `import/cross_file_proof.bend` | `/shared/proof_chain.bend` | `/shared` |
| `import/cycle_terminates.bend` | `/cycle/other_half.bend` | `/cycle` |
| `import/diamond_dedup.bend` | `/diamond/top.bend` | `/diamond` |
| `import/path_canonical.bend` | `/mods/canonical.bend` | `/mods` |

Source evidence: `tools/typed-driver.mjs::inspectWithMemo` sets `load` before Base-cache/source discovery and `parse` after discovery; `discoverSources::visit` invokes `realpathSync` without an import-specific phase. `tools/conformance/adapters/upstream.mjs::probeWithModules` starts at `parse` for `B.book_load`. Pinned `bend2/bend.ts::book_load` checks existence, then uses the imported target's span for a structured error; it loads the leading imports before calling `parse_book` on the current body.

Moving the entire discovery interval to `parse` would match that broad reference convention but also relabel original-input and unrelated IO/internal failures. The proposed narrower exception tag avoids that API expansion and preserves existing error text and error order. In particular, Base/API resource failures must not be hidden, an explicit phase must not be overwritten, and the original source path must remain distinct from an absent import target.

A missing import plus malformed current body reveals a separate possible first-error mismatch: upstream visits the import first, whereas Bend parses the current body before traversing imports. This is a **static prediction**, not a newly reproduced result. The design provides small counterexamples and requires fresh live witnesses before any order change. The five retained fixtures have valid bodies, so that issue does not explain their observed phase mismatch.

If validated, the narrow correction can remove ten phase disagreements, leaving six across the existing inventory. Their differing diagnostics remain; no strict checker failure or exact-observation improvement is promised. The fixture comments explicitly say the flat corpus lacks those module trees, so these observations provide no successful cycle/diamond/IO/proof execution evidence.
