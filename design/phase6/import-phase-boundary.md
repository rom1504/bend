# Missing declared imports: a narrow phase boundary

Status: read-only design, 2026-09-23. No host/compiler edit or fresh probe is represented here. Preserve the released compiler and the currently frozen backend/timing inputs.

## Evidence and intended change

Final Phase5 has five missing-import fixtures, each observed in parse and check lanes: `cross_file_io`, `cross_file_proof`, `cycle_terminates`, `diamond_dedup`, and `path_canonical` under `tests/import`. All ten Bend observations reject with `phase:load`, `checked:false`, exit 1; live pinned TypeScript rejects with `phase:parse`, `checked:false`, exit 1. Their diagnostics differ independently. These flat fixtures deliberately reference absent absolute module trees; their names do not establish successful cycle, diamond or cross-file execution coverage.

The typed host initializes `phase='load'`, computes/validates Base-cache information, and calls `discoverSources`; it changes to `parse` only afterward. Discovery calls `fs.realpathSync` before reading/parsing each file. All five observed failures are `ENOENT` at this call, often naming the missing parent (`/shared`, `/cycle`, `/diamond`, `/mods`). Upstream `book_load` instead checks existence and throws a structured no-such-file error with the import-site span. Its reference adapter labels the whole `book_load` interval `parse`.

The smallest conservative contract is: **a nonexistent target encountered while resolving an explicit recursive import is a parse-phase rejection; other existing loader/infrastructure classifications remain unchanged.** This is a reporting change only. It must not create/read substitute files, suppress errors, change traversal order, rewrite diagnostics, or accept a source.

Proposed shape, not an implemented patch:

1. Add an internal `fromImport=false` flag to discovery's `visit` helper.
2. Catch errors immediately around `fs.realpathSync(file)` only.
3. If `fromImport` is true, `error.code==='ENOENT'`, and no phase was already assigned, tag the same error with `phase:'parse'`; then rethrow it.
4. Pass `true` only from the declared-import recursion. The initial source visit keeps the default.

All existing caller result construction and error selection stay unchanged. Do not parse English error messages or infer imported status from a path/name. Do not add `existsSync` before the operation: it adds a race and unnecessary IO. Do not classify `EACCES`, `EIO`, `ELOOP`, `EISDIR`, generic `TypeError`, or explicitly tagged module-collision failures as missing-source syntax. `ENOTDIR` can be considered separately after an actual witness; it is not needed for these ten observations.

A blanket move of `phase='parse'` before `discoverSources` aligns the reference adapter's broader convention, but also relabels absent root input, permissions/read failures and internal parser exceptions. That is a larger API taxonomy decision. The narrow fix deliberately leaves missing original input as `load`, including its known difference from the reference. Modern compiler Base-cache preflight occurs before discovery, so a missing bundled Base/API-resource failure also remains in its existing path. API import errors occur outside the inner inspection catch and must remain unchanged.

## Gates before promotion

- Reuse the five pinned fixtures, both lanes, live TypeScript and released derivative. Require only the ten intended phase changes, unchanged status/checked/exit/diagnostic, and no new sourceFile field. Exact TS diagnostic parity is not the oracle.
- Fresh unique temporary directory: missing relative target, missing absolute target, nested missing dependency; all are parse-phase rejections without executing the checker. Keep complete files/requests rather than borrowing old missing paths.
- Missing original input: remains `load`; malformed source in an existing root/dependency remains `parse` with the correct actual `sourceFile`. Missing bundled Base during existing preflight remains unchanged.
- Nonexistent target versus directory target, broken symlink, symlink loop, permission failure and a mocked IO failure: verify that only the scoped `ENOENT` import path changes. Mock filesystem failures in host unit tests; do not depend on root/permission behavior of a shared machine.
- Confirm an existing explicit phase is never overwritten and module-path collision remains its current error. Check public inspection and persistent sessions; modify/recreate the source between requests to reject stale memo reuse.
- Positive imported executable plus alias/canonical-path/repeated-Base controls: preserve raw results and emitted/executed output. Ordinary no-import compiler configuration/phase behavior must remain unchanged.
- Preserve first-error controls described below; do not silently change their oracle to make the new phase claim stronger.

No accepted path needs a new traversal, file access, parser call or cache. A try/catch enclosing the already-required realpath operation and one explicit recursive flag suffices. Its cost is unmeasured; make no performance claim.

## First-error and diagnostic limits

A static counterexample requires a fresh witness before any broader repair:

```bend
import ./absent.bend as M
def main() -> U32:
  (
```

Upstream loads leading imports before `parse_book` on the remaining body; Bend discovery first calls `f_parse` on the entire current file and then visits its returned imports. Consequently upstream is expected to choose the missing import, while Bend may choose the malformed current body first. The same issue can arise with a missing first import followed by malformed later import syntax. Phase tagging cannot and should not alter this order. Repairing it would require a separate loader/parser design, not another catch clause.

The five existing diagnostics still need a separate origin-aware design: TypeScript names the full unresolved target and highlights the import line; Bend currently preserves Node's ENOENT text, which may name only the absent parent. Do not attach the importer as `sourceFile` as though it were the file whose text failed parsing, and do not claim canonical-path identity for a nonexistent file. Preserve requested target and import origin as distinct data if later diagnostics need them.

Expected bounded result, if fresh gates pass: status/phase differences 16→6 across the final frontend inventory, but **zero guaranteed exact-diagnostic repairs and no strict-failure reduction**. Existing 318 strict failures remain unless a separate diagnostic change is proved. This is a small, low-risk taxonomy correction under the narrow contract; it is not the next major compiler-performance improvement.
