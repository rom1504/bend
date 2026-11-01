# Recovering historical experiments

The current compiler and tools should have one maintained implementation.
Historical methods, generated source copies, and compressed evidence bodies can
remain recoverable from Git without occupying the current checkout. Reports,
result summaries, provenance manifests, independent fixtures and proof statements
remain useful current documentation and correctness inputs.

The immutable recovery baseline is
`2a4f9f8383cbc66fadaedd9b4b27f83b93a13511`. Keep that commit reachable when
publishing consolidation commits. Inventory and recovery do not rewrite history,
repack archives, execute a compiler, change the index, or delete files. The
separate retirement tool has an explicit apply command; planning is read-only.

## Inventory and review

| Location | Purpose | Retention |
|---|---|---|
| `selfhost/manifests/history-inventory-v2.json.gz` | Exact baseline blob/path recovery index | One full metadata index at HEAD |
| `history-policy-v1.json`, `history-dependency-review-v1.json` | Retirement classes and exact reviewed exceptions | Small maintained policy records |
| `selfhost/build/consolidation/history-retirement/plan-*.json` | Complete review/apply plan | Ignored build output |
| `implementation/PHASE/history-retirement-receipt.json.gz` | Actual removals, preserved working identities, recovery-index pin | Compressed report evidence after application |
| `history-replay-v1.json`, `history-retirement-controls-v1.json` | Recovery and safety-control outcomes | Compact validation records |

```sh
python3 selfhost/tools/history/inventory.py
```

The policy is `selfhost/manifests/history-policy-v1.json`; the generated exact
file catalog is `history-inventory-v2.json.gz`. This is the only full recovery
index retained at HEAD; gzip contains JSON metadata, not a compiler/code capsule.
Both plain JSON and gzip JSON inputs are supported. Each entry records its repository
path, baseline Git blob ID, Git file mode, size, proposed action and reason.
`retire` is an explicit review proposal, not an instruction executed by this
tool. `blocked` identifies a live dependency awaiting migration. Root must check
the completed build/bench/profiler/law migration maps before applying a list.

Classification distinguishes archived payload objects from the JSON manifests
that describe them, historical method/source files from independent test data,
and generated machine code from scientific result summaries. The conservative
test-asset classification needs review: a directory named `controls` can contain
a complete old compiler, and a content-addressed object can contain a fixture.
Git recovery preserves either case, but any independently maintained test needed
by the consolidated checks must first have a stable current copy.

The policy protects the dirty Phase6/68 working trees from filesystem deletion.
Retirement there can only remove tracked baseline entries from the index while
leaving working bytes intact. The inventory separately pins changed tracked
working files; it never stages user changes. Untracked research is outside the
Git inventory and must remain untouched. The root's workspace preservation audit
is a separate gate; this inventory is not a backup of untracked files.

## Exact, bounded retrieval

Recover one or a few files into a fresh destination, retaining repository paths:

```sh
python3 selfhost/tools/history/restore.py \
  --path selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py \
  --out /tmp/bend-history-example
```

The parent directory must exist; the destination itself must be new. Retrieval
accepts at most 32 files and 64 MiB by default. `--max-mib` changes the byte
budget explicitly. Use `--list-prefix PATH_PREFIX` to inspect a narrow part of
the catalog before selecting paths. No giant worktree or duplicate compiler
binary is needed to inspect an old method or compressed object.

For every selected path, the restore utility verifies membership and mode in
the pinned commit, streams the exact Git blob, and verifies its size and Git
object hash. `restore.json` additionally records SHA256 and whether every file
was recovered. Existing paths are never overwritten, symlink blobs are refused,
and partial output retains an incomplete receipt. Compressed capsule objects
remain compressed: use the historical manifest to select the needed object and
check its uncompressed hash if manually decoding it.

Split archives have ordered `archiveGroups` metadata in the same compressed
index. Numeric `.part-001`, `.part001`, `.part00001` and zero-based variants are
recognized for gzip/xz/zstd/bzip2 tar archives and zip archives. Every part retains
its original Git blob and byte count. A group records consecutive tracked
numbering, not an assertion that the archived payload itself is valid.

```sh
python3 selfhost/tools/history/restore.py --list-groups
python3 selfhost/tools/history/restore.py \
  --archive-group implementation/phase30/evidence/campaign.tar.gz \
  --max-mib 128 --out /tmp/bend-phase30-parts
```

Group recovery checks the complete indexed part set, numbering, sizes and blob
identities, then restores the original parts in numeric order. It neither joins
nor repacks them. The usual 32-file and explicit byte-budget limits still apply;
`restore.json` records the order. If a historical procedure concatenates those
parts, follow that procedure and verify its original complete-archive hash before
extracting anything. No archive payload is copied into the current source tree by
building this recovery metadata.

Recovering a method is not replaying an entire benchmark. Historical programs
may require additional pinned source, data, tools and output identities. Restore
those exact files from the same catalog and follow the experiment manifest;
do not silently substitute today's compiler, flags, inputs or runtime. Any
target execution still belongs in the current disk/resource guard.

## Active dependency audit before retirement

| Current surface | Historical dependency | Disposition |
|---|---|---|
| Build retention | `performance/programs/support.py` | Explicitly retained shared supervisor; the Phase32 lock inode remains unchanged. |
| Native launcher guard | `performance/phase86/guard.py` | Explicitly retained while the old public launcher remains selected. |
| JS/native-graph conformance | Historical graph runner and unchecked prototype adapter | Maintained selected-graph transport and explicit checked adapters replace these routes. The prototype's incidental directory copying is an exact reviewed exception. |
| General profiler and concat extension | Phase68 ELF helper, Phase112 control metadata, Phase144 extension | Selected helpers and fixtures now live under `tools/profiler/`; migration maps retain provenance. |
| Independent law tooling | Historical law runners and source helpers | Current source binding and selected independent fixtures live under `tools/laws/` and `proofs/compiler-laws/`; historical runners remain recoverable from Git. |
| Build tools | Phase130/125 request chain and Phase134/123 machine chain | Maintained build modules and named asset manifests replace runtime imports. Historical asset provenance is data, not a runtime source dependency. |
| Benchmark corpus | Phase37 original45, legacy15, Phase112 timed wrappers/counts | Selected sources/oracles and general execution tools now live under `tools/bench/`, with exact migration provenance. |
| Older JS development | `development/`, `typed-driver.mjs`, compiler ABI/runtime files | Maintained routes remain; unused `private-compiler/` and obsolete unchecked bootstrap implementations are reviewed retirement candidates. `stage0.mjs`, `stage0-library.mjs` and explicit `selfcheck.mjs` remain. |
| Installed native package | `native/selection.json`, profiles/releases and existing asset receipts | All 52 baseline native-surface files remain blocked until the root qualifies and selects the replacement public CLI. Preserve the selected package and required assets. |

Paths in historical JSON provenance are not automatically live runtime imports.
Conversely, an import that is only executed during packaging or proof preparation
is still a dependency. The dependency table and migration maps complement the
inventory; filename classification alone cannot establish safe retirement.

## Dry-run retirement and explicit application

After reviewing migration maps, produce a fresh plan:

```sh
python3 selfhost/tools/history/retire.py plan \
  --out selfhost/build/consolidation/history-retirement/plan.json
```

`--prefix` can restrict a review to one or more narrow path prefixes. The command
prints the exact plan SHA256 and counts. It verifies baseline ancestry and each
candidate's baseline/index blob, hashes dirty working bytes, protects every
current canonical source module, and excludes literal/transitive dependencies
found in maintained tool code. Staged edits are excluded. Untracked files are
never considered. Changed tracked files and workspace-protected Phase6/68 paths
receive index-only operations; their working bytes remain in place.

Full dry-run plans stay under ignored `selfhost/build/`; do not commit a second
80,000-row copy of the recovery index. Keep a compact review summary and, after
application, the compressed receipt in the implementation report. No historical
code archive is repacked or embedded by this metadata compression.

The root must review both `exclusions` and `unresolvedInventoryBlockers`, qualify
replacement tool routes, and freeze edits to selected paths before application.
Literal dependency detection is conservative and cannot prove the absence of
computed paths or dependencies described in external recipes. A successful dry
run is not a claim that migration qualification has passed.

`history-dependency-review-v1.json` records exact reviewed exceptions to the
conservative literal-reference scan. Currently it covers the obsolete prototype
adapter incidentally included in a directory snapshot: no maintained import or
default selects it, and the directory walk works when it is absent. Each exception
binds the consumer's complete SHA256; a changed consumer requires another review.
It does not waive canonical-module, dirty-file, index or blob checks.

Only after that review, the root may invoke:

```sh
python3 selfhost/tools/history/retire.py apply \
  --plan selfhost/build/consolidation/history-retirement/plan.json \
  --sha256 REVIEWED_PLAN_SHA256 \
  --receipt implementation/PHASE/history-retirement-receipt.json.gz
```

Clean dry-run entries use Git cleanliness and file metadata; they are explicitly
marked as requiring a complete content hash during apply. This keeps review from
rereading gigabytes of archived payloads. Apply hashes every selected file and
requires unchanged planning inputs, unchanged selected working bytes, the
same baseline index entries, and no new detected dependency. HEAD may advance
through consolidation commits as long as the recovery baseline remains an
ancestor. Git index removal is performed under the conventional index lock and
checked to preserve every unrelated entry. No replacement contents or user edits
are staged. Clean files are then removed individually; directories are never
recursively deleted. Unexpected edits during deletion are preserved and reported
as conflicts. Treat an incomplete receipt as requiring inspection before commit.
Do not run another editor, cleanup process or staging command against selected
paths during apply; this is not a concurrent filesystem transaction.

`test_retire.py` exercises the destructive operations only in disposable temporary
Git repositories. It covers clean deletion, dirty preservation, staged-edit
exclusion, exact-plan/baseline rejection, transitive dependencies and canonical
module protection. No real repository retirement is needed to run these tests.
